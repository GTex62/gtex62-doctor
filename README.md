# gtex62-doctor

`gtex62-doctor` is a standalone Conky suite built on the shared
[`gtex62-core`](../gtex62-core/README.md) engine model, following the same
suite/engine split as [`gtex62-osa`](../gtex62-osa/README.md) and
[`gtex62-sitrep`](../gtex62-sitrep/README.md).

Doctor is a single-panel health console for `gtex62-core` itself: one
alphabetical table covering every provider domain (AIR, ALERTS, AP, ASTRO,
AVIATION, CALENDAR, CONNECT, GITHUB, MEDIA, MODEM, MTR, NET, NETWORK, ORB,
PFSENSE, SOLAR, SYSTEM, TIME, VPN, WEATHER), an alert banner for
config-completeness and provider-health conditions, and a runtime/config
summary — see
[`gtex62-core/docs/doctor-design.md`](../gtex62-core/docs/doctor-design.md)
for the full design.

## Divergence from other suites

Doctor has no suite-specific rendering logic. Where SitRep and OSA each own a
distinct visual language and panel composition over the domains they display,
Doctor exists purely to surface core's own health — there is no mode
submenu, and no palette/wallpaper submenus until the core-launcher
consolidation work lands, matching SitRep's own current scope. Every suite
(including this one) benefits equally from anything core learns to diagnose;
Doctor doesn't compete with SitRep or OSA's own Doctor-shaped checks, it
replaces the need for each suite to hand-maintain one (see the design doc's
"Core Distinction: Suite Doctors vs. Core Doctor" section).

## Status

Chassis, launcher and all four boxes are built against core's
`shared/doctor/{profile}/status.json` (written by `providers/doctor/fetch_doctor.sh`):
DCM (idle gauges / active QRH-style entries), RUNTIME, CONFIG and PROVIDERS. DCM's fixed
action text lives in `lua/lib/qrh.lua`, keyed by the QRH procedure titles in
[`docs/doctor-qrh.md`](docs/doctor-qrh.md).

## Repository Layout

```text
gtex62-doctor/
├── design/            # Previz images, design notes
├── docs/              # Suite-local docs
├── lua/
│   ├── lib/           # json decoder, QRH text table
│   ├── suite/          # doctor.lua: status.json -> box view models
│   ├── ui/             # frame.lua: chassis + box drawing
│   └── widgets/        # doctor_main.lua: conky_draw_doctor entrypoint
├── screenshots/        # Captures for README/docs
├── scripts/            # start-conky.sh, bootstrap, QRH link checker
├── theme/              # Palette catalog, layout, panel geometry
├── widgets/             # doctor-main.conky.conf
├── suite.toml
└── LICENSE
```

## License

MIT — see [LICENSE](LICENSE).
