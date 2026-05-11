---
name: pixio-story
description: Produce movies, TV shows, animated shorts, and illustrated stories end-to-end with the Pixio API. Orchestrates script breakdown, character anchors, keyframes, image-to-video chaining, audio, and final stitching. Trigger when the user wants a multi-shot video, animated story, comic, music video, trailer, episode, or any narrative output that requires consistent characters across many scenes.
---

# Pixio Story Workflow

Produces narrative video or illustrated stories end-to-end through Pixio. Always uses the `pixio-skill` (or its API reference docs) as the underlying tool layer — this skill is the director, `pixio-skill` is the camera and crew.

## Hard requirements

- A valid Pixio API key in `PIXIO_API_KEY` (or ask the user).
- PowerShell on Windows or bash + curl on Unix. Pipeline scripts ship in PowerShell; port to bash if needed.
- `ffmpeg` on PATH for stitching and audio mux (final stage only).

## The 6-stage pipeline

Run stages strictly in order. Each stage writes its outputs to a project folder under `./projects/<project-name>/` so the pipeline is resumable and inspectable.

```
1. plan       — story → outline → shot list (JSON)
2. bible      — character + style reference sheet
3. anchors    — one locked image per character (text-to-image)
4. keyframes  — per-shot still using anchor + scene prompt (image-to-image edit)
5. animate    — per-shot 5–10s clip from keyframe (image-to-video)
6. assemble   — TTS, music, SFX, ffmpeg concat → final mp4
```

Stages 4 and 5 are the cost drivers. Encourage the user to run stage 1–3 first, review, then commit to 4–6.

## Default model picks

Read `references/model-picks.md` for the full matrix and the reasoning. Defaults baked into the pipeline:

- Anchors (text-to-image, photoreal): `pixio/flux-pro/v1.1-ultra` (7c)
- Anchors (anime/stylized): `pixio/gpt-image-1.5` (6c) or `pixio/imagen4/ultra` (6c)
- Keyframes (character lock + scene compose): `pixio/nano-banana-2/edit` (7c)
- Animate (image-to-video): `pixio/wan/v2.7/image-to-video` or `pixio/kling-video/v2.5/standard/image-to-video` (check current credits)
- Add audio to clip: `pixio/video-ops/add-audio` (0c — combines tracks only)

Switch models per-project by editing the project's `config.json` (see `examples/example-story.json`).

## Protocol

When invoked:

1. **Detect intent** — confirm output type (short film, episode, illustrated story, music video, trailer) and approximate length. Length × ~5s/shot ≈ shot count.
2. **Cost preview** — estimate credits before any generation. Formula in `references/cost-formula.md`.
3. **Run stage 1 (plan)** — use `prompts/story-to-shotlist.md` to produce `shots.json`. Show the user the plan and pause for approval.
4. **Run stage 2 (bible)** — use `prompts/character-bible.md` to produce `bible.json`. Pause for approval if any character will appear in more than 3 shots.
5. **Run stages 3–6** — invoke `scripts/pipeline.ps1` with the project folder. The script is resumable; if a stage fails midway it picks up from the last successful checkpoint.
6. **Always save** generation `contentId`s so URLs can be refreshed (signed URLs expire in 1 hour — re-poll `/api/v1/generations/{id}` to get fresh ones).

## Continuity rules

These are non-negotiable for coherent output. Detailed in `references/continuity.md`:

- One **anchor image per character.** Every keyframe edits *from* that anchor.
- **Same anchor + same style suffix** appended to every prompt.
- **Last frame of clip N** is the input to keyframe N+1 (for shot-to-shot motion continuity within a scene).
- **Same aspect ratio** for the entire project. Set once in `config.json`.

## Audio stage

`references/audio.md` covers TTS (per-character voice IDs), music generation, and SFX. The image-to-video models generate silent clips; audio is layered last with ffmpeg or Pixio's `add-audio` op.

## Output

Final deliverables in `./projects/<name>/output/`:

- `final.mp4` — full assembly with audio
- `shots/` — individual clips
- `keyframes/` — stills (also usable for storyboards, posters, thumbnails)
- `bible.json` + `shots.json` — source of truth, edit and rerun any stage

## Sharing this skill

`references/sharing.md` documents how to zip + send, publish to a marketplace, or import on a teammate's machine.

## When NOT to use

- Single-image generations — use `pixio-skill` directly.
- Live-action editing of a user-supplied video — use `pixio/video-ops/*` directly.
- Anything that needs frame-exact lipsync — current image-to-video models can't hold mouth shapes to a TTS track reliably. Note this limitation to the user up front.
