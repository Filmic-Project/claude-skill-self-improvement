---
name: skill-maintenance
description: >
  Propose or update a project skill when a reusable, codebase-specific
  convention is discovered that isn't already captured. Use when a PR review
  comment flags a rule, when the same correction has come up more than once,
  when you hit a non-obvious gotcha worth recording, or when the user asks to
  "capture this", "add a skill", or "fill the gaps". Defines the detection
  triggers, the update-vs-create decision, the SKILL.md format, and the
  propose-then-confirm workflow (skills live in .claude/skills/).
compatibility: Repos using .claude/skills/<name>/SKILL.md (Claude Code / Agent SDK skills).
metadata:
  version: "1.0"
---

# Skill maintenance — keep the skill library current

Skills are how this repo's hard-won, non-obvious knowledge survives between
sessions. When you learn something reusable, the work isn't done until it's
captured. This skill is the process for doing that consistently.

> **This skill is the HOW.** The WHEN-to-propose triggers and the approval gate
> are owned by the always-on rule `.claude/rules/skill-self-improvement/RULE.md`.
> That rule fires every session; this skill is loaded on demand to carry out a
> proposal once it's approved. Don't write anything until the user approves.

## When to act (gap-detection triggers)

Treat any of these as a signal that a skill should be created or updated:

1. **Review feedback** — a PR review comment (human or automated) flags a
   convention, rule violation, or "you should have used X". If it's reusable,
   capture it.
2. **Repeated correction** — you (or the user) fixed the same class of issue
   more than once, in this session or across sessions.
3. **Non-obvious gotcha** — something that cost real debugging time and that the
   compiler/tests won't catch next time (an API that silently falls back, an
   import-time crash, an env quirk).
4. **Explicit request** — the user says "capture this", "add/update a skill",
   "document the convention", "fill the gaps".
5. **Drift** — you notice an existing skill is now wrong or incomplete.

If none of these apply, don't create a skill — avoid one-off or speculative
skills (KISS / YAGNI). A skill must encode *reusable* knowledge.

## Update vs create

- **Update an existing skill** when the knowledge fits its scope. Prefer this —
  fewer, denser skills beat many thin ones. Check `.claude/skills/` first.
- **Prefer a targeted PATCH (a small diff) over a rewrite** when updating — it's
  lower-risk and easier to review. Rewrite only when the skill is fundamentally
  wrong. For an improvement, **cite the evidence** (the review comment, the
  failing task) so the change is justified, not speculative.
- **Create a new skill** only when the knowledge is a distinct, cross-cutting
  area not owned by any existing skill.
- If a rule also belongs in `AGENTS.md`/`CLAUDE.md` (the always-loaded source of
  truth), add a one-line rule there and point to the skill for the detail.

## Workflow: propose, then confirm

1. **Draft** the change (new `SKILL.md` or an edit) following the format below.
2. **Propose it to the user** — briefly: what gap, update vs new, where it
   lives, and a 1–2 line summary. Do this even mid-task; a skill change is a
   repo change and deserves a quick confirm. Use `AskUserQuestion` if there's a
   real choice (e.g. which skill to fold it into).
3. **On approval**, write the file. Skills are tracked in git like any other
   source, so commit them with a clear message — but only commit/push when the
   user asks (don't auto-commit after writing).
4. Keep it scoped — document the rule, the wrong/right example, and how to
   verify. Don't pad.

## SKILL.md format

```markdown
---
name: kebab-case-name            # must match the directory name
description: >                   # 2nd person, trigger-rich; this is what makes
  What it covers and WHEN to use it — list the concrete situations that should
  trigger it, so it auto-activates at the right moment.
compatibility: one line          # optional
pinned: true                     # optional — propose patches only, never archive/delete
metadata:
  version: "1.0"
---

# Title

Short why-it-matters. Then the rules with ❌ wrong / ✅ right code examples,
a verification step, and a "Don't" list. Keep it actionable, not theoretical.
```

The **description is the most important field** — skills are selected by it.
Write it so the trigger conditions are explicit (look at a couple of existing
skills in `.claude/skills/` for the house style before writing a new one).

## Don't

- Don't create a skill for a one-off fix or speculative future need.
- Don't silently rewrite a skill the user relies on — propose the change.
- Don't rewrite when a small patch will do, and never archive a `pinned: true` skill.
- Don't duplicate a whole rule into both `AGENTS.md` and a skill — put the
  one-line rule in `AGENTS.md` and the detail in the skill.
- Don't let a skill go stale — if you find it wrong while working, propose the fix.
