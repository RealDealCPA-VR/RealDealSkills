# Continuity rules

These rules are the difference between a coherent short and a slideshow of unrelated images.

## 1. Character lock

Every keyframe is an `image-to-image` edit using the character's anchor as the input image.

- Pass the anchor URL in `image_urls`.
- Prompt format: `Keep the same person. {scene action}. {camera direction}. {style suffix}.`
- Multi-character shots: edit twice (compose Character A, then edit that result passing Character B's anchor as the second reference). Models like `nano-banana-2/edit` accept multiple `image_urls`.

## 2. Style suffix

Define `style` once in `shots.json` and append it verbatim to every keyframe prompt. Examples:

- "cinematic photoreal, 35mm, anamorphic, teal-orange grade"
- "Studio Ghibli inspired anime, painterly clouds, soft pastel light"
- "graphic novel ink, halftone shading, high contrast, limited palette"

Do not paraphrase the style mid-project. Models notice.

## 3. Shot-to-shot motion continuity

If `previous_shot_continuity` is set on shot N:

1. After shot N-1 finishes animating, pull its last frame via `pixio/video-ops/last-frame`.
2. Use that frame as the input image for shot N's keyframe edit instead of the character anchor.
3. Prompt: `{scene action continuing from previous frame}. {camera direction}. {style suffix}.`

This is how to keep a character mid-action across a cut (running, falling, reaching) without the body teleporting.

## 4. Aspect ratio and resolution

- One aspect ratio for the entire project. Lock it in `config.json`.
- Anchors and keyframes at the same resolution as the target video (usually 1K, escalate hero shots to 2K).
- Image-to-video models accept their own resolutions; downscale or upscale to match the final mp4.

## 5. Lighting and time-of-day

Treat lighting as part of the style suffix when it should be consistent. When it changes (day → night), make it explicit in the scene action and accept that the model will reinterpret.

## 6. When continuity breaks

It will. Common fixes:

- Face drift → regenerate keyframe with stronger "keep the same face, glasses, hair" anchor prompt.
- Wardrobe drift → re-anchor with the wardrobe locked in.
- Aspect mismatch → never crop in-engine, regenerate at the right ratio.
- Style shift → check that the style string is byte-identical across prompts.
