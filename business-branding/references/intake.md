# Intake

Run this before any generation. Capture answers verbatim — they become the input to `brand-system.md`.

## Step 1 — Business Basics (free-form, one message)

Ask in one message (do not use AskUserQuestion for these — they're open-ended):

> Before we design anything, I need a quick snapshot of the business:
>
> 1. **Business name** and what it does in one sentence.
> 2. **Who is the target customer?** (e.g., "first-time homebuyers age 28–40", "indie game devs", "luxury wedding planners")
> 3. **One or two competitors or brands you admire** — and what you like about how they look.
> 4. **Anything we should avoid?** (colors, imagery, styles that don't fit — e.g., "no stock-photo handshakes", "nothing that looks like a tech startup")

Wait for the answer before moving to Step 2. If the user gives a thin answer, ask one clarifying follow-up, then move on — don't interrogate.

## Step 2 — Structured Brand Choices (use AskUserQuestion)

Send all four questions in a single `AskUserQuestion` call.

### Question 1 — Vibe

```
question: "What image do you want to project to customers?"
header: "Vibe"
multiSelect: false
options:
  - label: "Trustworthy & established"
    description: "Conveys reliability, expertise, longevity. Good for finance, legal, healthcare, B2B services."
  - label: "Modern & innovative"
    description: "Forward-looking, tech-savvy, premium-but-accessible. Good for SaaS, DTC, modern services."
  - label: "Warm & approachable"
    description: "Friendly, human, community-oriented. Good for local businesses, hospitality, family brands."
  - label: "Bold & disruptive"
    description: "Confident, distinctive, willing to stand out. Good for challenger brands and lifestyle products."
```

### Question 2 — Style

```
question: "What style should the visuals lean toward?"
header: "Style"
multiSelect: false
options:
  - label: "Professional / clean"
    description: "Minimal, lots of whitespace, restrained typography. Reads as serious and competent."
  - label: "Casual / friendly"
    description: "Rounded forms, conversational tone, approachable imagery."
  - label: "Fun / playful"
    description: "Energetic colors, expressive type, illustrative elements."
  - label: "Serious / premium"
    description: "Sophisticated, restrained palette, editorial feel."
```

### Question 3 — Color Scheme

```
question: "Which color direction fits the brand?"
header: "Colors"
multiSelect: false
options:
  - label: "I have specific brand colors already"
    description: "User will provide hex codes or named colors — capture them verbatim in the next message."
  - label: "Monochrome + one accent"
    description: "Black/white/grey foundation with a single bold accent color. Reads as confident and modern."
  - label: "Warm palette (reds/oranges/earth tones)"
    description: "Inviting, energetic, organic. Good for food, hospitality, lifestyle."
  - label: "Cool palette (blues/greens/purples)"
    description: "Calm, trustworthy, technical. Good for finance, health, tech."
```

If the user picks "I have specific brand colors already," follow up: *"Great — list the hex codes or names you want to anchor the palette around."*

### Question 4 — Logo Type

```
question: "What kind of logo do you want?"
header: "Logo type"
multiSelect: false
options:
  - label: "Wordmark (text-based — full business name)"
    description: "Like Google, Coca-Cola, FedEx. Best when the name is short and distinctive."
  - label: "Lettermark (initials)"
    description: "Like HBO, IBM, NASA. Good for long names or when initials are memorable."
  - label: "Icon / symbol (image-based, no text)"
    description: "Like Apple, Nike swoosh, Twitter bird. Best when paired with a separate wordmark and used at small sizes."
  - label: "Combination (icon + text together)"
    description: "Like Adidas, Burger King, Lacoste. Most versatile — works as either piece alone or together."
```

## Step 3 — Echo Back

After all answers are collected, summarize the intake in 5–7 lines. Example:

> Here's what I have:
> - **Business:** [name] — [one-line description]
> - **Target:** [audience]
> - **Vibe:** [chosen] | **Style:** [chosen]
> - **Colors:** [chosen, with hex if provided]
> - **Logo type:** [chosen]
> - **Avoid:** [the don'ts]
>
> If that's right, I'll build the brand system and start with logo concepts.

Get explicit confirmation before invoking `brand-system.md`.

## When To Skip Intake

If the user has already provided all of the above in their initial message, skip the structured questionnaire and go straight to Step 3 (echo back). Do not re-ask things they already told you.
