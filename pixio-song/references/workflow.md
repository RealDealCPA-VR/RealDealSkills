# End-to-End Song Workflow

## 1. Create the generation

```bash
curl -s -X POST https://beta.pixio.myapps.ai/api/v1/generate \
  -H "Authorization: Bearer pxio_live_your_api_key" \
  -H "Content-Type: application/json" \
  -d '{
    "providerId": "pixio",
    "modelId": "pixio/minimax-music/v2.6",
    "params": {
      "prompt": "upbeat acoustic folk-pop, warm male vocals, claps, 100 bpm, hopeful",
      "lyrics": "[verse]\nMorning light on a coffee cup\n[chorus]\nWe are gonna be alright\nWe are gonna be alright"
    }
  }'
```

Response — save `contentId`:

```json
{
  "success": true,
  "message": "Generation started successfully!",
  "contentId": "00000000-0000-0000-0000-000000000000",
  "providerId": "pixio",
  "modelId": "pixio/minimax-music/v2.6"
}
```

## 2. Poll until final

```bash
curl -s "https://beta.pixio.myapps.ai/api/v1/generations/<contentId>" \
  -H "Authorization: Bearer pxio_live_your_api_key"
```

Poll every 5–6 seconds. Song gens usually finish in well under a minute but can take a few minutes.

Final success (note `outputs` is `null` for music — the mp3 is in `outputUrl`):

```json
{
  "id": "00000000-...",
  "status": "succeeded",
  "type": "audio",
  "modelId": "pixio/minimax-music/v2.6",
  "outputUrl": "https://pixio-v2.nyc3.digitaloceanspaces.com/.../<id>.mp3?X-Amz-Expires=3600&...",
  "outputs": null,
  "creditsCost": 20,
  "error": null
}
```

Failure example (still billed):

```json
{ "status": "failed", "creditsCost": 5, "error": "Unexpected status code: 422: Field required (body.lyrics_prompt)" }
```

## 3. Return / download

`outputUrl` is signed and **expires in ~1 hour**. Download it promptly:

```bash
curl -s -o song.mp3 "<outputUrl>"
```

Re-fetching the generation after expiry returns the same dead URL — there is no refresh; you'd have to re-generate.

## Polling pseudo-code

```text
gen = POST /api/v1/generate          # save gen.contentId
loop:
  r = GET /api/v1/generations/{contentId}
  if r.status == "succeeded": return r.outputUrl      # the mp3
  if r.status == "failed":    return r.error
  wait 5-6 seconds
```

## Error handling

- `401` — missing/invalid key. Body: `{"error":"Missing API key..."}`.
- `402` — insufficient credits. Body includes `availableCredits`, `requiredCredits`, `shortfall`.
- `404` — `{"error":"Pixio API model not found"}` — re-check the ID via `GET /api/v1/models`.
- `429` — concurrency limit (account-wide cap 3; default accounts 1 in-flight). Wait for the running gen to finish, then retry with backoff.
- `400 Missing required parameter: X` — gateway treats an "optional with default" param as required. Resend every non-empty `/params` field at its default.
- PowerShell hides 4xx/5xx bodies behind a generic error — read the response stream (the helper script does this) to see the real message.

## Multi-section / longer songs

- Generate a base song, then **`pixio/songcraft/extend`** to add sections, and **`pixio/songcraft/concat`** ("Get Full Song") to stitch. These consume existing audio — pass the prior `outputUrl` (within its 1h window) or upload the mp3 via `POST /api/v1/uploads` first and pass the returned `filePath` (filePaths don't expire).
- For a fixed duration, use **`pixio/music/compose`** with `music_length_seconds`.

## Adding the song to a video

If the user wants the track under a video, hand off to `pixio-skill`'s `pixio/video-ops/add-audio` (0c). Note that endpoint rejects signed Pixio URLs with a 403 — pass the bare `filePath`, not the signed `outputUrl`.

## Uploading reference audio

For covers, extends, or instrumental references that take a `ref_file`/media input, upload first:

```bash
curl -s -X POST https://beta.pixio.myapps.ai/api/v1/uploads \
  -H "Authorization: Bearer pxio_live_your_api_key" \
  -F "file=@./reference.mp3"
```

Use the returned `filePath` (stable) or `url` (signed, 1h) in the model's media param per `/api/v1/params`.
