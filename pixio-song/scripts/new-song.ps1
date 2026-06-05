<#
.SYNOPSIS
  Create a song with the Pixio API: submit, poll, and (optionally) download the mp3.

.DESCRIPTION
  Self-contained generator for the pixio-song skill. Handles PowerShell 5.1's hidden
  4xx/5xx response bodies, sanitizes unicode dashes, and returns the signed mp3 URL
  (which expires ~1h after generation).

.EXAMPLE
  .\new-song.ps1 -ApiKey $env:PIXIO_API_KEY `
    -Prompt "upbeat acoustic folk-pop, warm male vocals, 100 bpm, hopeful" `
    -Lyrics "[verse]`nMorning light on a coffee cup`n[chorus]`nWe are gonna be alright" `
    -OutFile .\song.mp3

.EXAMPLE
  # Instrumental, no lyrics
  .\new-song.ps1 -ApiKey $key -Prompt "lofi chillhop, rain, mellow piano" -Instrumental

.EXAMPLE
  # Let the model write the lyrics from a theme
  .\new-song.ps1 -ApiKey $key -ModelId "pixio/mureka/music/create" -Prompt "a cheerful birthday song for a dog named Biscuit"
#>
param(
  [Parameter(Mandatory=$true)][string]$ApiKey,
  [Parameter(Mandatory=$true)][string]$Prompt,
  [string]$Lyrics = "",
  [string]$ModelId = "pixio/minimax-music/v2.6",
  [switch]$Instrumental,
  [string]$OutFile = "",
  [int]$PollSeconds = 6,
  [int]$MaxWaitSeconds = 600
)

$ErrorActionPreference = "Stop"
$Base = "https://beta.pixio.myapps.ai"
$Headers = @{ Authorization = "Bearer $ApiKey" }

# --- sanitize: em/en dashes 500 the gateway on some models ---
function Convert-CleanText([string]$s) {
  if ($null -eq $s) { return "" }
  return ($s -replace [char]0x2014, '-' -replace [char]0x2013, '-' `
             -replace [char]0x2018, "'" -replace [char]0x2019, "'" `
             -replace [char]0x201C, '"' -replace [char]0x201D, '"' `
             -replace [char]0x2026, '...')
}

# --- REST helper that surfaces the real error body (PS 5.1 hides it) ---
function Invoke-Pixio {
  param([string]$Method, [string]$Url, [object]$Body)
  try {
    if ($Body) {
      $json = ($Body | ConvertTo-Json -Depth 12 -Compress)
      return Invoke-RestMethod -Method $Method -Uri $Url -Headers $Headers `
                               -ContentType "application/json" -Body $json
    }
    return Invoke-RestMethod -Method $Method -Uri $Url -Headers $Headers
  } catch {
    $resp = $_.Exception.Response
    if ($resp) {
      $reader = New-Object System.IO.StreamReader($resp.GetResponseStream())
      $detail = $reader.ReadToEnd()
      throw "Pixio $($resp.StatusCode.value__): $detail"
    }
    throw
  }
}

$Prompt = Convert-CleanText $Prompt
$Lyrics = Convert-CleanText $Lyrics

# --- discover the model's accepted param names so we use the right lyrics field ---
# (minimax v2.5/v2.6 use "lyrics" + is_instrumental; v1.5 uses "lyrics_prompt"; etc.)
$names = @()
try {
  $pinfo = Invoke-Pixio -Method GET -Url "$Base/api/v1/params?modelId=$ModelId"
  $names = @($pinfo.params | ForEach-Object { $_.name })
} catch {
  Write-Host "  (could not fetch /params, using defaults): $_" -ForegroundColor DarkYellow
}
function Has($n) { return ($names -contains $n) }

# --- build params, matching whatever the model actually accepts ---
$params = @{ prompt = $Prompt }
if (Has 'model_id')          { $params.model_id = "music_v1" }   # music/compose: required-by-quirk

if ($Instrumental) {
  if     (Has 'is_instrumental')    { $params.is_instrumental = $true }
  elseif (Has 'force_instrumental') { $params.force_instrumental = $true }
} elseif ($Lyrics) {
  if     (Has 'lyrics')        { $params.lyrics = $Lyrics }
  elseif (Has 'lyrics_prompt') { $params.lyrics_prompt = $Lyrics }
  # models with neither (e.g. mureka/create) write their own lyrics from the prompt
}

$body = @{ providerId = "pixio"; modelId = $ModelId; params = $params }

Write-Host "Submitting $ModelId ..." -ForegroundColor Cyan
$gen = Invoke-Pixio -Method POST -Url "$Base/api/v1/generate" -Body $body
$id = $gen.contentId
if (-not $id) { throw "No contentId returned: $($gen | ConvertTo-Json -Compress)" }
Write-Host "contentId: $id" -ForegroundColor DarkGray

# --- poll ---
$deadline = (Get-Date).AddSeconds($MaxWaitSeconds)
while ((Get-Date) -lt $deadline) {
  Start-Sleep -Seconds $PollSeconds
  $r = Invoke-Pixio -Method GET -Url "$Base/api/v1/generations/$id"
  Write-Host ("  status: {0}" -f $r.status) -ForegroundColor DarkGray
  if ($r.status -eq "succeeded") {
    $url = $r.outputUrl   # music output lands here; outputs is null
    Write-Host "DONE ($($r.creditsCost) credits): $url" -ForegroundColor Green
    if ($OutFile) {
      Invoke-WebRequest -Uri $url -OutFile $OutFile
      Write-Host "Saved -> $OutFile" -ForegroundColor Green
    }
    Write-Output $url
    return
  }
  if ($r.status -eq "failed") {
    throw "Generation failed ($($r.creditsCost) credits): $($r.error)"
  }
}
throw "Timed out after ${MaxWaitSeconds}s; gen $id may still be processing (occupies a concurrency slot)."
