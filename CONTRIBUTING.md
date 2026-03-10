# Contributing to tiktok-dev-plugin

Thanks for your interest in contributing! This plugin follows the [Claude Code plugin format](https://code.claude.com/docs/en/discover-plugins).

## How to Contribute

### Reporting Issues
Open a GitHub Issue with:
- What you expected vs what happened
- The TikTok API endpoint or feature involved
- Link to relevant TikTok docs if applicable

### Improving Skills
Each skill lives in `skills/<name>/SKILL.md`. To improve one:
1. Fork the repo
2. Edit the relevant `SKILL.md`
3. Test locally: `claude --plugin-dir ./` from your project
4. Submit a PR describing what you changed and why

### Adding a New Skill
1. Create `skills/your-skill-name/SKILL.md`
2. Add YAML frontmatter with `description:` (one line — shown to Claude at session start)
3. Register it in `.claude-plugin/plugin.json` under `"skills"`
4. Update `README.md`

### Skill Frontmatter Reference
```yaml
---
description: One-line description shown to Claude — be specific about when this activates
disable-model-invocation: true   # Optional: prevents Claude from auto-triggering
---
```

## Keeping Docs Accurate
If TikTok updates their API, please open a PR updating the relevant SKILL.md with:
- The new endpoint / field / behavior
- A link to the updated TikTok documentation page

## Code of Conduct
Be respectful. Focus on accuracy and developer experience.
