# claude-skill-self-improvement

A drop-in blueprint that turns Claude Code into a **co-author of its own skill
library**: it *proposes* a new skill when a chat surfaces a reusable convention,
and *proposes a patch* when a loaded skill proves wrong — always behind an
explicit human-approval gate. Generic and project-agnostic; copy it into any
repo that uses `.claude/`.

## Why

Anything a chat figures out that isn't captured as a skill is lost when the
conversation ends, and re-derived next session — sometimes wrongly. This closes
that loop without automating skill sprawl: the agent does the *noticing*, the
human still *approves and owns* every `SKILL.md`.

## The three layers

| Layer | File | Role |
| --- | --- | --- |
| **Always-on RULE** | `rules/skill-self-improvement/RULE.md` | The base. Loaded every session. Owns the *WHEN* (triggers) and the approval *gate*. |
| **On-demand SKILL** | `skills/skill-maintenance/SKILL.md` | The *HOW*. Loaded when a proposal is being carried out: format, update-vs-create, patch/pinning/evidence. |
| **Turn-end hook** | `hooks/skill-gap-reminder.sh` | Enforcement nudge. Fires at every turn-end so the reflection actually happens; self-guarded against loops. |

The RULE is the load-bearing piece — a SKILL alone is on-demand and may never
fire; the always-on rule plus the hook guarantee the reflection happens.

## Install into a project

From the target repo root:

```bash
BP=/path/to/claude-skill-self-improvement

mkdir -p .claude/rules .claude/skills .claude/hooks
cp -R "$BP/rules/skill-self-improvement"   .claude/rules/
cp -R "$BP/skills/skill-maintenance"       .claude/skills/
cp     "$BP/hooks/skill-gap-reminder.sh"   .claude/hooks/
chmod +x .claude/hooks/skill-gap-reminder.sh
```

Then register the Stop hook in `.claude/settings.json`:

- **No settings.json yet?** Copy the snippet wholesale:

  ```bash
  cp "$BP/settings.snippet.json" .claude/settings.json
  ```

- **Already have one?** Merge the `hooks.Stop` array from `settings.snippet.json`
  into it (don't clobber existing hooks — append the entry).

Finally, make it discoverable from the always-loaded context (Claude Code does
not guarantee auto-loading `.claude/rules/`): add a line to your `AGENTS.md` or
`CLAUDE.md`, e.g.

```markdown
**Self-improving skills (always-on).** `.claude/rules/skill-self-improvement/RULE.md`
makes the agent propose a new or improved skill whenever a reusable gap or a wrong
skill surfaces — and never write a SKILL.md/RULE.md without explicit approval.
`skill-maintenance` is the procedure; a turn-end hook nudges the same reflection.
```

## Verify

```bash
# hook is valid bash
bash -n .claude/hooks/skill-gap-reminder.sh

# already-active payload -> no output, exits 0 (no infinite loop)
printf '{"stop_hook_active":true}' | bash .claude/hooks/skill-gap-reminder.sh; echo "exit=$?"

# fresh payload -> emits valid block JSON
printf '{}' | bash .claude/hooks/skill-gap-reminder.sh | python3 -m json.tool
```

Then run a throwaway Claude session: a trivial task should end with the hook
firing and **no** proposal (no spam); a task where you teach it a real
convention should end with exactly one well-formed proposal.

## Customize per project

- **Add domain-specific triggers/examples** to the RULE's "When to propose" and
  "Good / Bad" sections (e.g. name your API, your reviewer, your recurring
  patterns) — concrete examples make the triggers fire at the right moment.
- **Tighten the gate wording** if your repo has its own commit/approval norms.
- Keep one source of truth: if you also run other coding agents, project the
  same RULE into their always-on rule format rather than forking the content.

## Conventions baked in

- **Propose-then-confirm**: never write a `SKILL.md`/`RULE.md` without explicit
  approval specific to the skill action.
- **One proposal per chat**, only when a trigger clearly fires — no end-of-chat spam.
- **Patch over rewrite**, and improvement proposals **must cite evidence**.
- **`pinned: true`** in a skill's frontmatter → propose patches only, never archival.
- **Check existing skills first** to avoid near-duplicates.
