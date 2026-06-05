---
name: pixio-song
description: Use this skill when a user wants to programmatically create music or a song — full songs with vocals and lyrics, instrumentals, AI-written lyrics, covers, song extensions, or stem separation — using the Pixio API from an agent, backend, script, automation, or CLI. Trigger for "make a song", "generate music", "write me a song", "compose a track", "create a jingle/theme/anthem", "instrumental background music", "cover song", "extend my song", "split stems", or any Pixio music/audio-generation request. Do not use for sound effects only (use pixio-skill `pixio/sfx`), text-to-speech, or non-Pixio music APIs.
---

# Pixio Song Skill

Generate music and full songs programmatically through the Pixio API. This skill is a song-focused specialization of `pixio-skill` — the same auth, generate, and poll endpoints, with a verified music model catalog, lyrics-formatting conventions, and audio-specific gotchas.

Base URL:

```text
https://beta.pixio.myapps.ai
```

Auth header (never expose this key in client code, public repos, or logs):

```http
Authorization: Bearer pxio_live_your_api_key
```

## Core Workflow

1. Get the user's **brief**: style/genre/mood, whether it has **vocals or is instrumental**, and lyrics (provided, AI-written, or themed).
2. **Pick a model** (see Model Routing below). Don't invent IDs — these are verified against the live catalog, but re-check with `GET /api/v1/models` if a call 404s.
3. Optionally `GET /api/v1/params?modelId=...` to confirm the param shape for that model.
4. **Craft the inputs**: a `prompt` describing the sound, and (for vocal models) structured `lyrics` (see `references/lyrics-format.md`).
5. `POST /api/v1/generate` with `providerId: "pixio"`. Save `contentId`.
6. Poll `GET /api/v1/generations/{id}` until `succeeded` or `failed`.
7. Return **`outputUrl`** — for music this is the `.mp3` (see Audio Gotchas; `outputs` is usually `null`).

The ready-made helper does all of this: `scripts/new-song.ps1` (Windows/PowerShell on this machine).

## Model Routing

Pick by what the user wants. Costs are credits per generation (verified 2026-06-05).

| Want | Model | Credits | Key params |
|------|-------|--------:|-----------|
| **Full song, vocals + your lyrics** (default) | `pixio/minimax-music/v2.6` | 20 | `prompt` (style), `lyrics`, `is_instrumental` |
| Cheaper vocal song | `pixio/minimax-music/v1.5` | 5 | `prompt`, `lyrics_prompt` (note: not `lyrics`) |
| **Song with AI-written lyrics** (just give a theme) | `pixio/mureka/music/create` | 15 | `prompt`, `model` (V9 default) |
| **Instrumental** (no vocals), prompt-driven | `pixio/mureka/music/create-instrumental` | 15 | `prompt`, `title`, `model` |
| Instrumental, Google Lyria | `pixio/lyria3-pro` | 15 | `prompt`, `negative_prompt` |
| Background/scored music, length control | `pixio/music/compose` | 12 | `prompt` or `composition_plan`, `music_length_seconds`, `force_instrumental` |
| **Suno-style full song** (chirp v5) | `pixio/songcraft/generate` | 20 | `model_id` (`chirp-v5-5`…), `songcraft_builder` |
| Cover an existing song | `pixio/songcraft/cover` | 20 | see `/params` |
| Extend an existing song | `pixio/songcraft/extend` | 20 | see `/params` |
| Split a song into stems | `pixio/songcraft/stems` (40) / `all-stems` (270) | 40/270 | see `/params` |

When in doubt for "make me a song," use **`pixio/minimax-music/v2.6`** — it is verified working end-to-end with a style prompt + structured lyrics. Full catalog and exact params: `references/models.md`.

## Minimum Request Shape

```json
{
  "providerId": "pixio",
  "modelId": "pixio/minimax-music/v2.6",
  "params": {
    "prompt": "upbeat acoustic folk-pop, warm male vocals, claps, 100 bpm, hopeful",
    "lyrics": "[verse]\nMorning light on a coffee cup\nA brand new day is waking up\n[chorus]\nWe are gonna be alright\nWe are gonna be alright"
  }
}
```

For an **instrumental**, either use an instrumental model or set `"is_instrumental": true` (minimax) / `"force_instrumental": true` (music/compose) and omit lyrics.

## Audio Gotchas (verified)

- **Music output is in `outputUrl`, not `outputs`.** For music gens `outputs` is `null` and `outputUrl` is the `.mp3`. Don't look for `outputs.audioUrl` — return `outputUrl`.
- **`outputUrl` is a signed URL that expires in ~1 hour** (`X-Amz-Expires=3600`). Download or hand it off promptly; re-fetching the generation returns the *same* dead URL after expiry — re-generation or re-upload is the only refresh.
- **`pixio/minimax-music/v2` (5c) is broken** — its `lyrics_prompt` param fails upstream with `422 Field required (body.lyrics_prompt)` even when sent, and you're still billed. Use `v1.5` (5c) or `v2.6` (20c) instead.
- **`pixio/music/compose` can wedge on flagged lyrics/prompt vocabulary** — genre-trigger words (`thriller`, `noir`, `predator*`), violent-film references (`John Wick`, `Heat`), or horror signifiers can leave the gen stuck at `processing` indefinitely, occupying a concurrency slot. Sanitize prompts/lyrics; prefer plain descriptive language.
- **Sanitize unicode punctuation in prompts/lyrics.** Em-dash (`—`, U+2014) can 500 the gateway on some models; replace `—`/`–` with `-` and normalize curly quotes/ellipsis before sending.
- **Account-wide concurrency cap is 3** (across all API keys), and **default accounts get 1 in-flight API generation** (Maker 3). A song gen can take 30s–several minutes; poll at 5–6s intervals and don't fire a second job until the first finishes on a default account.
- **"Optional with default" can be required by the gateway.** If a music model 400s with `Missing required parameter: <name>`, resend every non-empty param from `/api/v1/params` at its default. Known: `music/compose` needs `model_id` (`music_v1`); `songcraft/generate` needs `model_id`.

## Gotchas (general, inherited from pixio-skill)

- Never expose the API key in browser/client-side code, public repos, examples, or logs.
- Always send `providerId: "pixio"`.
- API generations spend the same Pixio credits and share history with the web app. Check balance with `GET /api/v1/credits`.
- Handle `401` (bad key), `402` (insufficient credits, returns shortfall), `404` (unknown model), `429` (concurrency). PowerShell hides 4xx bodies — read the response stream to see the real error (the helper script does this).

## Reference Routing

- `references/models.md` — verified music model catalog with exact params, costs, and notes.
- `references/lyrics-format.md` — song-structure tags (`[verse]`, `[chorus]`, `[bridge]`…) and how to write effective style prompts.
- `references/workflow.md` — end-to-end create→poll flow, audio specifics, error handling, multi-section songs.
- `scripts/new-song.ps1` — self-contained PowerShell generator (create + poll + download).

For anything beyond songs (images, video, SFX, TTS, uploads), defer to the `pixio-skill` references.

## Completion Checklist

Before reporting a song is ready:

- Model ID is from the verified catalog or `/api/v1/models`.
- Vocals vs instrumental matches the user's intent (`is_instrumental` / `force_instrumental` set correctly).
- Lyrics use section tags if the model supports them.
- Prompt/lyrics sanitized of em-dashes and flagged vocabulary.
- `contentId` saved and polling implemented.
- Returned the `outputUrl` mp3, and warned it expires in ~1 hour.
- Errors `401/402/404/429` handled.
