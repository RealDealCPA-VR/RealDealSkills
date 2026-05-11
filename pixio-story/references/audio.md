# Audio stage

Image-to-video models produce silent clips. Audio is layered last.

## Components

1. **Music bed** — one long track for the whole piece (or one per scene). Generate with `pixio/elevenlabs/music/v1` or `pixio/suno/v4/text-to-music`. Specify duration in seconds.
2. **Voiceover / dialogue** — one TTS call per line, using the character's `voice_id` from the bible. `pixio/elevenlabs/tts/v1`.
3. **SFX** — one call per `sfx` entry in a shot. `pixio/elevenlabs/sound-effects/v1`.

## Recommended flow

For each shot:

1. Sum dialogue line durations into `dialogue_audio.wav`.
2. Generate `sfx_<n>.wav` for each SFX entry.
3. Mux per-shot: `ffmpeg -i shot.mp4 -i dialogue.wav -i sfx_1.wav -filter_complex amix=inputs=2 -c:v copy shot_with_audio.mp4`.

After all shots have audio: concat (see `stitching.md`), then overlay the music bed at -18 dB:

```
ffmpeg -i full_no_music.mp4 -i music.wav -filter_complex \
  "[1:a]volume=0.15[bg]; [0:a][bg]amix=inputs=2:duration=first" \
  -c:v copy final.mp4
```

## TTS gotchas

- Image-to-video models cannot match mouth shapes to your TTS audio. Use voiceover, narration, off-screen dialogue, or wide shots where lips aren't readable.
- ElevenLabs voice IDs are stable; save them in the bible. Test the voice once before generating the full episode.
- For multi-language: generate dialogue in target language, do not auto-translate at runtime.

## Music gotchas

- Suno and ElevenLabs Music generate fixed-length tracks. Request slightly longer than the video so you can trim, not stretch.
- Specify genre, instrumentation, tempo, and emotional arc. "epic" alone produces mush.

## Skip-audio mode

If the user wants a silent stylized short (mood piece, looping wallpaper), skip stage 6 entirely. The pipeline supports `--no-audio`.
