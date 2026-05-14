# Brand System

The brand system is a short, reusable spec built from intake answers. It does two jobs:

1. **Prompt prefix** — a fixed string prepended to every Pixio generation so all assets share a visual language.
2. **Human-readable summary** — a 5-line spec the user can paste into briefs, decks, or a future re-run of this skill.

## How To Build It

For each intake answer, pick the matching descriptor from the tables below. Concatenate them into the prefix template. Never invent your own — these have been tuned to read well to image models.

### Vibe → Descriptor

| Intake answer | Prompt descriptor |
|---|---|
| Trustworthy & established | "confident, established, restrained, professional" |
| Modern & innovative | "modern, forward-looking, premium, refined" |
| Warm & approachable | "warm, friendly, human, inviting" |
| Bold & disruptive | "bold, distinctive, high-contrast, confident" |

### Style → Descriptor

| Intake answer | Prompt descriptor |
|---|---|
| Professional / clean | "minimal, clean, ample negative space, restrained typography" |
| Casual / friendly | "rounded forms, friendly, approachable, soft edges" |
| Fun / playful | "energetic, playful, expressive, lively" |
| Serious / premium | "editorial, sophisticated, restrained palette, luxe" |

### Color Scheme → Descriptor

| Intake answer | Prompt descriptor |
|---|---|
| Specific hex codes | "color palette anchored on {hex1}, {hex2}, {hex3}" |
| Monochrome + accent | "monochrome black / white / grey palette with a single {ACCENT} accent" — ask the user for the accent color if not given |
| Warm palette | "warm palette: terracotta, ochre, deep red, cream" |
| Cool palette | "cool palette: deep blue, teal, soft green, off-white" |

### Logo Type → How To Use It Downstream

| Intake answer | Notes for non-logo deliverables |
|---|---|
| Wordmark | Place the wordmark prominently; do not generate a separate icon. |
| Lettermark | The lettermark works as a standalone monogram in small spaces (favicons, app icons). |
| Icon / symbol | The icon stands alone but social posts and ads should pair it with the business name in clean type. |
| Combination | Use icon-only at small sizes, full lockup at large sizes. |

## Prompt Prefix Template

```
[VIBE_DESCRIPTOR], [STYLE_DESCRIPTOR], [COLOR_DESCRIPTOR]. Brand: [BUSINESS_NAME] — [ONE_LINE_DESCRIPTION]. Target audience: [AUDIENCE]. Avoid: [DON'TS].
```

### Worked Example

Intake answers:
- Business: "Northwind Roastery — small-batch specialty coffee subscription"
- Audience: "home brewers age 25–45 who care about origin and process"
- Vibe: Modern & innovative
- Style: Serious / premium
- Colors: Specific (#1A1A1A, #C9A876, #F5F0E8)
- Logo type: Combination
- Avoid: "no rustic farmhouse aesthetic, no coffee-bean clip art"

Generated prefix:

```
modern, forward-looking, premium, refined, editorial, sophisticated, restrained palette, luxe, color palette anchored on #1A1A1A, #C9A876, #F5F0E8. Brand: Northwind Roastery — small-batch specialty coffee subscription. Target audience: home brewers age 25–45 who care about origin and process. Avoid: rustic farmhouse aesthetic, coffee-bean clip art.
```

## Human-Readable Summary

Build this in parallel with the prompt prefix and show it to the user for sign-off:

```
Brand System — [BUSINESS_NAME]
- Vibe: [intake answer]
- Style: [intake answer]
- Palette: [hex codes or named palette]
- Logo type: [intake answer]
- Audience: [audience]
- Avoid: [don'ts]
```

## Sign-Off Gate

After echoing the summary, ask:

> Does this brand system feel right? Once you confirm, I'll start generating logo concepts.

Do not proceed without explicit confirmation. If the user wants adjustments, edit the relevant descriptor and re-echo before generating.

## Reuse Across Deliverables

Every downstream guide (`logo.md`, `social-posts.md`, `ad-creatives.md`, `video-ads.md`) prepends this prefix to its asset-specific prompt. That's what creates a unified visual identity across the whole package.
