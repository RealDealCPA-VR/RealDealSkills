# End-To-End Example

This walks one full session from first user message through the first delivered asset, so future-Claude has a concrete reference.

## User's First Message

> "I'm launching a coffee subscription called Northwind Roastery. Can you help me build the brand and some marketing assets?"

## Step 1 — Intake (free-form first message)

Claude responds:

> Great — let's start with a quick snapshot before I design anything:
>
> 1. **Business name** is "Northwind Roastery" — what does it do in one sentence?
> 2. **Who is the target customer?**
> 3. **One or two competitors or brands you admire** — and what you like about how they look.
> 4. **Anything we should avoid?**

User answers:

> Small-batch specialty coffee subscription, ships every two weeks. Target: home brewers 25–45 who care about origin and process. Admire Heart Roasters and Onyx Coffee Lab — both feel premium and editorial without being stuffy. Avoid: rustic farmhouse aesthetic, coffee-bean clip art, anything that looks like Starbucks.

## Step 2 — Intake (structured questionnaire)

Claude sends a single `AskUserQuestion` call with all four structured questions from `intake.md`.

User picks:
- Vibe: Modern & innovative
- Style: Serious / premium
- Colors: "I have specific brand colors already" → follow-up: `#1A1A1A, #C9A876, #F5F0E8`
- Logo type: Combination

## Step 3 — Echo Back

Claude:

> Here's what I have:
> - **Business:** Northwind Roastery — small-batch specialty coffee subscription, ships every two weeks
> - **Target:** home brewers 25–45 who care about origin and process
> - **Vibe:** Modern & innovative | **Style:** Serious / premium
> - **Colors:** #1A1A1A, #C9A876, #F5F0E8
> - **Logo type:** Combination (icon + wordmark)
> - **Avoid:** rustic farmhouse, coffee-bean clip art, Starbucks-like
>
> If that's right, I'll build the brand system and start with three logo concepts.

User confirms.

## Step 4 — Brand System

Claude loads `brand-system.md` and assembles:

**Prompt prefix:**
```
modern, forward-looking, premium, refined, editorial, sophisticated, restrained palette, luxe, color palette anchored on #1A1A1A, #C9A876, #F5F0E8. Brand: Northwind Roastery — small-batch specialty coffee subscription. Target audience: home brewers age 25–45 who care about origin and process. Avoid: rustic farmhouse aesthetic, coffee-bean clip art.
```

**Human summary** echoed to the user for sign-off.

Claude also asks for the Pixio API key here if not already in context.

## Step 5 — Logo Generation

Claude loads `guides/logo.md`. Combination logo → 3 lockup variants.

Three prompts (one per variant), each prepending the brand system prefix:

**Variant A:**
> {PREFIX} Logo design for Northwind Roastery. Combination logo — an icon paired with the wordmark "Northwind Roastery". Icon to the left of the text. Single logo centered on a clean white background. Vector-style, high contrast, scalable. No mockup, no shadows, no 3D rendering — flat logo presentation only. Geometric, structured, grid-based.

**Variant B:** appends `Organic, hand-shaped, custom letterforms.`

**Variant C:** appends `Distinctive, unexpected, signature element.`

Claude invokes `pixio-skill` three times (sequential, default account is concurrency=1), streaming each result as it lands.

## Step 6 — Present And Iterate

Claude:

> **Variant A — geometric:** [url]
> **Variant B — organic:** [url]
> **Variant C — signature:** [url]
>
> Which direction feels right? I can iterate on a favorite, or pick one and move on to social posts.

User picks B and asks for tighter letter spacing. Claude re-runs Variant B's prompt with `Tighter letter spacing on the wordmark.` appended.

## Step 7 — Continue

Once the logo is locked, Claude moves to `guides/social-posts.md` using the approved logo URL as a reference image where applicable.

---

## Notes For Future Claude

- The brand system prefix never changes mid-session. If the user wants to tweak vibe/style/colors, regenerate the prefix and re-echo summary first.
- Always stream Pixio results as they complete — don't wait for all generations to finish before showing the user anything.
- Per [[pixio_api_quirks]], wrap PowerShell Pixio calls in try/catch to surface 4xx bodies. The pixio-skill should handle this, but verify.
