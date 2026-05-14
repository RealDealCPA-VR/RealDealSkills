---
name: business-branding
description: Use this skill when a business owner wants marketing, branding, or advertising assets — logos, color palettes, typography mood, social posts, display ads, or short promo videos. Runs a hybrid intake (structured questions for vibe, style, color scheme, and logo type; free-form for audience, competitors, and inspirations), translates the answers into a reusable brand system, then orchestrates the pixio-skill to generate the actual assets. Trigger for "build my brand", "design a logo for my business", "create ads for my company", "make social media posts for my shop", "brand identity for my startup", and similar phrasings. Do not use for one-off generic image prompts with no business context — use pixio-skill directly for that.
---

# Business Branding Skill

This skill turns a business owner's intent into a coherent set of brand and marketing assets. It does NOT call the Pixio API itself — it runs intake, builds a reusable brand system, then invokes `pixio-skill` for each generation.

## Default Deliverables

Produced by default (in this order):

1. **Brand identity** — 3 logo concepts, a 5-swatch color palette, and a typography mood reference.
2. **Social media posts** — 3 starter posts in 1:1 (feed) and 9:16 (story) formats.
3. **Ad creatives** — 1 hero banner (16:9) and 1 square display ad (1:1).

Produced only when the user explicitly asks:

- **Short video ads** — 5–10s text-to-video or image-to-video promos. Video burns significantly more credits, so confirm scope and budget before starting.

## Workflow

1. **Intake.** Load `references/intake.md` and run it. Use `AskUserQuestion` for the 4 structured questions (vibe, style, colors, logo type). Then ask the free-form questions conversationally.
2. **Build the brand system.** Load `references/brand-system.md` and translate intake answers into a reusable prompt prefix, palette description, and style descriptor. Echo the brand system back to the user as a short summary and get sign-off before generating anything.
3. **Confirm API readiness.** Ask for a Pixio API key if not already in context. Mention the default Pixio account concurrency is 1 in-flight generation (3 for Maker accounts) — so deliverables will be produced sequentially, not in parallel.
4. **Generate brand identity first.** Load `references/guides/logo.md`. Generate logo concepts before anything else — the chosen logo and refined palette feed every later asset.
5. **Get sign-off on the logo + palette.** Show the user the outputs, let them pick a favorite or request iterations.
6. **Generate the rest of the deliverables.** Use `references/guides/social-posts.md` and `references/guides/ad-creatives.md`. Reuse the brand system prompt prefix in every generation for visual consistency.
7. **Optional: video.** Only if the user asked, load `references/guides/video-ads.md`.
8. **Hand off.** Return all output URLs grouped by deliverable, plus the brand system summary as a reusable spec the user can save.

## How To Invoke pixio-skill

When it's time to actually generate, invoke the pixio-skill via the Skill tool. Pass it a self-contained generation brief — model intent (text-to-image / image-edit / text-to-video), aspect ratio, the full prompt (brand system prefix + asset-specific prompt), and any reference image URLs from prior generations. The pixio-skill handles model discovery, params, uploads, and polling.

Do NOT try to call Pixio endpoints directly from this skill. If you find yourself writing `curl https://beta.pixio.myapps.ai/...`, stop and delegate.

## Reference Routing

- `references/index.md` — start here when unsure which doc to load.
- `references/intake.md` — the hybrid questionnaire.
- `references/brand-system.md` — translating answers into a reusable prompt prefix.
- `references/guides/logo.md` — logo concepts (3 variants per type).
- `references/guides/social-posts.md` — feed + story templates, multi-platform sizing.
- `references/guides/ad-creatives.md` — banner, square, hero ad formats.
- `references/guides/video-ads.md` — opt-in video promos.
- `references/examples/end-to-end.md` — one worked example from intake through first deliverable.

## Guardrails

- **Never start generating before intake + brand-system sign-off.** Skipping intake produces incoherent assets and burns credits.
- **Reuse the brand system prefix in every prompt.** This is what makes the assets feel like one brand instead of ten random images.
- **Logo first, always.** The logo informs palette refinement and downstream prompts.
- **Confirm before video.** Video is opt-in and costs 5–20x a single image.
- **Don't invent trademarks.** If the user names their business after an existing brand, flag it before generating identity assets.
- **Don't fabricate model IDs or params.** This is the pixio-skill's job — let it do model discovery.

## Completion Checklist

Before declaring the brand package ready:

- Intake answers (all 4 structured + free-form) are captured and the brand system was signed off.
- Logo concepts were generated and one was selected (or the user explicitly asked to keep all 3).
- Color palette and typography mood are documented as text the user can paste into a brief.
- Social posts and ad creatives were generated with the brand system prefix.
- Video was generated only if explicitly requested.
- All output URLs are grouped by deliverable in the final response.
- Brand system summary is included so the user can re-run later with consistency.
