# Contributing

Thanks for contributing to Intent++.

## Development principles

- Keep it CLI first.
- Keep skills deterministic and artifact driven.
- Avoid context bloat. Prefer short instructions and executable checks.
- Keep research and planning separate from implementation.

## Local testing

Claude Code supports local plugin loading via `--plugin-dir`.

Example:

- `cd /path/to/your-project`
- `claude --plugin-dir /path/to/intent-plus-plus`

Then invoke:

- `/intent-plus-plus:presearch`
- `/intent-plus-plus:deepplan`

## Script style

- bash scripts must pass `shellcheck`
- prefer `set -euo pipefail`
- keep scripts composable, grep-friendly, and toolable

## Release process

1) Update `.claude-plugin/plugin.json` version
2) Update `CHANGELOG.md`
3) Tag the release in git
