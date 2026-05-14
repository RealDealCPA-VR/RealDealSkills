# Guide — Video Ads (Opt-In)

**Only load this guide if the user explicitly asked for video.** Video burns 5–20x the credits of a single image, takes longer to generate, and is harder to iterate on. Confirm scope before starting.

## Confirm Scope First

Before any generation, get answers to:

1. **How many video ads?** (Default: 1.)
2. **Duration?** (Default: 5 seconds. Most pixio text-to-video models support 5 or 10s, some go to 15s. Check the model's `/api/v1/params` for the `duration` select values.)
3. **Aspect ratio?** (9:16 for stories/reels, 1:1 for feed, 16:9 for YouTube/web — confirm which platform.)
4. **With or without audio?** (Audio is a separate generation step — see "Adding Audio" below.)
5. **Image-to-video or text-to-video?** Image-to-video uses an approved still as the first frame (more on-brand, more controllable). Text-to-video is open-ended (more creative, less controllable). **Default to image-to-video** when there's already an approved hero shot.

Show the credit estimate before generating: *"This will be ~{N} credits and take ~{M} minutes. Confirm to proceed?"*

## Image-To-Video Workflow (Preferred)

1. Pick an approved still from earlier deliverables (logo, social post, or hero banner) as the first frame.
2. Write a short motion prompt: what should happen in the 5 seconds? Keep it to one or two beats. Example: *"Camera slowly pushes in toward the kettle as steam rises and curls upward."*
3. Invoke `pixio-skill` with:
   - **Intent:** image-to-video
   - **Aspect ratio:** matching the source image (or whatever the model accepts)
   - **Prompt:** the motion prompt only — the brand system prefix is already baked into the source image
   - **Reference image:** the approved still's URL
   - **Duration:** as confirmed (remember: pass `duration` as a **string**, not a number, for select-type params — see [[pixio_api_quirks]])

## Text-To-Video Workflow

Use only when no suitable still exists or the user wants something new.

Prompt skeleton:

```
{BRAND_SYSTEM_PREFIX}

{ONE-SENTENCE SCENE}. Camera: {static | slow push-in | slow pan}. Lighting matches brand vibe. Single continuous shot, no cuts.
```

Keep the scene description to one sentence. Multi-action prompts confuse text-to-video models.

## Adding Audio (Optional)

If the user wants sound:

1. Generate the silent video first.
2. Invoke `pixio-skill` again with intent `add-audio-to-video`, passing the silent video and an audio prompt (e.g., *"Calm acoustic guitar with subtle ambient kitchen sounds"*).
3. **Critical:** per [[pixio_api_quirks]], `pixio/video-ops/add-audio` rejects signed Pixio URLs. Use the bare filePath (`users/<uuid>/generated-content/<contentId>.<ext>`). Pixio-skill knows how to handle this — let it.

## Presenting Results

```
Video ad ({duration}s, {aspect}): [url]
```

Plus a one-line description of what happens in the clip.

## Anti-Patterns

- Do not generate multiple video variants on the first pass. Generate one, get feedback, iterate.
- Do not write complex multi-action prompts. Models will produce mush.
- Do not bake voiceover or spoken text into the video — current models can't render legible speech. Use add-audio for music/SFX only, then suggest the user add VO separately.
- Do not pad duration. A focused 5s beats a meandering 15s for ads.
