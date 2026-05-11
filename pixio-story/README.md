# pixio-story

A Claude Code skill that turns a story or script into a finished video (or illustrated comic) using the Pixio API. Orchestrates breakdown, character locking, image-to-video animation, and audio assembly.

## Install

Drop this folder into `~/.claude/skills/` (or `%USERPROFILE%\.claude\skills\` on Windows). Restart Claude Code so the skill is picked up. The skill will auto-trigger when a user asks Claude to build a video, episode, animated story, or music video.

Manual invocation: `/pixio-story` (or `Skill: pixio-story`).

## Requirements

- A Pixio API key in `$env:PIXIO_API_KEY` (Windows User scope) or `PIXIO_API_KEY` shell env (Unix).
- `ffmpeg` on PATH (final stitch stage only).
- The `pixio-skill` skill installed in the same Claude environment — `pixio-story` defers all API mechanics to it.

## Quick start

```
You: Make a 60-second sci-fi short about a janitor on a space station who finds a glowing key.
Claude: [invokes pixio-story]
        → drafts shotlist (12 shots × 5s)
        → drafts character bible (1 character: Marlow, the janitor)
        → estimates cost (~280 credits image + ~180 video + audio)
        → asks for approval
You: go
Claude: [runs scripts/pipeline.ps1 — anchors, keyframes, animate, audio, stitch]
        → ./projects/space-janitor/output/final.mp4
```

## Layout

```
SKILL.md                — the workflow protocol Claude reads on invocation
README.md               — this file (human-readable)
references/             — load-on-demand docs (model picks, continuity, costs, audio, sharing)
prompts/                — LLM prompt templates (shotlist, character bible)
scripts/                — PowerShell pipeline (resumable, checkpointed)
examples/               — sample story.json input + a tiny end-to-end run
```

## Sharing

See `references/sharing.md`. Short version: zip the `pixio-story/` folder and your teammate drops it into their `~/.claude/skills/` folder. Their Pixio key is theirs — no secrets travel with the skill.

## Caveats

- Character consistency relies on image-to-image edits against a single anchor. Drift still happens at extreme angles or wide shots. Plan close-ups for emotional beats.
- Image-to-video models cannot lip-sync to TTS. Voiceover and over-the-shoulder dialogue work; talking-head shots do not.
- Signed Pixio URLs expire in 1 hour. The pipeline records `contentId`s so URLs can be refreshed at any time.
