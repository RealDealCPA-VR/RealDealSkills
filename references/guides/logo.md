# Guide — Logo Concepts

The logo is generated first because every later asset references it visually.

## Output Plan

Generate **3 logo concepts** so the user has real options. Match the logo-type intake answer:

| Logo type | What the 3 concepts should explore |
|---|---|
| Wordmark | 3 different type treatments (geometric sans, modern serif, distinctive custom) |
| Lettermark | 3 monogram approaches (enclosed, stacked, ligatured) |
| Icon / symbol | 3 conceptually different symbols tied to the business |
| Combination | 3 icon-and-wordmark lockups in different proportions |

## Aspect Ratio And Format

- Aspect ratio: **1:1** (logos are presented and used as squares).
- Background: solid white or transparent (state it in the prompt).
- Output format: PNG.

## Prompt Skeleton

Prepend the brand system prefix from `brand-system.md`, then append the logo-specific instruction:

```
{BRAND_SYSTEM_PREFIX}

Logo design for {BUSINESS_NAME}. {LOGO_TYPE_INSTRUCTION}. Single logo centered on a clean white background. Vector-style, high contrast, scalable. No mockup, no shadows, no 3D rendering — flat logo presentation only.
```

`{LOGO_TYPE_INSTRUCTION}` is one of:

- Wordmark: `Wordmark logo — the full business name set in distinctive typography. No icon or symbol.`
- Lettermark: `Lettermark logo — the initials "{INITIALS}" set as a memorable monogram. No icon or symbol beyond the letterforms.`
- Icon: `Icon-only logo — a single symbolic mark with no text. The icon should suggest {ONE-LINE BUSINESS DESCRIPTION}.`
- Combination: `Combination logo — an icon paired with the wordmark "{BUSINESS_NAME}". Icon to the left of or above the text.`

## Generating The 3 Variants

Run three separate generations, varying the **last sentence** of the prompt to push the model into a different direction each time:

1. Variant A: append `Geometric, structured, grid-based.`
2. Variant B: append `Organic, hand-shaped, custom letterforms.`
3. Variant C: append `Distinctive, unexpected, signature element.`

(For icon-only logos, replace those with three different metaphors derived from the business description — for a coffee roastery: "a stylized bean cross-section", "an abstract roast curve", "a minimal kettle silhouette".)

## Invoking pixio-skill

For each variant, invoke `pixio-skill` with:

- **Intent:** text-to-image
- **Aspect ratio:** 1:1
- **Prompt:** the full assembled prompt (brand system prefix + logo skeleton + variant suffix)
- **Reference images:** none

The pixio-skill picks the model (typically a flux or nano-banana image model from `/api/v1/models`), discovers params, and returns the output URL.

## Presenting Results

Show the 3 outputs side-by-side as URLs with one-line descriptions:

> **Variant A — geometric:** [url]
> **Variant B — organic:** [url]
> **Variant C — signature:** [url]
>
> Which direction feels right? I can iterate on a favorite, or pick one and move on to social posts.

## Iteration

If the user wants iteration on a variant: re-generate with the same prompt but add a specific tweak the user mentioned (e.g., "warmer color", "tighter letter spacing", "remove the underline").

If the user wants something totally new: ask which intake answer should change, then update the brand system and try again.

## Anti-Patterns

- Do not generate logos with photographic mockups (business cards, billboards). Flat presentation only.
- Do not include placeholder text like "your tagline here". If a tagline exists, include the real one; otherwise omit.
- Do not request "3D rendered", "metallic", "embossed" — these read as cheap stock-logo aesthetics.
- Do not generate more than 3 variants in one pass. Iterate one at a time on the user's favorite instead.
