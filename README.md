# gtex62-doctor

`gtex62-doctor` is a standalone Conky suite built on the shared
[`gtex62-core`](../gtex62-core/README.md) engine model, following the same
suite/engine split as [`gtex62-osa`](../gtex62-osa/README.md) and
[`gtex62-sitrep`](../gtex62-sitrep/README.md).

Doctor is a single-panel health console for `gtex62-core` itself. One
alphabetical table covers all 21 provider domains (AIR, ALERTS, AP, ASTRO,
AVIATION, CALENDAR, CONNECT, GITHUB, MEDIA, MODEM, MTR, NET, NETWORK, ORB,
PFSENSE, PIHOLE, SOLAR, SYSTEM, TIME, VPN, WEATHER), beside a monitor
(DCM) that shows cache freshness at a glance and, when something is wrong,
the fix. The suite owns only the display; the engine's
`providers/doctor/fetch_doctor.sh` does all the checking. See
[`gtex62-core/docs/doctor-design.md`](../gtex62-core/docs/doctor-design.md) for
the full design.

## Table of Contents

- [Divergence from other suites](#divergence-from-other-suites)
- [Panels](#panels)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Runtime Model](#runtime-model)
- [Reading the Widget](#reading-the-widget)
- [Customization](#customization)
- [Troubleshooting](#troubleshooting)
- [Repository Layout](#repository-layout)
- [License](#license)

## Divergence from other suites

Doctor has no suite-specific rendering logic. Where SitRep and OSA each own a
distinct visual language over the domains they display, Doctor exists purely to
surface core's own health, so every suite benefits equally from anything core
learns to diagnose. It doesn't replace SitRep's alert banner (runtime
conditions like a gateway outage); it covers provider health and
config-completeness, and replaces the need for each suite to hand-maintain a
Doctor script (see the design doc's "Core Distinction: Suite Doctors vs. Core
Doctor").

## Panels

| Panel | Content |
| --- | --- |
| Header line | `NO HEALTH ALERTS` or `CHECK ACTIONS (N)`, with the local date/time. Reads `DOCTOR STALE - <N>S` if the provider stops updating |
| DCM | Digital Core Monitor. Idle: one vertical gauge per eligible domain, TTL on top, AGE against that TTL. Active: full takeover by one entry per condition (domain, condition, fixed action line, `PROC:` line), scrolling one whole entry at a time when more are active than fit |
| RUNTIME | The six roots: config, data, cache, assets, suites, media |
| CONFIG | Time zone, lat, lon, and whether the OpenWeather and AirNow keys are set (never the keys) |
| PROVIDERS | `DOMAIN \| STATE \| TTL \| AGE \| NOTE` for every domain, plus one reserved blank row and the pointer to README § Provider Toggles in `gtex62-core` |

## Requirements

- Conky with Lua and Cairo support, for example `conky-all`
- `bash`, `jq`, `python3` (3.11 or newer recommended; `jq` and `python3` are
  checked at launch), `lua`
- The fonts `GTex62 OSA` and `Eurostile LT Std` from
  `gtex62-shared-assets` (core's `scripts/install-fonts.sh` installs them)
- `feh`, only if you want the launcher to apply shared wallpapers

Repositories expected side by side:

```text
~/.config/conky/
├── gtex62-core/
├── gtex62-doctor/
└── gtex62-shared-assets/
```

## Quick Start

```bash
~/.config/conky/gtex62-doctor/scripts/start-conky.sh
```

The script stops any old Doctor window, installs the runtime templates if
`suites/doctor.toml` is missing, asks for a palette and a wallpaper (Enter
keeps the last choice), then starts `gtex62-core-launch --suite doctor`.

## Configuration

Everything lives in `~/.config/gtex62-core/`:

- **`core.toml` `[doctor] enabled = true`** turns the provider on. It only runs
  for a suite that lists `"doctor"` in its `[domains]`, which this one does.
- **`suites/doctor.toml`** is installed from
  `gtex62-core/examples/runtime/suites/doctor.toml.example` by the bootstrap.
  It names a profile for every domain and lists them under `[domains]`.
  Listing `vpn`, `ap`, `modem`, `alerts`, `mtr` and `pihole` there is what lets
  a Doctor launch keep those providers running when they are enabled in
  `core.toml [providers]`. Edit the installed copy: bootstrap never overwrites
  an existing file.
- **Provider toggles** stay in `core.toml [providers]`; a domain that is turned
  off shows as DISABLED, not as a fault.

Launching Doctor starts every provider that is enabled in `core.toml`, the same
as any other suite. Running it beside SitRep or OSA means two launchers drive
the same shared cache; each provider's own skip-if-fresh check keeps them from
double-fetching.

## Runtime Model

- **`fetch_doctor.sh`** runs every 5s in the launcher, reads every other
  domain's cache and profile, and writes
  `~/.cache/gtex62-core/shared/doctor/<profile>/status.json`. STATE, NOTE and
  the DCM entries come from there.
- **The widget** redraws every second. AGE and the DCM gauges tick live: it
  re-reads the cache files' modification times once a second, so a provider
  refreshing shows immediately. For up to one provider run, an AGE past its TTL
  can display before that row's STATE follows.
- **Liveness:** if `status.json` is more than 30s old, the header line says
  `DOCTOR STALE`; if it is missing, `NO DATA`.

## Reading the Widget

**STATE** — `NOMINAL` (fresh, within TTL), `WARN` (stale, or the provider
reports a non-ok state), `DISABLED` (turned off by design), `PRIVATE` (GITHUB,
maintainer-only), `HYBRID` (some, not all, of PFSENSE's four sub-flags
enabled, everything healthy), and MTR's own `IDLE` / `ARMED` / `RUNNING`.
A row goes WARN when its age passes its TTL by more than 5s.

**NOTE** — a short pointer only: `ERROR`, `DEGRADED`, `PARTIAL`, `WAITING`,
`STALE`, `MISSING` or `REFRESH`, with a trailing `+` when more than one applies.
A row whose NOTE carries one of these is highlighted (filled), whatever its
STATE says. `MISSING` beside a NOMINAL row means the domain is running on the
launcher's fallback cadence because its profile lacks the TTL key.

**TTL and AGE** — TTL is plain seconds, or `ON DEMAND` (CONNECT), `TIMER`
(GITHUB), `WRITE` (MEDIA), `TRIGGER` (MTR) or `VARIES` (PFSENSE). AGE is seconds
for fast domains and a `HH:MM:SSZ` (UTC) timestamp for the rest. NET, SYSTEM and
TIME (1s TTL) leave AGE blank.

**DCM entries** name a procedure in the Quick Reference Handbook
([`docs/doctor-qrh.md`](docs/doctor-qrh.md)); the fixed one-line action shown on
screen comes from `lua/lib/qrh.lua`, and the long form is the procedure titled
by the entry's `PROC:` line.

## Customization

- **Scale:** `layout.scale` in `theme/layout.lua` (1.00 by default; a scale
  change needs a restart). Geometry is authored on an 8px grid so it stays
  crisp at 1.25.
- **Palette:** chosen at launch, or set `CONKY_DOCTOR_PALETTE`. The catalog is
  `theme/palettes.lua`.
- **Monitor:** `theme.monitor_head` in `theme/theme.lua`. The window is centered
  (`middle_middle`) in `widgets/doctor-main.conky.conf`.
- **DCM:** `theme.dcm.idle.edge_gap` (gauge margin at the box edges, as a
  multiple of the gauge-to-gauge gap) and `theme.dcm.active.scroll_interval_sec`.

## Troubleshooting

| Symptom | Check |
| --- | --- |
| `NO DATA` in the header | Provider not running: `[doctor] enabled = true` in `core.toml`, and `"doctor"` in the `[domains]` of `suites/doctor.toml`. Run the bootstrap if that file is missing |
| `DOCTOR STALE - <N>S` | `fetch_doctor.sh` has stopped: check the launcher is still running |
| A row shows `MISSING` with a NOMINAL STATE | The profile lacks its TTL key; add it and restart the suite (PROC: `FALLBACK TTL`, or `NET`/`ORB`/`ASTRO FALLBACK TTL`) |
| A row is `STALE` right after restarting a suite | Expected once: cadence realigns within one TTL |
| Squares or missing characters | The `GTex62 OSA` font is not installed; the data font has no lowercase glyphs and no `§`, so all text is uppercase |

## Repository Layout

```text
gtex62-doctor/
├── CLAUDE.md          # Project instructions
├── design/            # Previz images (not tracked)
├── docs/
│   └── doctor-qrh.md  # Quick Reference Handbook: one procedure per condition
├── lua/
│   ├── lib/           # json.lua decoder, qrh.lua (DCM action text)
│   ├── suite/         # doctor.lua: status.json -> box view models; runtime.lua
│   ├── ui/            # frame.lua: chassis and box drawing
│   └── widgets/       # doctor_main.lua: conky_draw_doctor entrypoint
├── screenshots/
├── scripts/           # start-conky.sh, bootstrap-runtime-root.sh, check-qrh-links.py
├── theme/             # palettes, layout, panels, theme
├── widgets/           # doctor-main.conky.conf
├── suite.toml
└── LICENSE
```

After editing the QRH, run `scripts/check-qrh-links.py`; its outline links depend
on heading order.

## License

MIT — see [LICENSE](LICENSE).
