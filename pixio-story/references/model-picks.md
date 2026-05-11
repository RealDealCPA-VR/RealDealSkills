# Model picks by stage

All IDs are public `pixio/...` IDs. Verify availability and current credit cost at runtime with `GET /api/v1/models`.

## Anchors (one-time, text-to-image)

| Style | Model | Credits | Notes |
|---|---|---|---|
| Photoreal | `pixio/flux-pro/v1.1-ultra` | 7 | Default for live-action looks. |
| Photoreal premium | `pixio/flux-2-pro` | 10 | Use when prompts are complex (multi-character compositions). |
| Anime | `pixio/gpt-image-1.5` | 6 | Best prompt adherence for stylized characters. |
| Anime cheap | `pixio/flux-lora` | 3 | Acceptable, less coherent on detailed costumes. |
| Cinematic mid-budget | `pixio/imagen4/ultra` | 6 | Strong on natural lighting, scenes. |
| Stylized illustration | `pixio/recraft/v3/text-to-image` | 8 | Vector-leaning, posters and comics. |

## Keyframes (per-shot, image-to-image edit, character lock)

| Model | Credits | When |
|---|---|---|
| `pixio/nano-banana-2/edit` | 7 | **Default.** Best identity retention across angle/wardrobe changes. |
| `pixio/nano-banana-pro/edit` | 15 | Premium quality. Use for hero shots only. |
| `pixio/bytedance/seedream/v4.5/edit` | 5 | Cheap and adequate when budget matters more than fidelity. |
| `pixio/flux-pro/kontext/max` | 8 | Excellent at scene-only edits; weaker on subtle face details. |
| `pixio/qwen-image-2/edit` | 5 | Reasonable fallback. |

## Animate (image-to-video)

Call `GET /api/v1/params?modelId=...` before using — frame counts, max duration, and credits vary. Typical defaults from the Pixio catalog:

| Model | Notes |
|---|---|
| `pixio/wan/v2.7/image-to-video` | High motion fidelity; longer clips. |
| `pixio/kling-video/v2.5/standard/image-to-video` | Strong motion coherence on character action. |
| `pixio/bytedance/seedance/v1/pro/image-to-video` | Cinematic motion blur; good for transitions. |
| `pixio/minimax/hailuo-02/image-to-video` | Cheap fallback. |

Rule of thumb: pick one model and stick with it for the entire project to keep motion style consistent.

## Audio

| Need | Model |
|---|---|
| Music generation | `pixio/elevenlabs/music/v1` or `pixio/suno/v4/text-to-music` |
| Voiceover/TTS | `pixio/elevenlabs/tts/v1` (multi-voice) |
| SFX | `pixio/elevenlabs/sound-effects/v1` |
| Add audio to video | `pixio/video-ops/add-audio` (0c, mix/replace only) |

## Video utilities

- `pixio/video-ops/first-frame` — extract opening frame
- `pixio/video-ops/last-frame` — extract closing frame (use for shot-to-shot continuity)
- `pixio/video-ops/specific-frame` — pull arbitrary frame for retakes
