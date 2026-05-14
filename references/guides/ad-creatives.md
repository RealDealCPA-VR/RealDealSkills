# Guide — Ad Creatives

Generated after social posts. Same brand system prefix; different formats and a more salesy framing.

## Default Output Plan

- **1 hero banner** — 16:9, suitable for website hero, YouTube cover, LinkedIn banner.
- **1 square display ad** — 1:1, suitable for most display networks and social-ad placements.

If the user runs paid display ads at IAB standard sizes, offer to add:

- Leaderboard 728×90 → use 8:1 aspect
- Medium rectangle 300×250 → use 6:5 aspect
- Skyscraper 160×600 → use 4:15 aspect
- Mobile banner 320×50 → use 32:5 aspect

Only generate these if explicitly requested — they're rarely all needed and they multiply credit cost fast.

## Hero Banner Prompt Skeleton

```
{BRAND_SYSTEM_PREFIX}

Hero web banner for {BUSINESS_NAME}. Wide cinematic composition. Strong focal subject on the {left|right} third, leaving the opposite two-thirds as clean space for a headline and CTA. Subject should communicate {PRIMARY_VALUE_PROP} — {ASSET_INSTRUCTION}. Lighting reinforces the brand vibe.
```

`{ASSET_INSTRUCTION}` is built from the business description. Examples:

- Coffee subscription: `a single hand pouring water from a gooseneck kettle onto fresh grounds, steam rising`
- B2B SaaS: `a clean abstract composition of overlapping data shapes in the brand palette`
- Fitness coach: `a runner mid-stride at golden hour on an empty street`

Ask the user what the **primary value prop** is if it's not obvious from intake — that's the single most important thing the ad should communicate.

## Square Display Ad Prompt Skeleton

```
{BRAND_SYSTEM_PREFIX}

Square display ad for {BUSINESS_NAME}. Bold, scroll-stopping composition. {SUBJECT} centered or off-center with strong contrast. Negative space in the {top|bottom} third for headline overlay. Designed to read clearly at 250×250 thumbnail size.
```

## Reusing The Logo

Same logic as social posts:

- Wordmark / combination → prompt the logo placement in the corner.
- Icon-only / lettermark → upload the logo file (or pass its URL) and use image-edit.

## Invoking pixio-skill

For each ad:

- **Intent:** text-to-image (or image-edit if compositing with the logo)
- **Aspect ratio:** 16:9 for hero, 1:1 for square
- **Prompt:** brand system prefix + ad skeleton + asset instruction
- **Reference images:** approved logo URL when applicable

## Presenting Results

```
Hero banner (16:9): [url]
Square ad (1:1): [url]
```

Then: *"These are designed with headline/CTA space — you'll add the actual copy in your ad platform. Want iterations or additional sizes?"*

## Headline And CTA Copy

This skill generates the **visual** only. If the user wants headline/CTA copy too, write it as plain text in the response (don't bake it into the image). Suggested format:

> **Headline options:**
> 1. [short headline]
> 2. [alt headline]
>
> **CTA options:** Get started · Try free · Shop now · Book a demo

Keep copy short, benefit-led, and matched to the vibe descriptor.

## Anti-Patterns

- Do not bake real headline text into the image — text rendering is unreliable and the user needs to A/B test copy separately.
- Do not generate ads with photorealistic stock-photo-style models doing forced smiles — it reads as low-trust.
- Do not center the subject when the user needs CTA space — ask which third should hold negative space if it's not obvious.
- Do not generate every IAB size by default. Hero + square covers 80% of needs.
