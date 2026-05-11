# Sharing this skill

The skill is a plain folder. Sharing is just file transfer.

## Option 1: zip and send

```
# Windows PowerShell
Compress-Archive -Path "$env:USERPROFILE\.claude\skills\pixio-story" -DestinationPath pixio-story.zip
```

The recipient extracts into their own `~/.claude/skills/` (or `%USERPROFILE%\.claude\skills\`) and restarts Claude Code.

## Option 2: git repo

```
cd ~/.claude/skills/pixio-story
git init && git add . && git commit -m "initial: pixio-story skill"
gh repo create pixio-story --public --source=. --push
```

Teammates clone into `~/.claude/skills/pixio-story` and pull to get updates.

## Option 3: plugin / marketplace

Wrap the skill in a Claude Code plugin so it can be installed via `/plugin install`:

```
pixio-story-plugin/
  plugin.json
  skills/
    pixio-story/    ← (this folder)
```

Minimal `plugin.json`:

```json
{
  "name": "pixio-story",
  "version": "0.1.0",
  "description": "Story-to-video pipeline on Pixio",
  "skills": ["skills/pixio-story"]
}
```

Publish to your team's marketplace or to a public marketplace per Claude Code plugin docs.

## Secrets hygiene

- No API keys live in this skill. The pipeline reads `$env:PIXIO_API_KEY` at runtime.
- `projects/` folders contain generated outputs and shot lists, not credentials. Safe to commit if you want to share renders, but `.gitignore` them by default to avoid leaking unreleased work.

## Updating

When updating the skill, bump a `version` line at the top of `SKILL.md` (optional but useful):

```
---
name: pixio-story
version: 0.2.0
description: ...
---
```

Teammates re-pull / re-extract. Skills load on Claude Code startup; no separate install step.

## Forking

This skill is designed to be forked. Common forks:

- **`pixio-comic`** — strip stages 5 and 6 (animate, audio), output a paneled PDF.
- **`pixio-music-video`** — replace stage 2 with a beat-detection step on a user-supplied audio file, then key shots to beats.
- **`pixio-trailer`** — fixed 60s structure, hard-coded pacing template, large title cards.

Keep `pixio-skill` as the underlying API layer in all forks.
