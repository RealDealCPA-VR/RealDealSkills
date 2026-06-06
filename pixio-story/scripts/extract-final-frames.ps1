# Extract evenly-distributed sample frames from final.mp4 so the agent can do a Stage 7 quality
# gate (vision-compare against the treatment's central_question + climax landing + identity
# consistency). Used by pipeline.ps1's automatic post-stitch watch step (unless -SkipWatch).
#
# Drops 8 frames into <project>/final-watch/:
#   frame_01.jpg through frame_08.jpg (evenly distributed across the film's duration)
#
# Uses ffmpeg if available (free, fast). Falls back to just the last frame via Pixio
# video-ops/last-frame (free, single-frame). With only one frame the agent can still spot-check
# the closing image but cannot verify pacing or climax landing.

[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$ProjectDir,
  [int]$FrameCount = 8
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib-pixio.ps1')

$finalPath = Join-Path $ProjectDir 'output\final.mp4'
if (-not (Test-Path $finalPath)) { throw "no final.mp4 at $finalPath - run stitch first" }

$watchDir = Join-Path $ProjectDir 'final-watch'
if (-not (Test-Path $watchDir)) { New-Item -ItemType Directory -Path $watchDir | Out-Null }

$ffmpeg = Get-Command ffmpeg -ErrorAction SilentlyContinue
$useFfmpeg = $null -ne $ffmpeg

$index = @{ frames = @(); source = $finalPath; mode = $null }

if ($useFfmpeg) {
  $probeRaw = & $ffmpeg.Source -i $finalPath 2>&1 | Out-String
  $dur = if ($probeRaw -match 'Duration:\s*(\d+):(\d+):([\d\.]+)') {
    [double]$matches[1]*3600 + [double]$matches[2]*60 + [double]$matches[3]
  } else { 0.0 }
  if ($dur -le 0) { throw "ffmpeg could not determine final.mp4 duration" }

  Write-Host "  final.mp4 duration: $([Math]::Round($dur,1))s — extracting $FrameCount frames"
  $index.mode = 'ffmpeg'
  $index.duration_s = $dur

  # Even distribution: skip the very first and last 5% (likely fade-in/fade-out frames that don't
  # represent shot content). Frames land at 0.05, 0.05+step, ... up to 0.95 of duration.
  $start = 0.05 * $dur
  $end   = 0.95 * $dur
  $step  = ($end - $start) / [Math]::Max(1, $FrameCount - 1)
  for ($i = 0; $i -lt $FrameCount; $i++) {
    $ts = [Math]::Round($start + $i * $step, 2)
    $outPath = Join-Path $watchDir ("frame_{0:D2}.jpg" -f ($i + 1))
    & $ffmpeg.Source -y -ss $ts -i $finalPath -vframes 1 -q:v 3 $outPath 2>&1 | Out-Null
    if (Test-Path $outPath) {
      $index.frames += @{ index = $i + 1; t_seconds = $ts; path = $outPath }
    }
  }
} else {
  Write-Host "  ffmpeg not on PATH — falling back to last-frame only via Pixio (1 frame)" -ForegroundColor Yellow
  $index.mode = 'pixio-last-frame'
  $stitchCk = Read-Checkpoint $ProjectDir 'stitch'
  if (-not $stitchCk -or -not $stitchCk.finalId) {
    Write-Warning "stitch checkpoint missing finalId; cannot extract last frame via Pixio"
  } else {
    try {
      $vPath = Get-PixioPath -ContentId $stitchCk.finalId
      $lfCid = Invoke-PixioGenerate -ModelId 'pixio/video-ops/last-frame' -Params @{ videoUrl = $vPath }
      $lfGen = Wait-PixioGeneration -ContentId $lfCid -MaxSeconds 300
      if ($lfGen.status -eq 'succeeded') {
        $outPath = Join-Path $watchDir 'frame_01.jpg'
        Save-PixioMedia -ContentId $lfCid -Destination $outPath
        if (Test-Path $outPath) { $index.frames += @{ index = 1; t_seconds = -1; path = $outPath; note = 'last frame only (no ffmpeg)' } }
      } else { Write-Warning "last-frame extract failed: $($lfGen.error)" }
    } catch { Write-Warning "last-frame extract errored: $($_.Exception.Message)" }
  }
}

$craftPath = Join-Path $ProjectDir 'craft.json'
if (Test-Path $craftPath) { $index.craft_reference = $craftPath }
$indexPath = Join-Path $watchDir 'final-watch.json'
$index | ConvertTo-Json -Depth 10 | Set-Content -Path $indexPath -Encoding utf8
Write-Host "  $($index.frames.Count) frame(s) in $watchDir" -ForegroundColor Green
Write-Host "  Index: $indexPath" -ForegroundColor Green
