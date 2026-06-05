#!/usr/bin/env bash
# Stop hook: nudge to capture reusable conventions as skills.
#
# Fires at turn-end. Guarded by `stop_hook_active` so it blocks at most once
# per stop sequence (one reflection per turn) — never an infinite loop.
#
# Reads the hook payload (JSON) on stdin. If we're already continuing because
# of this hook, allow the stop. Otherwise emit a one-time reminder that makes
# the model reflect on whether a skill should be proposed/updated.

input="$(cat)"

# Already re-woken by this hook? Let the turn end.
if printf '%s' "$input" | grep -q '"stop_hook_active"[[:space:]]*:[[:space:]]*true'; then
  exit 0
fi

cat <<'JSON'
{"decision":"block","reason":"Before ending the turn: did anything this turn reveal a REUSABLE, codebase-specific convention not yet captured in a skill — e.g. a PR review comment, a correction that came up more than once, or a non-obvious gotcha that cost real time? If yes, follow the always-on rule (.claude/rules/skill-self-improvement/RULE.md) and the skill-maintenance skill (.claude/skills/skill-maintenance/SKILL.md): propose updating an existing skill or creating a new one (propose-then-confirm), then finish. If no such gap, just end the turn normally — do NOT invent one-off or speculative skills."}
JSON
exit 0
