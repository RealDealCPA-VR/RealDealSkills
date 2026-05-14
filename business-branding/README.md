# 🎨 Business Branding Skill

**Turn a business idea into a full brand kit in one conversation.**

An Agent Skill that takes a business owner from *"I have a vibe in my head"* to a coherent set of logos, social posts, and ad creatives — without the agency invoice. Wraps `pixio-skill` with a structured intake, a reusable brand system, and deliverable-specific playbooks so every asset looks like it came from the same studio.

---

## ✨ What It Does

This skill teaches compatible agents how to:

- 🎯 **Run a hybrid intake** — structured picks for vibe, style, color scheme, and logo type, plus free-form on audience, competitors, and inspirations.
- 🧬 **Lock in a brand DNA** — translate intake answers into a reusable prompt prefix so every asset stays visually consistent.
- 🅰️ **Generate logos** — 3 concepts matched to the chosen type (wordmark / lettermark / icon / combination).
- 📱 **Spin up social content** — feed (1:1) and story (9:16) posts across 3 themes.
- 📢 **Produce ad creatives** — hero banner, square display, and optional IAB sizes.
- 🎬 **Drop video ads on demand** — short promos, opt-in only, with a credit check before the meter runs.
- 🔌 **Delegate the heavy lifting** — model discovery, params, uploads, polling, and errors all go through `pixio-skill`.

---

## 🚀 Install

From a local checkout:

```bash
npx skills add ./scripts/business-branding
```

Install globally:

```bash
npx skills add -g ./scripts/business-branding
```

If this skill lives in its own repo:

```bash
npx skills add <owner>/<repo>
```

---

## 📦 Requires

- **`pixio-skill`** — this skill delegates every image and video generation to it. Install it first.
- **A Pixio API key** — the agent will prompt for one if it's not already configured.

---

## 💬 Usage

Once installed, just talk to your agent like a creative director:

```text
Build a brand for my new sourdough bakery — logo, color palette, and a few social posts.
```

Or:

```text
Design ad creatives for my B2B SaaS launch. Modern, blue palette, combination logo.
```

The agent loads `business-branding`, walks the intake, gets your sign-off on the brand system, then fires off generations through `pixio-skill`.

---

## 📂 Files

| File | Purpose |
|---|---|
| `SKILL.md` | Required Agent Skill entrypoint and workflow |
| `references/index.md` | Map of all reference docs |
| `references/intake.md` | Hybrid questionnaire + echo-back gate |
| `references/brand-system.md` | Turns intake answers into a reusable prompt prefix |
| `references/guides/logo.md` | 3 variants per logo type |
| `references/guides/social-posts.md` | Feed + story templates, 3 universal themes |
| `references/guides/ad-creatives.md` | Hero banner, square display, opt-in IAB sizes |
| `references/guides/video-ads.md` | Opt-in short promos with credit-cost confirmation |
| `references/examples/end-to-end.md` | Full worked example, first message to first deliverable |

---

## 🗺️ Workflow At A Glance

1. **Intake** — free-form basics, then one `AskUserQuestion` call for the 4 structured picks.
2. **Brand system** — assemble the prompt prefix, echo a summary, get sign-off.
3. **Logo first** — 3 concepts, pick or iterate.
4. **Social posts** — 6 generations (3 themes × feed + story), streamed live.
5. **Ad creatives** — hero banner + square display by default.
6. **Video** — only on request, with a credit estimate up front.
7. **Hand off** — every output URL grouped by deliverable, plus the brand system summary as a reusable spec.

---

## 🛡️ Safety

- 🔑 **API keys stay private.** Same handling as `pixio-skill` — never in browser code, public repos, screenshots, or logs.
- ™️ **Trademark check first.** If the business name resembles an existing brand, the agent flags it before generating identity assets.
- 💰 **No surprise spend.** Video generation requires explicit confirmation — a single 10-second clip can cost 10–20x a still image.
