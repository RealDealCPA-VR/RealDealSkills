# Cost formula

Always present this to the user before starting stage 4 (keyframes).

```
total_credits =
    (num_characters × anchor_credits)               # stage 3
  + (num_shots × keyframe_credits)                  # stage 4
  + (num_shots × animate_credits_per_clip)          # stage 5
  + (num_dialogue_lines × tts_credits)              # stage 6
  + music_credits                                   # stage 6
  + sfx_count × sfx_credits                         # stage 6
```

Example — 60-second short, 1 character, 12 shots, light dialogue, one music bed:

| Stage | Calculation | Credits |
|---|---|---|
| Anchors | 1 × 7 (Flux Pro Ultra) | 7 |
| Keyframes | 12 × 7 (Nano-Banana 2 Edit) | 84 |
| Animate | 12 × ~25 (WAN v2.7 image-to-video, varies) | ~300 |
| TTS | 8 lines × ~2 (ElevenLabs) | ~16 |
| Music | 1 × ~30 | ~30 |
| **Total** | | **~440** |

Always **fetch live credit costs** with `GET /api/v1/models` at the start of a project — Pixio prices change. Anchor those numbers into the project's `config.json` so re-runs are reproducible.

## Saving money

- Drop animate stage entirely → an illustrated story (slideshow with TTS).
- Use `seedream/v4.5/edit` (5c) instead of nano-banana-2 (7c) for non-hero shots.
- Render anchors at 1K, hero keyframes at 2K, b-roll at 1K.
- Reuse one keyframe across multiple short clips with different camera moves rather than regenerating each angle.
