# Character bible

The bible is the single source of truth for character appearance. Every character is rendered once into an anchor image, and every shot keyframe is an edit *from* that anchor.

## Schema

```json
{
  "style": "cinematic photoreal, 35mm anamorphic, teal-orange grade, soft volumetric light",
  "characters": [
    {
      "id": "marlow",
      "name": "Marlow",
      "age": 42,
      "build": "lean, slightly hunched",
      "face": "tired hazel eyes, two-week stubble, faint scar across left brow",
      "hair": "short salt-and-pepper",
      "wardrobe": "stained gray jumpsuit, name patch reads MARLOW, scuffed work boots",
      "props": ["a mop", "a battered keyring on his belt"],
      "anchor_pose": "neutral half-body portrait, soft three-quarter lighting, looking slightly off-camera",
      "anchor_setting": "industrial corridor with flickering fluorescent",
      "voice_id": "elevenlabs_voice_id_here"
    }
  ]
}
```

## Anchor prompt construction

```
{wardrobe}, {face}, {hair}, {build}, {props}.
{anchor_pose}.
{anchor_setting}.
{style}
```

That single sentence is the anchor prompt. Use it once per character, save the contentId and outputUrl, and never regenerate unless the character design itself changes.

## Rules

1. **One anchor per character.** Multi-character scenes still edit from each character's individual anchor, composed via the keyframe prompt.
2. **Anchor must be a clear, well-lit, neutral pose.** Extreme angles or heavy shadow in the anchor poison every downstream edit.
3. **Wardrobe in the anchor is the wardrobe for the whole project** — unless the story explicitly changes it, and then you generate a *new* anchor for the new wardrobe.
4. **No camera direction in the anchor prompt.** Save "low angle / dolly / dutch tilt" for keyframe prompts.
5. **Voice IDs** are optional in the bible; required only if the story has dialogue.
