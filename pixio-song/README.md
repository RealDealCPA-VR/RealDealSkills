# pixio-song

A Claude Code skill for generating music and full songs programmatically via the Pixio API.

It is a song-focused specialization of `pixio-skill`: same base URL, auth, `generate`, and poll endpoints, with a **verified** music model catalog, lyrics-formatting conventions, and audio-specific gotchas baked in.

## What it covers

- Full songs with vocals + your lyrics (`minimax-music/v2.6`, default)
- Songs with AI-written lyrics from a theme (`mureka/music/create`)
- Instrumentals (`mureka/.../create-instrumental`, `lyria3-pro`, `music/compose`)
- Suno-style songs (`songcraft/generate`) and cover / extend / stem-split operations
- Submit → poll → download, with the right `outputUrl` handling for audio

## Files

- `SKILL.md` — entry point: workflow, model routing table, gotchas, completion checklist.
- `references/models.md` — verified music model catalog with exact params and costs.
- `references/lyrics-format.md` — section tags (`[verse]`/`[chorus]`…) and style-prompt craft.
- `references/workflow.md` — end-to-end create→poll→download, errors, multi-section songs.
- `scripts/new-song.ps1` — self-contained PowerShell generator (auto-detects params, sanitizes text, polls, downloads).

## Quick start (PowerShell)

```powershell
.\scripts\new-song.ps1 -ApiKey $env:PIXIO_API_KEY `
  -Prompt "upbeat acoustic folk-pop, warm male vocals, 100 bpm, hopeful" `
  -Lyrics "[verse]`nMorning light on a coffee cup`n[chorus]`nWe are gonna be alright" `
  -OutFile .\song.mp3
```

Never commit or log the Pixio API key.
