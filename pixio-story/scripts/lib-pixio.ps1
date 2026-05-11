# Shared helpers for the pixio-story pipeline.
# All Pixio API calls go through these so error handling and URL refresh are consistent.

$script:PixioBase = 'https://beta.pixio.myapps.ai'

function Get-PixioHeaders {
  if (-not $env:PIXIO_API_KEY) { throw "PIXIO_API_KEY environment variable is not set." }
  return @{ Authorization = "Bearer $env:PIXIO_API_KEY"; 'Content-Type' = 'application/json' }
}

function Invoke-PixioGenerate {
  param(
    [Parameter(Mandatory)][string]$ModelId,
    [Parameter(Mandatory)][hashtable]$Params
  )
  $h = Get-PixioHeaders
  $body = @{ providerId = 'pixio'; modelId = $ModelId; params = $Params } | ConvertTo-Json -Depth 10
  $r = Invoke-RestMethod -Uri "$script:PixioBase/api/v1/generate" -Headers $h -Method Post -Body $body
  $cid = $r.contentId; if (-not $cid) { $cid = $r.id }
  return $cid
}

function Wait-PixioGeneration {
  param(
    [Parameter(Mandatory)][string]$ContentId,
    [int]$MaxSeconds = 600,
    [int]$PollSeconds = 4
  )
  $h = @{ Authorization = "Bearer $env:PIXIO_API_KEY" }
  $start = Get-Date
  while ($true) {
    Start-Sleep -Seconds $PollSeconds
    try {
      $g = Invoke-RestMethod -Uri "$script:PixioBase/api/v1/generations/$ContentId" -Headers $h -Method Get
    } catch { Start-Sleep -Seconds $PollSeconds; continue }
    if ($g.status -in @('succeeded','failed','cancelled')) { return $g }
    if ((New-TimeSpan -Start $start -End (Get-Date)).TotalSeconds -gt $MaxSeconds) { return $g }
  }
}

function Get-PixioOutputUrl {
  param([Parameter(Mandatory)]$Generation)
  if ($Generation.outputUrl) { return $Generation.outputUrl }
  if ($Generation.outputs -and $Generation.outputs.Count -gt 0) { return $Generation.outputs[0].url }
  return $null
}

function Get-FreshPixioUrl {
  # Re-fetch a generation to get a freshly signed URL.
  param([Parameter(Mandatory)][string]$ContentId)
  $h = @{ Authorization = "Bearer $env:PIXIO_API_KEY" }
  $g = Invoke-RestMethod -Uri "$script:PixioBase/api/v1/generations/$ContentId" -Headers $h -Method Get
  return Get-PixioOutputUrl $g
}

function Save-PixioMedia {
  # Download a Pixio output to a local file. Refreshes URL first.
  param(
    [Parameter(Mandatory)][string]$ContentId,
    [Parameter(Mandatory)][string]$Destination
  )
  $url = Get-FreshPixioUrl -ContentId $ContentId
  if (-not $url) { throw "No output URL for content $ContentId" }
  Invoke-WebRequest -Uri $url -OutFile $Destination -UseBasicParsing
}

function Get-PixioCredits {
  $h = @{ Authorization = "Bearer $env:PIXIO_API_KEY" }
  return Invoke-RestMethod -Uri "$script:PixioBase/api/v1/credits" -Headers $h -Method Get
}

function Write-Checkpoint {
  param(
    [Parameter(Mandatory)][string]$ProjectDir,
    [Parameter(Mandatory)][string]$StageName,
    [Parameter(Mandatory)]$Data
  )
  $path = Join-Path $ProjectDir "state-$StageName.json"
  $Data | ConvertTo-Json -Depth 20 | Out-File -Encoding utf8 $path
}

function Read-Checkpoint {
  param(
    [Parameter(Mandatory)][string]$ProjectDir,
    [Parameter(Mandatory)][string]$StageName
  )
  $path = Join-Path $ProjectDir "state-$StageName.json"
  if (Test-Path $path) { return Get-Content $path -Raw | ConvertFrom-Json }
  return $null
}
