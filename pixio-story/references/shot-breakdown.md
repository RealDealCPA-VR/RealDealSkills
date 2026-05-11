# Shot breakdown rules

The goal: turn a story or premise into a `shots.json` that the pipeline can render.

## Schema

```json
{
  "project": "space-janitor",
  "logline": "A space-station janitor finds a glowing key.",
  "style": "cinematic photoreal, 35mm, anamorphic, teal-orange grade",
  "aspect_ratio": "16:9",
  "shots": [
    {
      "id": 1,
      "scene": "corridor",
      "characters": ["marlow"],
      "duration_s": 5,
      "shot_type": "wide",
      "camera": "slow dolly forward",
      "action": "Marlow pushes a mop bucket down a flickering corridor.",
      "dialogue": null,
      "sfx": ["distant alarm", "wet mop"],
      "previous_shot_continuity": null
    }
  ]
}
```

## Rules Claude must follow when generating this

1. **Each shot is one camera setup.** If the camera cuts, it's a new shot.
2. **Each shot is 3–10 seconds.** Image-to-video models stretch poorly past that; chain instead.
3. **Resolve characters** — every character mentioned in `action` must exist in `characters` and in `bible.json`.
4. **Hold style.** `style` is appended verbatim to every keyframe prompt. Do not vary it per shot.
5. **Same aspect ratio** for every shot.
6. **`previous_shot_continuity`** — if shot N continues a motion or location from shot N-1, set this to N-1's id. The pipeline will use shot N-1's last frame as shot N's keyframe input.
7. **Limit dialogue to voiceover or off-screen** unless the user accepts that lip-sync will be imperfect.
8. **Keep `action` concrete and visual.** No "feels nostalgic" — write what the camera sees.

## Pacing heuristic

- Establishing shot: 4–6s
- Action beat: 2–4s
- Dialogue beat: length of the line + 1s
- Reaction/cutaway: 1–2s
- Final hold: 5–8s

Aim for an average of ~4s per shot. A 60s short is ~15 shots.
