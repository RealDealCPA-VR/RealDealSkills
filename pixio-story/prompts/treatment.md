# Prompt: treatment (Pass 1 of 3)

Use this prompt to expand the user's brief into a one-page treatment before any structural work. The treatment exists to surface what the story is ACTUALLY about — its theme, the central problem, the protagonist's wound, and the resolution. Skipping this pass is the single largest source of "AI slop" writing: shotlists generated from a logline have no underlying story, just a sequence of cool-sounding visuals.

---

You are a story consultant. Read the user's brief below and write a tight one-page treatment that exposes the story's actual mechanics.

**Brief:**

{brief_text}

**Target runtime:** {duration_seconds} seconds

**Output:** valid JSON only, conforming to this schema. No prose outside the JSON.

```json
{
  "title": "working title",
  "logline": "single sentence: PROTAGONIST wants GOAL because MOTIVATION but ANTAGONIST/OBSTACLE",
  "theme": "the underlying human truth this story tests (one sentence, no abstractions like 'love' or 'freedom' — name the specific question, e.g. 'whether competence can replace belonging')",
  "premise": "the world-rule or what-if that makes this story possible (one sentence)",
  "protagonist": {
    "name": "name or role",
    "want": "what they're consciously pursuing",
    "need": "what the story will force them to learn (often the opposite of want)",
    "wound": "the prior event or condition shaping their behavior — the reason they have the want"
  },
  "antagonist_or_obstacle": "the force that opposes the want. Person, system, internal flaw, or environment. Be specific.",
  "central_question": "the dramatic question whose answer the climax delivers (e.g. 'will she trust him in time?')",
  "tone": "two or three adjectives that should govern every shot (e.g. 'desaturated, patient, dread-soaked')",
  "stakes": "what is lost if the protagonist fails",
  "resolution_type": "tragic | bittersweet | triumphant | ambiguous | ironic",
  "scene_count_estimate": "rough beats count for the runtime (4-7 for 60s; 8-12 for 2min; 15-25 for 5min)"
}
```

**Rules:**

1. The logline must follow the WANT/MOTIVATION/OBSTACLE shape. If you can't fill all three, the brief is too thin — invent the missing piece in the spirit of the brief.
2. `theme` and `want`/`need` must be DIFFERENT. If `want` is "to win the race" and `need` is "to learn to lose gracefully", that's a story. If they're the same, you don't have a story yet — invent a need.
3. `wound` is non-negotiable. Even a 60-second film implies a backstory; without one the protagonist behaves randomly. If the brief doesn't specify, infer something plausible.
4. `tone` adjectives will be propagated as the project's `style` later — make them visual, not emotional ("sun-bleached, slow" not "sad, hopeful").
5. `central_question` must be answerable yes/no by the final shot. "Will she trust him?" not "What does trust mean?"
6. Keep it tight — every field is one sentence or short phrase. The treatment is the cap on every downstream decision; it must be MEMORABLE, not exhaustive.

After this pass, validate the treatment by asking: if I changed the `theme` or `need`, would the rest of the story collapse? If not, those fields are too generic — rewrite them.

---

## Self-critique pass (mandatory)

After producing the JSON above, BEFORE moving to the beat sheet, attack your own treatment by scoring each axis 1-5 and revising any score ≤3:

1. **Theme distinctness (1-5):** Could I swap the `theme` for "the importance of trying" or "the value of love" without rewriting anything else? If yes, score 1. The theme must be specific enough that the climax beat will be different from any other film's climax. Rewrite if ≤3.
2. **Want ≠ need (1-5):** Are `want` and `need` describing the same goal in different words? Score 1 if yes. Strong stories have `want` and `need` in dramatic opposition (she wants to win the race; she needs to learn she's not defined by winning). Rewrite if ≤3.
3. **Wound earns the want (1-5):** Reading just the `wound`, can I predict the `want`? If the connection is invisible or arbitrary, score 1. The wound must make the want feel inevitable. Rewrite if ≤3.
4. **Central question is binary (1-5):** Can the final shot answer the `central_question` with yes or no? "Will she trust him?" is binary. "What is trust?" isn't. Rewrite if ≤3.
5. **Tone is visual (1-5):** Are `tone` adjectives describing what the camera SEES or what the audience FEELS? "Sun-bleached, slow" is visual (5). "Sad, hopeful" is emotional (1). Rewrite if ≤3.

Revise once. After the revision, if any axis is still ≤3, accept it — don't loop forever. Output the final JSON only; do not include the critique in the output.
