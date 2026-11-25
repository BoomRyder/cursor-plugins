The skill directories and `LICENSE` are copied from
https://github.com/mattpocock/skills at the commit recorded in `UPSTREAM.json`.

Copyright (c) 2026 Matt Pocock. MIT License. Do not edit those files here.
The Sync aihero GitHub Action updates them.

Cursor only discovers a skill when `skills/<name>/SKILL.md` is one level down.
Upstream keeps the same skills under `skills/engineering/` and `skills/productivity/`.
The sync copies each directory listed in upstream `.claude-plugin/plugin.json`
to `skills/<name>/`. The file bytes are unchanged. Skills under `in-progress/`
and `misc/` are not in that published list, so they are not included.
