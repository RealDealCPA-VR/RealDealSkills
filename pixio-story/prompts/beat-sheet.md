# Prompt: beat sheet (Pass 2 of 3)

Use this prompt to translate the treatment from Pass 1 into a sequence of dramatic beats with explicit function. The beat sheet sits between treatment and shotlist — it forces structural decisions (where does Act 2 turn? what's the climax composition?) BEFORE the LLM starts thinking visually. Skipping this pass produces shotlists that are visually varied but dramatically flat.

---

You are a story editor. Convert the treatment below into an ordered beat sheet. Each beat is a unit of story progression that the audience experiences as a single change.

**Treatment (output of Pass 1):**

{treatment_json}

**Target runtime:** {duration_seconds} seconds

**Output:** valid JSON only.

```json
{
  "act_shape": "3-act | 5-act | vignette | spiral",
  "total_runtime_s": 60,
  "beats": [
    {
      "id": 1,
      "function": "establish | inciting incident | escalation | midpoint reversal | crisis | climax | resolution | tag",
      "act": 1,
      "duration_s": 12,
      "purpose": "what changes in the audience's understanding between the start and end of this beat",
      "location": "single phrase: where this beat takes place",
      "present_characters": ["character names from treatment"],
      "what_happens": "one or two sentences of concrete, visible action — no internal states",
      "emotional_register": "single adjective for the dominant feeling (tense | tender | grim | euphoric | quiet | chaotic | etc.)",
      "links_to_theme": "one phrase: how this beat tests or expresses the treatment's theme"
    }
  ]
}
```

**Rules:**

1. **Sum of `duration_s` must equal `total_runtime_s`.** Hard constraint.
2. **Every beat must have a `function`.** Beats without function are filler — delete them or merge into neighbors. A 60-second film typically has 4-6 beats; 2 minutes has 7-10; 5 minutes has 12-20.
3. **`purpose` is what CHANGES.** "She enters the room" is not a beat. "She enters the room expecting safety, finds it stripped bare" is. If you can't name a change, the beat shouldn't exist.
4. **Pacing rules by runtime:**
   - <90s: condense to 3-act with no midpoint. Inciting incident lands by 20% mark. Climax begins by 75% mark.
   - 90s-5min: full 3-act with midpoint reversal at ~50%.
   - The CLIMAX beat should be the LONGEST single beat in the film. Resolution is short.
5. **Emotional register must VARY between adjacent beats.** Two adjacent beats with the same register read as flat. If your climax is "tense" and your resolution is "tense", one of them is wrong.
6. **`links_to_theme` is the integrity check.** If a beat's link is "doesn't really" or "loosely", cut the beat. Every beat earns its runtime by advancing the theme.

**Composition guidance for the climax beat (if any):**

- Multiple participating characters whenever possible — single-character climaxes read as anticlimactic in short-form.
- Visible physical action, not internal realization. The audience needs something to SEE.
- The `central_question` from the treatment must be answered IN this beat (resolution beat is the consequence, not the answer).

After this pass, sanity-check: if you removed the climax beat and skipped to resolution, would the resolution still make sense? It shouldn't. If it does, the climax isn't doing structural work.

---

## Self-critique pass (mandatory)

After producing the JSON above, BEFORE moving to the shot breakdown, attack your own beat sheet by scoring each axis 1-5 and revising any score ≤3:

1. **Climax removability (1-5):** If you delete the climax beat and skip from crisis straight to resolution, does the resolution still make narrative sense? It SHOULDN'T. Score 1 if it does (your climax isn't load-bearing). Rewrite the climax to make it the structural answer to the central question.
2. **Function diversity (1-5):** Do any two consecutive beats share the same `function` (e.g. two `escalation` beats in a row)? Score down for each repeat. Adjacent same-function beats are usually one beat that should be merged. Either merge or differentiate.
3. **Emotional contrast (1-5):** Are any two adjacent beats sharing the same `emotional_register`? Score 1 if 2+ pairs repeat. Films breathe through contrast; flat registers across beats read as monotone. Rewrite the registers to alternate.
4. **Theme integrity (1-5):** Could you delete the `links_to_theme` field from every beat without weakening the story? Score 1 if the link is decorative ("loosely connects", "kind of tests"). The theme should be the spine — every beat must test or express it concretely. Rewrite weak links.
5. **Climax has the most runtime (1-5):** Is the climax beat the longest single beat? If not, score 1 unless you can defend why (e.g. an ironic film where the climax is a moment, not a sequence). Usually rebalance so climax_duration > max(other_beats).
6. **Visible change per beat (1-5):** For each beat's `what_happens`, can you point to a specific visible thing that's true at the END that wasn't true at the START? If a beat ends without a visible change (just internal realization), score 1. Rewrite so the change is something the camera can see.

Revise once. After the revision, if any axis is still ≤3, accept it — don't loop forever. Output the final JSON only; do not include the critique in the output.

---

## Climax coverage hint (for the shotlist pass)

If the climax beat will be expanded into multiple coverage shots in the next pass, add a `coverage_shots` field to the climax beat:

```json
{ "id": <climax_beat_id>, "function": "climax", "coverage_shots": 4, ... }
```

`coverage_shots: N` means the next pass will produce N short coverage shots (2-4s each) that all depict the same climactic moment from different angles — wide, medium, close, reaction. Default `coverage_shots: 3` for any climax beat ≥6s in duration. Set `coverage_shots: 1` to skip coverage (single long shot of the climax) only if the climax is deliberately a single sustained image (a held final reveal, a single explosion).

---

## Cutaway / B-roll hint (for the shotlist pass)

Real films breathe by cutting to atmospheric inserts — a clock face, raindrops on a windshield, a steaming cup, a shoe on cobblestone, the sky between buildings — that establish texture, time, and place without any character on screen. These cost nothing for identity-drift (no characters to track) and dramatically lift production value because they tell the audience "this world is being observed, not just narrated".

For each beat that would benefit from texture, add `cutaway_count: N`:

```json
{ "id": 2, "function": "escalation", "cutaway_count": 1, ... }
```

`cutaway_count: 1` means the next pass will insert ONE atmospheric character-free shot somewhere within this beat's run. The cutaway is a separate shot in the shotlist (2-4s typical) marked with `cutaway: true` and `characters: []`.

**Default cutaway_count by beat function:**
- `establish` → 1 (an environment shot helps set the world)
- `escalation`, `midpoint reversal` → 1 if beat ≥10s, 0 if shorter
- `crisis`, `climax` → 0 (cutaways break momentum at the climax; only use here if the cutaway IS the climax — e.g. the clock striking)
- `resolution`, `tag` → 1 (cutaways at the end let the film "exhale")

Total cutaways across the film should stay ≤25% of total shot count. Too many cutaways read as "music video" — fine for music videos, jarring for narrative.

Cutaways are NOT a substitute for plot beats — they're insertions WITHIN existing beats, not replacements for them. The cutaway shot's `what_happens` doesn't appear in the beat sheet; it lives only in the shotlist.
