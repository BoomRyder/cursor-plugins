The files in `skills/`, `hooks/`, `.cursor/rules/`, and `LICENSE` are copied
verbatim from https://github.com/DietrichGebert/ponytail at the commit recorded
in `UPSTREAM.json`.

Copyright (c) 2026 DietrichGebert. Those files stay under the upstream MIT license.
Do not edit them in this repository. Update them with `scripts/sync-ponytail.ps1`.

This Cursor package does not load `.cursor/rules/ponytail.mdc` as a plugin rule.
Upstream treats that always-on rule and the session hooks as two different Cursor
installs: the rule cannot be turned off, and the hooks are what switch lite, full,
ultra, and off. The plugin uses the hooks.
