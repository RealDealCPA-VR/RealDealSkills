# Pixio Music Model Catalog (verified 2026-06-05)

All are `type: text-to-audio` unless noted. Discover the live list any time with:

```bash
curl https://beta.pixio.myapps.ai/api/v1/models \
  -H "Authorization: Bearer pxio_live_your_api_key"
```

Get exact params for one model:

```bash
curl "https://beta.pixio.myapps.ai/api/v1/params?modelId=<id>" \
  -H "Authorization: Bearer pxio_live_your_api_key"
```

## Recommended for full songs with vocals

### `pixio/minimax-music/v2.6` — 20 credits — DEFAULT, verified working
Full song with vocals from a style prompt + structured lyrics.
- `prompt` (string, **required**): style/genre/mood/instrumentation/BPM description.
- `lyrics` (string, optional): lyrics with `[verse]` / `[chorus]` / `[bridge]` tags.
- `is_instrumental` (boolean, default `false`): set `true` for no vocals (omit lyrics).
- `lyrics_optimizer` (boolean, default `false`): let the model polish phrasing/meter.
- `sample_rate` (select, default `44100`): `8000|16000|22050|24000|32000|44100`.
- `bitrate` (select, default `256000`): `32000|64000|128000|256000`.
- `format` (select, default `mp3`): `mp3|pcm|flac`.

Verified: a `prompt`+`lyrics` call succeeded and returned an `.mp3` in `outputUrl`.

### `pixio/minimax-music/v1.5` — 5 credits — budget vocal song, verified working
Same family, cheaper. Uses `prompt` + **`lyrics_prompt`** (NOT `lyrics` — different field name than v2.5/v2.6). No `is_instrumental` flag. Verified: produced a valid mp3 end-to-end.

### `pixio/minimax-music/v2.5` — 20 credits
`prompt` + `lyrics` + `is_instrumental` + `lyrics_optimizer` (same shape as v2.6).

### Lyrics field name differs by version — important
- **`lyrics`** (+ `is_instrumental`): `v2.5`, `v2.6`.
- **`lyrics_prompt`**: `v1.5`, `v2`.
- **`reference_audio_url`** (no lyrics field): base `pixio/minimax-music` "Music Reference".
Sending the wrong field 400s with `Missing required parameter: lyrics_prompt`. The helper script auto-detects via `/api/v1/params`.

### AVOID `pixio/minimax-music/v2` (5c)
Uses `prompt` + `lyrics_prompt` but fails upstream with `422 Field required (body.lyrics_prompt)` even when sent — and you're still billed. Use `v1.5` (5c) instead.

## AI-written lyrics (give only a theme)

### `pixio/mureka/music/create` — 15 credits — "Mureka Create (AI Lyrics)"
The model writes the lyrics for you.
- `prompt` (string, optional): theme + style, e.g. "an upbeat birthday song for a dog named Biscuit".
- `model` (select, default `V9`): `V9|V8|O2|V7.6|V7.5`.

### `pixio/mureka/music/create-advanced` — 20 credits
More control variant of the above; check `/params` for the extra fields.

## Instrumentals (no vocals)

### `pixio/mureka/music/create-instrumental` — 15 credits
- `prompt` (string): mood/genre/instrumentation.
- `title` (string, optional).
- `ref_id` (select) / `ref_file` (file, optional): reference an existing track.
- `model` (select, default `V9`): `V9|V8|O2|V7.6|V7.5`.

### `pixio/lyria3-pro` — 15 credits — Google Lyria 3 Pro (instrumental)
- `prompt` (string): description of the instrumental.
- `negative_prompt` (string, optional): what to avoid (e.g. "no vocals, no drums").
Siblings: `pixio/lyria2` (10c), `pixio/lyria3-clip` (5c, short clip).

### `pixio/music/compose` — 12 credits — ElevenLabs Music, length control
- `prompt` (string, optional): description. OR `composition_plan` (string) for a structured plan.
- `music_length_seconds` (number, default `30`): target duration.
- `model_id` (select, default `music_v1`): **send this — gateway treats it as required.**
- `force_instrumental` (boolean, default `false`): `true` = no vocals.
- `respect_sections_durations` (boolean, default `false`).
- `output_format` (select, default `mp3_44100_128`): many mp3/pcm/opus options.
Note: prone to wedging on flagged vocabulary — keep prompts plain (see SKILL gotchas).

### `pixio/music` — 5 credits — "Pixio Music"
Cheapest house instrumental/music model. Check `/params` before use.

## Suno-style full songs

### `pixio/songcraft/generate` — 20 credits — "Songcraft" (Suno chirp)
- `model_id` (select, **required**, default `chirp-v4`): `chirp-v5-5|chirp-v5|chirp-v4-5|chirp-v4`. Prefer `chirp-v5-5` or `chirp-v5` for quality.
- `songcraft_builder` (boolean, default `true`): when on, Pixio's builder assembles the song; additional style/lyrics fields may apply — dump `/params` and pass everything it lists.

### Songcraft ecosystem (operate on songs)
- `pixio/songcraft/cover` — 20c — cover/re-style an existing song.
- `pixio/songcraft/extend` — 20c — extend a song with more sections.
- `pixio/songcraft/concat` — 5c — "Get Full Song" (stitch sections).
- `pixio/songcraft/stems` — 40c — split into stems.
- `pixio/songcraft/all-stems` — 270c — full stem separation.
For each, `GET /api/v1/params?modelId=<id>` to see the required media inputs (these consume existing audio — upload local files via `POST /api/v1/uploads` first, or pass a public URL).

## Stable Audio (text/audio-to-audio)
- `pixio/stable-audio-25/text-to-audio` — 15c.
- `pixio/stable-audio-25/audio-to-audio` — 18c (audio-to-audio).
- `pixio/stable-audio-25/inpaint` — 18c (audio-to-audio).

## Not songs (use pixio-skill instead)
- Sound effects: `pixio/sfx` (10c) — params `text`, `duration_seconds`, `prompt_influence`.
- Text-to-speech: `pixio/text-to-speech` (8c), `pixio/minimax/speech-2.8-hd`, etc.
- Add a generated track onto a video: `pixio/video-ops/add-audio` (0c).
- Trim audio/video: `pixio/video-ops/trim` (0c).
