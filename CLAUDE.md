# Claude Code Reference

## Slash Commands & Agents

Both require YAML frontmatter with `description` (and `name` for agents).

- **Slash Commands:** https://docs.claude.com/en/docs/claude-code/slash-commands
- **Sub-Agents:** https://docs.claude.com/en/docs/claude-code/sub-agents

## Key Patterns

- Orchestrator + specialized agents to avoid context bloat
- Agents write to isolated files; orchestrator syncs to central checklist (prevents race conditions)
- Pre-plan commands in non-interactive agents; document blockers as issues
