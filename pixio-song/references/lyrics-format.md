# Writing Lyrics and Style Prompts

Two inputs drive vocal song quality: the **style prompt** (how it sounds) and the **lyrics** (what is sung). They are separate fields — don't put style words inside the lyrics or lyrics inside the style prompt.

## Style prompt

A comma-separated description of sound, not a sentence. Cover as many of these as you can:

- **Genre/subgenre**: "indie folk-pop", "90s boom-bap hip-hop", "synthwave", "orchestral cinematic".
- **Mood/energy**: "hopeful", "melancholic", "anthemic", "laid-back".
- **Vocals**: "warm male vocals", "breathy female vocals", "group gang vocals", "no vocals" (or use the instrumental flag).
- **Instrumentation**: "acoustic guitar, claps, upright bass", "808s, hi-hats", "lush strings, piano".
- **Tempo**: "100 bpm", "slow ballad", "uptempo".
- **Production**: "lo-fi tape warmth", "polished radio mix", "live room reverb".

Example:
```text
upbeat acoustic folk-pop, warm male vocals, claps, upright bass, 100 bpm, hopeful, polished radio mix
```

## Lyrics with section tags

Vocal models (minimax-music, songcraft) respect bracketed **section tags**. Put each tag on its own line, lyrics below it, blank line between sections. Supported tags (common across the catalog):

```text
[intro]
[verse]
[pre-chorus]
[chorus]
[post-chorus]
[bridge]
[hook]
[outro]
```

Example `lyrics` value (note `\n` newlines when embedding in JSON):

```text
[verse]
Morning light on a coffee cup
A brand new day is waking up
[pre-chorus]
And I can feel it in my chest
[chorus]
We are gonna be alright
We are gonna be alright
[bridge]
Even when the road gets long
We carry every word of this song
[chorus]
We are gonna be alright
```

In JSON, the same value:
```json
"lyrics": "[verse]\nMorning light on a coffee cup\nA brand new day is waking up\n[chorus]\nWe are gonna be alright\nWe are gonna be alright"
```

## Tips

- **Keep sections short.** 2–6 lines per section reads/sings better than long blocks; the model controls timing.
- **Repeat the chorus** — listing `[chorus]` again with the same lines reinforces the hook.
- **Let the model write lyrics** when the user only gives a theme: use `pixio/mureka/music/create` (pass the theme as `prompt`, no lyrics field). Or set `lyrics_optimizer: true` on minimax to polish rough lyrics.
- **Instrumental**: don't send lyrics — set `is_instrumental: true` (minimax) or `force_instrumental: true` (music/compose), or pick an instrumental model.
- **Sanitize before sending**: replace em-dash `—` (U+2014) and en-dash `–` with `-`, and avoid flagged vocabulary (violent-film references, horror signifiers, genre-trigger words) that can wedge `music/compose`. The helper script and the gateway are both happier with plain ASCII punctuation.
- **Length**: most models target ~30–90s. Use `pixio/music/compose` with `music_length_seconds` when you need a specific duration; use `pixio/songcraft/extend` to lengthen an existing track.
