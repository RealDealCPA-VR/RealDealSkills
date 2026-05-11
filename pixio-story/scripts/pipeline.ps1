# pixio-story pipeline.
# Usage:
#   .\pipeline.ps1 -ProjectDir .\projects\my-story
#   .\pipeline.ps1 -ProjectDir .\projects\my-story -Stage anchors    # run a single stage
#   .\pipeline.ps1 -ProjectDir .\projects\my-story -NoAnimate         # skip stage 5 (illustrated story mode)
#   .\pipeline.ps1 -ProjectDir .\projects\my-story -NoAudio           # skip stage 6
#
# The project dir must contain a story.json (see ../examples/example-story.json).
# Each stage is checkpointed; re-running picks up where it left off.

[CmdletBinding()]
param(
  [Parameter(Mandatory)][string]$ProjectDir,
  [ValidateSet('all','anchors','keyframes','animate','audio','stitch')][string]$Stage = 'all',
  [switch]$NoAnimate,
  [switch]$NoAudio,
  [switch]$Force   # ignore checkpoints, rerun
)

$ErrorActionPreference = 'Stop'
. (Join-Path $PSScriptRoot 'lib-pixio.ps1')

if (-not (Test-Path $ProjectDir)) { throw "Project directory not found: $ProjectDir" }
$storyPath = Join-Path $ProjectDir 'story.json'
if (-not (Test-Path $storyPath)) { throw "story.json not found in $ProjectDir" }
$story = Get-Content $storyPath -Raw | ConvertFrom-Json

$dirs = @{
  anchors   = Join-Path $ProjectDir 'anchors'
  keyframes = Join-Path $ProjectDir 'keyframes'
  shots     = Join-Path $ProjectDir 'shots'
  audio     = Join-Path $ProjectDir 'audio'
  output    = Join-Path $ProjectDir 'output'
}
foreach ($d in $dirs.Values) { if (-not (Test-Path $d)) { New-Item -ItemType Directory -Path $d | Out-Null } }

$models = $story.models
if (-not $models) { throw "story.json missing 'models' block" }

# --- STAGE 3: anchors -------------------------------------------------------
function Invoke-Anchors {
  Write-Host "`n=== STAGE 3: anchors ===" -ForegroundColor Cyan
  $ck = if (-not $Force) { Read-Checkpoint $ProjectDir 'anchors' }
  if ($ck) { Write-Host "  cached, skipping (use -Force to rerun)"; return $ck }

  $anchors = @{}
  foreach ($char in $story.bible.characters) {
    Write-Host "  anchor: $($char.id)"
    $prompt = "$($char.wardrobe). $($char.face), $($char.hair), $($char.build). $($char.anchor_pose). $($char.anchor_setting). $($story.bible.style)"
    $params = @{ prompt = $prompt; image_size = 'landscape_16_9' }
    # Common alt param name on some models is 'aspect_ratio'; the pipeline sets both safely
    if ($story.aspect_ratio) { $params['aspect_ratio'] = $story.aspect_ratio }
    $cid = Invoke-PixioGenerate -ModelId $models.anchor -Params $params
    $gen = Wait-PixioGeneration -ContentId $cid
    if ($gen.status -ne 'succeeded') { throw "anchor failed for $($char.id): $($gen.error)" }
    $anchors[$char.id] = @{ contentId = $cid; url = (Get-PixioOutputUrl $gen) }
    Save-PixioMedia -ContentId $cid -Destination (Join-Path $dirs.anchors "$($char.id).jpg")
  }
  Write-Checkpoint $ProjectDir 'anchors' $anchors
  return $anchors
}

