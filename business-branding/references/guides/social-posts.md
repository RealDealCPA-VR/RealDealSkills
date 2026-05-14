# Guide — Social Media Posts

Generated after the logo is approved. Reuses the brand system prefix and references the chosen logo for consistency.

## Default Output Plan

Generate **3 starter posts**, each in two formats:

- **1:1 feed post** (Instagram feed, LinkedIn, Facebook)
- **9:16 story** (Instagram/Facebook Stories, TikTok, Reels cover)

Total: 6 generations. Tell the user the count up front so they understand the credit cost.

## The 3 Post Themes

Unless the user specifies their own, use these three universal themes:

1. **Identity post** — introduces the brand. Hero shot of the product/service with the logo prominent.
2. **Value post** — communicates a benefit or proof point. Lifestyle/in-use shot with short overlay text.
3. **Promo / CTA post** — drives an action (launch, offer, signup). Bold visual with clear CTA-ready negative space.

If the user has a specific campaign in mind, replace these with their themes. Ask before generating: *"I'm planning to start with three post themes — identity, value, and promo. Want to swap any of those for something specific to a campaign you're running?"*

## Aspect Ratios

| Format | Aspect ratio | Notes |
|---|---|---|
| Feed | 1:1 | Universal — works on Instagram, LinkedIn, Facebook. |
| Story | 9:16 | Reserve top 15% and bottom 15% for platform UI overlays — keep critical content centered. |

## Prompt Skeleton

```
{BRAND_SYSTEM_PREFIX}

Social media {FEED|STORY} post for {BUSINESS_NAME}. Theme: {IDENTITY|VALUE|PROMO}. {THEME_INSTRUCTION}. Composition leaves room for short overlay text in the {top|bottom|center}. Photo-real or designed graphic, NOT a mockup of a phone screen.
```

`{THEME_INSTRUCTION}` examples (adapt to the business):

- Identity: `Hero shot featuring the brand's main product or service. The brand wordmark or logo is integrated subtly into the composition.`
- Value: `In-use lifestyle scene showing the target audience benefiting from the product. Naturalistic, candid feeling.`
- Promo: `Bold, attention-grabbing composition with high-contrast focal point and clean negative space for a CTA.`

## Including The Logo

Two approaches — pick based on logo type:

- **For wordmark / combination logos:** include the logo as a flat overlay element in the prompt: `Brand logo "{BUSINESS_NAME}" placed in the lower-right corner in clean typography.`
- **For icon-only / lettermark logos:** upload the approved logo file as a reference image and ask pixio-skill to do an image-edit/composition pass that incorporates it.

If you don't have the logo file uploaded yet, ask the user to upload it (or pass the Pixio output URL from the logo step — pixio-skill can import a public URL directly).

## Invoking pixio-skill

For each of the 6 generations:

- **Intent:** text-to-image (or image-edit if compositing with a logo file)
- **Aspect ratio:** 1:1 or 9:16
- **Prompt:** brand system prefix + post skeleton + theme instruction
- **Reference images:** the approved logo URL when applicable

## Pacing

Default Pixio accounts have concurrency = 1. Six generations run sequentially. Tell the user: *"This will be 6 generations and will take a few minutes — I'll send each one as it finishes."* Stream results to the user as each completes rather than waiting for all six.

## Presenting Results

Group by theme:

> **Identity** — Feed: [url] | Story: [url]
> **Value** — Feed: [url] | Story: [url]
> **Promo** — Feed: [url] | Story: [url]

Then ask: *"Want iterations on any of these, or should I move on to ad creatives?"*

## Anti-Patterns

- Do not generate "phone mockup" shots — they read as ads-about-ads, not posts.
- Do not include fake usernames, comment counts, or platform UI in the image.
- Do not include long body text in the image — captions live outside the image; only short overlay text belongs in it.
- Do not over-specify the overlay text — leave room for the user to add real copy in their scheduling tool.
