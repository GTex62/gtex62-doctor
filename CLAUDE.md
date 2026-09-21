# gtex62-doctor — Project Instructions

## Two Repos — Always Separate

This project spans two git repos. Identify which owns each file before editing.
Commit and push each repo independently.

- Suite: `~/.config/conky/gtex62-doctor/`
- Engine: `~/.config/conky/gtex62-core/`

Doctor is a display-only suite — it has nothing of its own to diagnose that
isn't already core state. Any new health check belongs in core's
`providers/doctor/fetch_doctor.sh`, not in this repo's Lua.

## Reference Suites

Use `gtex62-sitrep` and `gtex62-osa` as architectural references for
directory layout, `suite.toml` shape, and drawing conventions
(`lua/ui/frame.lua` chassis idiom, `lua/suite/*.lua` per-domain data
modules). Do not copy patterns from `gtex62-tech-hud` or `gtex62-tri-hud` —
those are legacy, pre-core-native suites being superseded; the design doc
cites their old Doctor scripts only for the conceptual state vocabulary and
remediation-table idea, not as code to port.

## Hard Rules

- Do not refactor while fixing a bug. Smallest safe change only.
- Do not rename files, dirs, or public paths unless explicitly requested.
- Commit messages: follow whatever AI attribution the current session's own
  instructions specify — that's changed over time, so don't hardcode a
  specific rule here.

## Bootstrap Gap

When a new provider is added to core, its profile TOML must be installed:

```bash
bash ~/.config/conky/gtex62-core/bin/gtex62-core-bootstrap-runtime
```

Missing profile TOML → 60s TTL fallback → meters appear frozen.

This section covers a genuinely absent profile file only. Bootstrap skips a file
that already exists, so it does not fix a profile that exists but lacks required
keys (e.g. `[cache] ttl_sec`) — see the NET/ORB/ASTRO rows in `doctor-design.md`'s
remediation table and the matching entries in `docs/doctor-qrh.md`.

## Full Project Docs

- `gtex62-core/docs/doctor-design.md` — full design: state vocabulary,
  provider table layout, NOTE/remediation tables, repo scaffold plan
- `gtex62-core/docs/doctor-missing-conditions.md` — per-domain verification
  evidence behind the remediation table
- `gtex62-doctor/docs/doctor-qrh.md` — the QRH: one full remediation
  procedure per condition, titled with the exact string a DCM `PROC:` line
  names (lives in this repo, not core)
