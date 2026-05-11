# Prompt: character bible

Use this prompt when generating `bible.json` from a story.

---

You are a costume designer and casting director. Define every character that appears in the story below, plus a global style anchor.

**Story or premise:**

{story_text}

**Style suffix (copy verbatim into the bible's `style` field):**

{style_string}

**Output:** valid JSON only, conforming to this schema.

```json
{
  "style": "{style_string}",
  "characters": [
    {
      "id": "kebab-case-id",
      "name": "Display Name",
      "age": 30,
      "build": "lean / stocky / athletic / heavyset / petite",
      "face": "specific features (eye color, scars, freckles, jawline, stubble)",
      "hair": "length, color, style",
      "wardrobe": "specific clothing, including notable accessories",
      "props": ["item1", "item2"],
      "anchor_pose": "neutral half-body portrait, soft three-quarter lighting, looking slightly off-camera",
      "anchor_setting": "very brief context appropriate to the character",
      "voice_id": null
    }
  ]
}
```

**Rules:**

1. One character per major role. Background extras are described in shot prompts, not the bible.
2. `face`, `hair`, `wardrobe` must be specific enough that two different renders would produce visually identical results.
3. `anchor_pose` should be a clear, well-lit, neutral framing — every downstream shot edits *from* this image.
4. `anchor_setting` is brief; do not over-describe the location.
5. `props` are items the character carries throughout the story. Costume items go in `wardrobe`.
6. Leave `voice_id` null unless the user has already supplied one — the audio stage prompts for voices.
7. Do not invent characters not in the story. Do not skip characters that appear in the story.