# --- STAGE 4: keyframes ----------------------------------------------------
function Invoke-Keyframes {
  param($Anchors)
  Write-Host "`n=== STAGE 4: keyframes ===" -ForegroundColor Cyan
  $ck = if (-not $Force) { Read-Checkpoint $ProjectDir 'keyframes' }
  $keyframes = if ($ck) { $ck } else { @{} }

  foreach ($shot in $story.shots) {
    $key = "$($shot.id)"
    if ($keyframes.$key -and $keyframes.$key.contentId) { Write-Host "  shot $key cached"; continue }

    Write-Host "  keyframe: shot $($shot.id)"
    # Build prompt
    $charDesc = ($shot.characters | ForEach-Object {
      $c = $story.bible.characters | Where-Object { $_.id -eq $_.id -and $_.id -eq $_ } | Select-Object -First 1
      $c = $story.bible.characters | Where-Object { $_.id -eq $shot.characters[0] }   # simplified for first character
      "$($c.name)"
    }) -join ', '
    $prompt = "Keep the same person, same face, same wardrobe. $($shot.action) Shot type: $($shot.shot_type). Camera: $($shot.camera). $($story.style)"

    # Choose input image: previous shot's last frame if continuity, else first character's anchor.
    $inputUrl = $null
    if ($shot.previous_shot_continuity) {
      $prev = $keyframes."$($shot.previous_shot_continuity)"
      if ($prev -and $prev.contentId) { $inputUrl = Get-FreshPixioUrl -ContentId $prev.contentId }
    }
    if (-not $inputUrl -and $shot.characters.Count -gt 0) {
      $anchorMeta = $Anchors.($shot.characters[0])
      if ($anchorMeta) { $inputUrl = Get-FreshPixioUrl -ContentId $anchorMeta.contentId }
    }

    $params = @{
      prompt        = $prompt
      aspect_ratio  = $story.aspect_ratio
      output_format = 'png'
      resolution    = '1K'
    }
    if ($inputUrl) { $params['image_urls'] = @($inputUrl) }

    $cid = Invoke-PixioGenerate -ModelId $models.keyframe -Params $params
    $gen = Wait-PixioGeneration -ContentId $cid
    if ($gen.status -ne 'succeeded') { Write-Warning "keyframe shot $($shot.id) failed: $($gen.error)"; continue }
    $keyframes[$key] = @{ contentId = $cid; url = (Get-PixioOutputUrl $gen) }
    Save-PixioMedia -ContentId $cid -Destination (Join-Path $dirs.keyframes ("shot_{0:D2}.png" -f $shot.id))
    Write-Checkpoint $ProjectDir 'keyframes' $keyframes
  }
  return $keyframes
}

# --- STAGE 5: animate ------------------------------------------------------
function Invoke-Animate {
  param($Keyframes)
  Write-Host "`n=== STAGE 5: animate ===" -ForegroundColor Cyan
  $ck = if (-not $Force) { Read-Checkpoint $ProjectDir 'shots' }
  $shotsState = if ($ck) { $ck } else { @{} }

  foreach ($shot in $story.shots) {
    $key = "$($shot.id)"
    if ($shotsState.$key -and $shotsState.$key.contentId) { Write-Host "  shot $key cached"; continue }
    $kf = $Keyframes.$key
    if (-not $kf) { Write-Warning "no keyframe for shot $key, skipping"; continue }

    Write-Host "  animate: shot $key ($($shot.duration_s)s)"
    $kfUrl = Get-FreshPixioUrl -ContentId $kf.contentId

    # Model param names vary; below works for WAN-family. Adjust per /api/v1/params for your chosen model.
    $params = @{
      image_url    = $kfUrl
      prompt       = "$($shot.action). Camera: $($shot.camera). $($story.style)"
      duration     = $shot.duration_s
      aspect_ratio = $story.aspect_ratio
    }
    $cid = Invoke-PixioGenerate -ModelId $models.animate -Params $params
    $gen = Wait-PixioGeneration -ContentId $cid -MaxSeconds 900
    if ($gen.status -ne 'succeeded') { Write-Warning "animate shot $key failed: $($gen.error)"; continue }
    $shotsState[$key] = @{ contentId = $cid; url = (Get-PixioOutputUrl $gen) }
    Save-PixioMedia -ContentId $cid -Destination (Join-Path $dirs.shots ("shot_{0:D2}.mp4" -f $shot.id))
    Write-Checkpoint $ProjectDir 'shots' $shotsState
  }
  return $shotsState
}

# --- STAGE 6a: audio per shot ---------------------------------------------
function Invoke-Audio {
  param($Shots)
  Write-Host "`n=== STAGE 6a: audio ===" -ForegroundColor Cyan
  $ck = if (-not $Force) { Read-Checkpoint $ProjectDir 'audio' }
  $audioState = if ($ck) { $ck } else { @{} }

  foreach ($shot in $story.shots) {
    $key = "$($shot.id)"
    if ($audioState.$key) { continue }
    $tracks = @()

    if ($shot.dialogue) {
      $voice = ($story.bible.characters | Where-Object { $_.id -eq $shot.characters[0] }).voice_id
      if ($voice -and $models.tts) {
        $cid = Invoke-PixioGenerate -ModelId $models.tts -Params @{ text = $shot.dialogue; voice = $voice }
        $gen = Wait-PixioGeneration -ContentId $cid
        if ($gen.status -eq 'succeeded') {
          $local = Join-Path $dirs.audio ("shot_{0:D2}_dialogue.wav" -f $shot.id)
          Save-PixioMedia -ContentId $cid -Destination $local
          $tracks += $local
        }
      } else { Write-Warning "shot $key has dialogue but no voice_id or tts model — skipping" }
    }

    if ($shot.sfx -and $models.sfx) {
      $sfxIdx = 0
      foreach ($tag in $shot.sfx) {
        $sfxIdx++
        $cid = Invoke-PixioGenerate -ModelId $models.sfx -Params @{ prompt = $tag; duration = $shot.duration_s }
        $gen = Wait-PixioGeneration -ContentId $cid
        if ($gen.status -eq 'succeeded') {
          $local = Join-Path $dirs.audio ("shot_{0:D2}_sfx_{1}.wav" -f $shot.id, $sfxIdx)
          Save-PixioMedia -ContentId $cid -Destination $local
          $tracks += $local
        }
      }
    }

    $audioState[$key] = @{ tracks = $tracks }
    Write-Checkpoint $ProjectDir 'audio' $audioState
  }

  # Music bed (one for the whole project)
  if ($models.music -and -not $audioState['_music']) {
    $totalDur = ($story.shots | Measure-Object -Property duration_s -Sum).Sum + 4
    $musicPrompt = if ($story.music_prompt) { $story.music_prompt } else { "instrumental score matching: $($story.logline). Style: $($story.style)" }
    Write-Host "  music ($totalDur s)"
    $cid = Invoke-PixioGenerate -ModelId $models.music -Params @{ prompt = $musicPrompt; duration = $totalDur }
    $gen = Wait-PixioGeneration -ContentId $cid -MaxSeconds 900
    if ($gen.status -eq 'succeeded') {
      $local = Join-Path $dirs.audio 'music.wav'
      Save-PixioMedia -ContentId $cid -Destination $local
      $audioState['_music'] = @{ path = $local }
      Write-Checkpoint $ProjectDir 'audio' $audioState
    }
  }

  return $audioState
}

