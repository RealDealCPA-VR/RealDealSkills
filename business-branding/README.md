# Business Branding Skill

Agent Skill that turns a business owner's intent into a coherent set of brand and marketing assets. Wraps the `pixio-skill` with a structured intake, a reusable brand system, and deliverable-specific guides.

This skill teaches compatible agents how to:

- run a hybrid intake (structured questions for vibe, style, color scheme, logo type; free-form for audience, competitors, inspirations);
- translate intake answers into a reusable prompt prefix that keeps every generated asset visually consistent;
- generate 3 logo concepts matched to the chosen logo type (wordmark / lettermark / icon / combination);
- generate social media posts in feed (1:1) and story (9:16) formats across 3 themes;
- generate ad creatives (hero banner, square display, optional IAB sizes);
- generate short video ads on request only, with a credit-confirmation gate;
- delegate all Pixio API mechanics (model discovery, params, uploads, polling, errors) to `pixio-skill` instead of duplicating that work.

## Install

From a local checkout:

```bash
npx skills add ./scripts/business-branding
```

Install globally:

```bash
npx skills add -g ./scripts/business-branding
```

If this skill is moved to its own repository, install it from the repo:

```bash
npx skills add <owner>/<repo>
```

## Requires

- `pixio-skill` must also be installed — this skill delegates all image and video generation to it.
- A Pixio API key (the agent will ask if not provided).

## Usage

After installing, ask an agent something like:

```text
Build a brand for my new sourdough bakery — I want a logo, a color palette, and a few social posts.
```

or:

```text
Design ad creatives for my B2B SaaS launch. Modern, blue palette, combination logo.
```

The agent should load `business-branding`, run intake, get sign-off on the brand system, then invoke `pixio-skill` for each generation.

## Files

- `SKILL.md`: required Agent Skill entrypoint and workflow.
- `references/index.md`: map of all reference docs.
- `references/intake.md`: hybrid questionnaire (structured + free-form) and echo-back gate.
- `references/brand-system.md`: translates intake answers into a reusable prompt prefix and human-readable summary.
- `references/guides/logo.md`: logo concept generation (3 variants per logo type).
- `references/guides/social-posts.md`: feed + story templates across 3 universal themes.
- `references/guides/ad-creatives.md`: hero banner, square display, opt-in IAB sizes.
- `references/guides/video-ads.md`: opt-in short video promos with credit-cost confirmation.
- `references/examples/end-to-end.md`: full worked example from first message to first deliverable.

## Workflow At A Glance

1. **Intake** — free-form business basics, then a single `AskUserQuestion` call for the 4 structured choices.
2. **Brand system** — assemble the prompt prefix, echo a summary, get sign-off.
3. **Logo first** — generate 3 concepts, let the user pick or iterate.
4. **Social posts** — 6 generations (3 themes × feed + story), streamed as they complete.
5. **Ad creatives** — hero banner + square display by default.
6. **Video** — only if explicitly requested, with a credit estimate up front.
7. **Hand off** — all output URLs grouped by deliverable, plus the brand system summary as a reusable spec.

## Safety

- Same Pixio API key handling as `pixio-skill` — never put keys in browser code, public repos, screenshots, or logs.
- Flag potential trademark conflicts before generating identity assets if the business name resembles an existing brand.
- Confirm scope before video generation — a single 10s video can cost 10–20x a still image.
