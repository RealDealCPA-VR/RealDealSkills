# Extract preview frames from hero-shot variants so the agent can vision-compare them and write
# picks.json. Used by pipeline.ps1's -PausePick flow.
#
# For each hero shot with multiple variants (shots/shot_XX_v1.mp4, _v2.mp4, ...), drops three
# preview frames per variant into <project>/picks-preview/shot_XX/:
#   shot_XX_v1_a.jpg  (~10% into the clip)
#   shot_XX_v1_b.jpg  (~50% into the clip)
#   shot_XX_v1_c.jpg  (~90% into the clip)
#
# Uses ffmpeg if available (free, fast, 3 frames per variant). Falls back to Pixio's
# video-ops/last-frame (1 frame per variant, free, but only the ending — still useful for
# identity/composition comparison since the input keyframe is shared across variants).

[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$ProjectDir
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib-pixio.ps1')

$storyPath = Join-Path $ProjectDir 'story.json'
if (-not (Test-Path $storyPath)) { throw "story.json not found in $ProjectDir" }
$story = Get-Content $storyPath -Raw | ConvertFrom-Json

$shotsDir = Join-Path $ProjectDir 'shots'
if (-not (Test-Path $shotsDir)) { throw "no shots/ in $ProjectDir - run animate stage first" }

$previewDir = Join-Path $ProjectDir 'picks-preview'
if (-not (Test-Path $previewDir)) { New-Item -ItemType Directory -Path $previewDir | Out-Null }

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
$useFfmpeg = $null -ne $ffmpeg
if ($useFfmpeg) { Write-Host "  ffmpeg detected: extracting 3 frames per variant" -ForegroundColor DarkGray }
else { Write-Host "  ffmpeg not on PATH: falling back to last-frame only (1 per variant)" -ForegroundColor Yellow }

$heroSet = @{}
if ($story.hero_shots) { foreach ($i in @($story.hero_shots)) { $heroSet["$i"] = $true } }
if ($heroSet.Count -eq 0) { Write-Host "  no hero_shots in story.json - nothing to extract"; return }

$summary = @{ shots = @() }
foreach ($shot in ($story.shots | Sort-Object id)) {
  $key = "$($shot.id)"
  if (-not $heroSet.ContainsKey($key)) { continue }

  $shotPreviewDir = Join-Path $previewDir ("shot_{0:D2}" -f $shot.id)
  if (-not (Test-Path $shotPreviewDir)) { New-Item -ItemType Directory -Path $shotPreviewDir | Out-Null }

  # Find all variant files for this shot. Naming: shot_XX_v1.mp4 .. shot_XX_v9.mp4.
  $variants = @(Get-ChildItem -Path $shotsDir -Filter ("shot_{0:D2}_v*.mp4" -f $shot.id) -ErrorAction SilentlyContinue | Sort-Object Name)
  if ($variants.Count -lt 2) {
    Write-Host "  shot ${key}: only $($variants.Count) variant(s) - no pick to make" -ForegroundColor DarkGray
    continue
  }

  Write-Host "  shot ${key}: extracting from $($variants.Count) variants"
  $shotEntry = @{ id = [int]$shot.id; action = "$($shot.action)"; camera = "$($shot.camera)"; variants = @() }

  foreach ($v in $variants) {
    $vIdx = if ($v.Name -match '_v(\d+)\.mp4$') { [int]$matches[1] } else { 0 }
    if ($vIdx -le 0) { continue }
    $vEntry = @{ index = $vIdx; file = $v.FullName; frames = @() }

    if ($useFfmpeg) {
      # Get duration via ffprobe-style ffmpeg invocation. Parse "Duration: hh:mm:ss.xx".
      $probeRaw = & $ffmpeg.Source -i $v.FullName 2>&1 | Out-String
      $dur = if ($probeRaw -match 'Duration:\s*(\d+):(\d+):([\d\.]+)') {
        [double]$matches[1]*3600 + [double]$matches[2]*60 + [double]$matches[3]
      } else { [double]($shot.duration_s) }
      $picks = @{ a = [Math]::Max(0.1, $dur * 0.10); b = [Math]::Max(0.5, $dur * 0.50); c = [Math]::Max($dur - 0.3, $dur * 0.90) }
      foreach ($k in @('a','b','c')) {
        $outPath = Join-Path $shotPreviewDir ("shot_{0:D2}_v{1}_{2}.jpg" -f $shot.id, $vIdx, $k)
        $ts = [Math]::Round($picks[$k], 2)
        & $ffmpeg.Source -y -ss $ts -i $v.FullName -vframes 1 -q:v 3 $outPath 2>&1 | Out-Null
        if (Test-Path $outPath) { $vEntry.frames += @{ position = $k; path = $outPath; t_seconds = $ts } }
      }
    } else {
      # No ffmpeg — pull the last frame via Pixio video-ops (free). Single frame per variant; the
      # input keyframe (Stage 4) is shared across variants so start/mid frames offer little
      # differentiation signal anyway.
      $shotsState = Read-Checkpoint $ProjectDir 'shots'
      $stateEntry = if ($shotsState) { $shotsState[$key] } else { $null }
      $variantContentId = $null
      if ($stateEntry -and $stateEntry.variants) {
        $match = $stateEntry.variants | Where-Object { $_.contentId } | Select-Object -Index ($vIdx - 1)
        if ($match) { $variantContentId = $match.contentId }
      }
      if (-not $variantContentId) {
        Write-Warning "  shot ${key} v${vIdx}: no contentId in state for last-frame fallback"
        continue
      }
      $vPath = Get-PixioPath -ContentId $variantContentId
      try {
        $lfCid = Invoke-PixioGenerate -ModelId 'pixio/video-ops/last-frame' -Params @{ videoUrl = $vPath }
        $lfGen = Wait-PixioGeneration -ContentId $lfCid -MaxSeconds 300
        if ($lfGen.status -eq 'succeeded') {
          $outPath = Join-Path $shotPreviewDir ("shot_{0:D2}_v{1}_c.jpg" -f $shot.id, $vIdx)
          Save-PixioMedia -ContentId $lfCid -Destination $outPath
          if (Test-Path $outPath) { $vEntry.frames += @{ position = 'c'; path = $outPath; t_seconds = [double]($shot.duration_s) } }
        } else { Write-Warning "  shot ${key} v${vIdx}: last-frame failed - $($lfGen.error)" }
      } catch { Write-Warning "  shot ${key} v${vIdx}: last-frame errored - $($_.Exception.Message)" }
    }

    $shotEntry.variants += $vEntry
  }

  $summary.shots += $shotEntry
}

# Drop a summary JSON so the agent can read a single file to know what's where.
$summaryPath = Join-Path $previewDir 'picks-preview.json'
$summary | ConvertTo-Json -Depth 10 | Set-Content -Path $summaryPath -Encoding utf8
Write-Host "`n  Preview frames in $previewDir" -ForegroundColor Green
Write-Host "  Index: $summaryPath" -ForegroundColor Green