# --- STAGE 6b: stitch ------------------------------------------------------
function Invoke-Stitch {
  param($Shots, $Audio)
  Write-Host "`n=== STAGE 6b: stitch ===" -ForegroundColor Cyan
  $ffmpeg = (Get-Command ffmpeg -ErrorAction SilentlyContinue)
  if (-not $ffmpeg) { Write-Warning "ffmpeg not on PATH — skipping final stitch"; return }

  $shotFiles = @()
  foreach ($shot in ($story.shots | Sort-Object id)) {
    $f = Join-Path $dirs.shots ("shot_{0:D2}.mp4" -f $shot.id)
    if (Test-Path $f) {
      $shotFiles += $f
      # Mux per-shot audio if available
      $trackData = $Audio."$($shot.id)"
      if ($trackData -and $trackData.tracks -and $trackData.tracks.Count -gt 0 -and -not $NoAudio) {
        $withAudio = Join-Path $dirs.shots ("shot_{0:D2}_a.mp4" -f $shot.id)
        $aArgs = @('-y','-i',$f)
        foreach ($t in $trackData.tracks) { $aArgs += '-i'; $aArgs += $t }
        $filterIn = ((0..($trackData.tracks.Count-1)) | ForEach-Object { "[$($_+1):a]" }) -join ''
        $aArgs += @('-filter_complex',"${filterIn}amix=inputs=$($trackData.tracks.Count):duration=first[a]",'-map','0:v','-map','[a]','-c:v','copy','-shortest',$withAudio)
        & ffmpeg @aArgs 2>$null | Out-Null
        if (Test-Path $withAudio) { $shotFiles[-1] = $withAudio }
      }
    }
  }

  $concatList = Join-Path $ProjectDir 'concat.txt'
  Set-Content -Encoding ascii $concatList ($shotFiles | ForEach-Object { "file '$_'" })

  $stitched = Join-Path $dirs.output 'stitched_no_music.mp4'
  & ffmpeg -y -f concat -safe 0 -i $concatList -c:v libx264 -crf 18 -preset slow -c:a aac $stitched 2>$null | Out-Null

  $final = Join-Path $dirs.output 'final.mp4'
  if (-not $NoAudio -and $Audio._music -and (Test-Path $Audio._music.path)) {
    & ffmpeg -y -i $stitched -i $Audio._music.path -filter_complex "[1:a]volume=0.15[bg];[0:a][bg]amix=inputs=2:duration=first" -c:v copy $final 2>$null | Out-Null
  } else {
    Copy-Item $stitched $final -Force
  }
  Write-Host "  -> $final" -ForegroundColor Green
}

# --- Orchestration ---------------------------------------------------------
$anchors = $null; $keyframes = $null; $shots = $null; $audio = $null

if ($Stage -in @('all','anchors')) { $anchors = Invoke-Anchors }
else { $anchors = Read-Checkpoint $ProjectDir 'anchors' }

if ($Stage -in @('all','keyframes')) { $keyframes = Invoke-Keyframes -Anchors $anchors }
else { $keyframes = Read-Checkpoint $ProjectDir 'keyframes' }

if (-not $NoAnimate -and $Stage -in @('all','animate')) { $shots = Invoke-Animate -Keyframes $keyframes }
else { $shots = Read-Checkpoint $ProjectDir 'shots' }

if (-not $NoAudio -and $Stage -in @('all','audio')) { $audio = Invoke-Audio -Shots $shots }
else { $audio = Read-Checkpoint $ProjectDir 'audio' }

if ($Stage -in @('all','stitch')) { Invoke-Stitch -Shots $shots -Audio $audio }

Write-Host "`nPipeline complete." -ForegroundColor Green
