# Prompt: story → shot list

Use this prompt verbatim (substitute the `{...}` placeholders) when generating `shots.json` from a story or premise.

---

You are a director and storyboard artist. Convert the story below into a JSON shot list that can be rendered by an image-to-video pipeline.

**Story or premise:**

{story_text}

**Target length:** {duration_seconds} seconds

**Style:** {style_string}
(Examples: "cinematic photoreal, 35mm anamorphic, teal-orange grade" / "Studio Ghibli anime, painterly clouds" / "graphic novel ink, halftone shading")

**Aspect ratio:** {aspect_ratio} (default 16:9)

**Output:** valid JSON conforming to this schema. Output ONLY the JSON, no prose.

```json
{
  "project": "kebab-case-slug",
  "logline": "single-sentence summary",
  "style": "{style_string}",
  "aspect_ratio": "{aspect_ratio}",
  "shots": [
    {
      "id": 1,
      "scene": "short location tag (e.g. corridor, rooftop, kitchen)",
      "characters": ["character_id_from_bible"],
      "duration_s": 4,
      "shot_type": "wide | medium | close | extreme-close | over-shoulder | top-down | low-angle",
      "camera": "static | slow dolly forward | pan left | tilt up | handheld | crane down | whip pan",
      "action": "concrete visual description of what happens in this shot",
      "dialogue": null,
      "sfx": ["short", "atomic", "tags"],
      "previous_shot_continuity": null
    }
  ]
}
```

**Rules:**

1. Each shot is one camera setup. If the camera cuts, it's a new shot.
2. Each shot is 3–10 seconds. Default 4.
3. Total duration of all shots ≈ {duration_seconds}. Within ±10%.
4. Use `previous_shot_continuity: <prev_id>` only when the character or motion physically continues across the cut (running, falling, reaching). Otherwise leave null.
5. Dialogue belongs in voiceover or off-screen. If the line is on-screen and lips would be visible, note it — but prefer wide shots or away-from-camera framings for spoken lines.
6. `sfx` is a flat list of short tags. The audio stage generates one SFX per tag.
7. Every character mentioned in `action` must be in the shot's `characters` array.
8. `action` is what the camera sees — no internal states, no "feels" verbs.

**Pacing:**

- Open with an establishing shot.
- Vary shot scale every 2–3 shots (wide → medium → close cycle).
- End on a held shot or a punchline beat.
