# Troubleshooting

## Signed URL 403 / "Request has expired"

Signed URLs expire 1 hour after issuance. Always store the `contentId` and re-poll `GET /api/v1/generations/{contentId}` to get a fresh URL.

## Edit job: "invalid_media_url" / 403 on upload

The signed URL you passed has expired between issuance and the model's fetch. Re-issue the source by calling `GET /api/v1/generations/{contentId}` immediately before submitting the edit, or upload the binary explicitly via `POST /api/v1/uploads` (multipart).

## Character drifts every shot despite edit chain

- Verify the anchor URL is reaching the edit endpoint. Log the request body.
- Strengthen the prompt: `"Keep the exact same face, same glasses, same hair, same wardrobe."`
- Switch to `pixio/nano-banana-pro/edit` (15c) for hero shots.
- Confirm the anchor is well-lit and unobstructed.

## Aspect ratio mismatch in final mp4

Every keyframe and every animate call must request the same ratio. Re-encoding to fit later distorts. Regenerate the offending shot at the correct ratio.

## ffmpeg concat fails with "Non-monotonous DTS"

Codecs/timebases differ between shots. Re-encode with `-c:v libx264 -c:a aac` instead of `-c copy`.

## "Insufficient credits"

`GET /api/v1/credits` to check, top up via the Pixio billing page, then rerun. The pipeline is checkpointed; it resumes from the failed shot.

## Concurrency 429

Default API accounts get 1 in-flight generation. The pipeline already serializes. If you see 429, another process under the same account is competing — pause it or wait.

## A whole stage produced garbage

Each stage writes its outputs to `projects/<name>/stage-<n>/`. Delete that stage's folder, edit `config.json`, and rerun — earlier stages are untouched.
