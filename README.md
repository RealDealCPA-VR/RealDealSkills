# Real Deal Skills

**Battle-tested Claude skills from The Real Deal.**

![License](https://img.shields.io/badge/license-MIT-blue)
![Built With](https://img.shields.io/badge/built_with-Claude-orange)
![Status](https://img.shields.io/badge/status-in_production-brightgreen)

These aren't demos. Every skill in this repo has earned its spot in production by saving time, preventing a mistake, or making the output sharper. If it's here, it's because it works.

---

## Why This Exists

Most skill libraries are built to show what's possible. This one is built by an operator, for operators. Every skill came out of a real workflow and a real need. When a skill stops paying its way, it gets retired. When a new one proves itself in the field, it ships.

## What Is a Skill?

A skill is a folder with a `SKILL.md` file that teaches an agent how to do one specific thing well. The agent loads the instructions only when the task actually triggers them, which keeps context clean and tokens cheap. Think of it as a function signature for an LLM: a tight description, a trigger condition, and a body of instructions.

## Works With

- Claude.ai projects
- Claude Code
- Claude Agent SDK
- Any agent framework that reads a `SKILL.md`

## Install and Use

### Claude Code
```bash
git clone https://github.com/realdealcpa/skills.git ~/.claude/skills/realdeal
```
Claude Code discovers the skills on next launch.

### Claude.ai Projects
Upload the skill folder to your project files. The skill triggers on description match.

### Claude Agent SDK
Point your skills directory at the cloned repo. The SDK handles discovery, loading, and progressive disclosure.

### Self-hosted agents
Drop the folder into your agent's skills path and register by name.

## Anatomy of a Skill

```
skill-name/
├── SKILL.md          # Description, triggers, core instructions
├── examples/         # Before/after samples
└── reference.md      # Optional deep dive the agent pulls on demand
```

A `SKILL.md` has YAML frontmatter and a body:

```markdown
---
name: skill-name
description: Use this skill when [specific trigger condition]. Describe when to reach for it, not just what it is.
---

# Skill Name

## When to use
- Concrete situation one
- Concrete situation two

## Rules
1. The first rule the agent must follow.
2. The second rule.
3. The third rule.
```

## Why Skills Beat Prompt Libraries

- **Composable.** Stack them. One task can trigger multiple skills together.
- **Portable.** The same folder runs in Claude.ai, Claude Code, the Agent SDK, and self-hosted agents.
- **Version controlled.** Git tracks every refinement so you can see what moved the needle.
- **Token efficient.** Skills load on demand, not up front. Your context stays available for the actual work.
- **Legible.** Anyone can read a `SKILL.md` and understand the rule in under a minute.

## Design Principles

1. **One skill, one job.** If a skill is doing two things, split it.
2. **Triggers over keywords.** The `description` field is the ranking signal. Write it to describe *when* to use the skill, not what it is.
3. **Progressive disclosure.** Put the essentials in `SKILL.md`. Put the deep reference in a separate file the agent can pull when needed.
4. **Opinionated beats generic.** A skill that enforces a clear house style is worth more than one that hedges.
5. **Retire ruthlessly.** If a skill isn't firing or isn't helping, kill it.

## Contributing

These are opinionated. Fork freely, tune to your own workflows, open a PR if you build something sharper.

When submitting:
- Include a `SKILL.md` with a tight `description` field.
- Show at least one before/after example.
- Note any connectors or MCP servers the skill assumes.

## License

MIT. Use them, modify them, ship them. Credit appreciated, not required.

## Who

Built and maintained by **The Real Deal.**

- X: [@realdealcpa](https://x.com/realdealcpa)

---

*Skills are the unit of agent capability. Treat them like code: write them tight, version them, and retire them when they stop paying their way.*
