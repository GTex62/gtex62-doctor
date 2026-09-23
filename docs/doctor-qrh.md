<!-- markdownlint-disable MD033 MD036 -->
<!-- MD036 is off for this file: the bold procedure title is the QRH boxed-title convention, deliberately not a heading. MD033 is off because each title carries an <a id> anchor so the outline and index can link to it. -->

# gtex62-doctor — Quick Reference Handbook (QRH)

The remediation reference behind DCM's `PROC:` lines. One procedure per condition
`gtex62-doctor` can raise, each titled with the exact string a DCM entry's `PROC:` line
names — search the title, land on the procedure. Companion to
[`doctor-design.md`](../../gtex62-core/docs/doctor-design.md) (state vocabulary, DCM, and the
one-line Actions / Remediation table this document expands) and
[`doctor-missing-conditions.md`](../../gtex62-core/docs/doctor-missing-conditions.md) (the
per-domain verification evidence behind it).

**Status (2026-09-20): reference for a design-only suite.** `gtex62-doctor` has no
commits yet, so nothing here describes behavior that exists in the Doctor repo today. The
provider behavior each procedure cites — `note` text, `state` values, launcher defaults,
timer settings — is the verified behavior recorded in `doctor-missing-conditions.md`,
re-checked against `bin/gtex62-core-launch` and `bin/gtex62-core-bootstrap-runtime` where a
procedure depends on them.

---

## How to Read This Handbook

The DCM entry is the short form: a condition line, a fixed action line, and a `PROC:` line.
This document is the long form that `PROC:` line points to. No color: the project has no
dedicated severity-color layer (OSA, SitRep and Doctor share one palette), so every ECAM/QRH
convention that paper QRHs carry in color is carried here in plain markdown instead.

| QRH convention | Form in this document |
| --- | --- |
| Boxed procedure title | **BOLD CAPS** — the string a `PROC:` line names |
| Conditional / branching statement | A literal ● followed by `IF …` |
| Action line | `-ACTION.....VALUE`, dot-leadered, in a fenced block |
| Exact field / value names | Code spans — `connectivity_state.status`, `state:"degraded"` |
| Indications | **Indications:** line right after the title — the STATE / NOTE combination and DCM entry text that lead here |
| NOTE | Blockquote labeled **NOTE:** — context: background, disambiguation, a nearby case that is *not* this procedure |
| CAUTION | Blockquote labeled **CAUTION:** — a risk in the fix or in inaction: an action that can destroy data or will silently fail to take effect if done as written, or a consequence that becomes irreversible if the condition is ignored |
| Related procedure | `PROC: <NAME>` line |
| Closing line | `[End of Procedure]`, then a `---` rule — on every procedure, even where a category or chapter break already follows |

**Structure.** `## DOMAIN` (subchapter) → `### Condition category` (section) → **PROCEDURE
TITLE**. Categories used:

| Category | What it covers |
| --- | --- |
| Configuration | A required setting is missing or still a placeholder |
| Enablement | Enabled, but the profile TOML / bootstrap step behind it is incomplete |
| Cache Staleness | The cache is missing, never written, or past its TTL with no reason given |
| Source Failure | An upstream fetch is failing |
| Silent Gaps | Conditions that used to leave `state:"ok"` with nothing pointing at them. All ten were closed at the source (2026-09-17): the provider now raises `state:"degraded"` itself, so these appear as `DEGRADED` like any other |
| SSH Gate | The domain's own SSH gate tripped |
| Dependency | Something owned by another domain or by the filesystem is what's missing |
| Refresh Deadline | A time-limited copy obligation (GITHUB only) |

**Indications.** Each procedure opens with an **Indications:** line saying what a reader sees that leads there: the row's STATE / NOTE, and the DCM entry text. Both come from the Actions / Remediation table in `doctor-design.md`, not from new wording. The DCM text is quoted from the table's action text — the fixed remediation DCM shows — cut at the first clause where the table text runs on. Every actionable NOTE highlights its row, raises a DCM entry and moves the header to `CHECK ACTIONS (N)`. GITHUB's STATE is hardcoded PRIVATE, so its rows show PRIVATE beside the NOTE, and an ORB or ASTRO fallback row reads NOMINAL beside MISSING — STATE follows AGE and the provider's own state, never a Doctor-derived flag. Where the design does not establish a DCM entry (config-completeness conditions), the line says so rather than supplying one.

**NOTE and CAUTION.** A NOTE is context. A CAUTION is reserved for a risk in the fix or in inaction — the `--force` overwrite on the fallback procedures is the model for the first, GITHUB REFRESH's 14-day window for the second. A warning that only steers the reader off the wrong procedure is a NOTE.

**Order within a category.** Procedures in each `###` section run most severe first, by the tier of the NOTE tag that raises the row (the tag is what highlights a row and triggers DCM; STATE cannot be the key, since GITHUB's is always PRIVATE and a fallback `MISSING` row can read NOMINAL). Within a tier, procedures keep their order.

| Tier | Tag / kind | Meaning |
| --- | --- | --- |
| 1 | `ERROR`, `DEGRADED` (and `PARTIAL`, the provider-reported fault state AIR alone uses) | A provider-reported fault is driving the row |
| 2 | `MISSING`, `STALE` (and `WAITING`, a wait on another domain) | The cache is absent or stale, or a domain is waiting on another |
| 3 | Informational: config-completeness alerts, and the deadline-not-yet-broken case (GITHUB `REFRESH`) | Nothing is broken yet, or nothing is broken at all |

**Tier and CAUTION are independent axes.** Tier marks current urgency — how much is broken right now. CAUTION marks consequence — a risk in the fix, or in ignoring the condition. A procedure can carry a serious CAUTION and still be low-urgency today, and a CAUTION never changes a procedure's tier. GITHUB `REFRESH` is the example: it is deliberately a softer signal than `STALE` — nothing is broken and the 4-day buffer is still open — so it is Tier 3, yet it carries a CAUTION because ignoring it past the 14-day window loses data for good. That is the two axes disagreeing on purpose, not a contradiction or an exception.

The Procedure Index at the end is purely alphabetical — a lookup tool, not a severity one.

**One tag, several causes.** A NOTE tag is a fast-scan pointer, not an explanation
(`ERROR` alone covers three AIR conditions). Every ● branch below keys off the provider's own
`note` text, the same match DCM uses to pick which procedure to show.

**More than one reason at once.** A provider can carry several `note` fragments in one poll
(MODEM's three `DEGRADED` reasons can all fire together). Run every procedure whose
`note` prefix appears.

**A `PROC:` inside a procedure is a hand-off.** Finish or rule out the referenced
procedure; it is not a step you can skip.

Two navigation aids: the [Outline by Domain](#outline-by-domain) browses every condition for a
domain; the [Procedure Index](#procedure-index) at the end jumps straight to a title.

**Maintenance:** the outline's category links use GitHub's auto-numbered duplicate-heading anchors (`#configuration`, `#configuration-1`, …), which depend on heading order — any added, removed or reordered chapter or category shifts them, so re-run `scripts/check-qrh-links.py` before trusting the outline again.

Titles are the interface. Renaming one breaks the `PROC:` line that names it, so a rename
changes the DCM text and this document together — the same rule as README § Provider Toggles.

---

## Outline by Domain

Browse every known condition for a domain: chapter → condition category → procedure. Titles
link to their procedures. To jump straight from a DCM `PROC:` line, use the
[Procedure Index](#procedure-index) at the end. Conditions deliberately without a procedure
are listed under [Deliberately Absent](#deliberately-absent).

- [GENERIC](#generic)
  - [Enablement](#enablement)
    - [PROFILE TOML MISSING](#profile-toml-missing)
    - [DOMAIN NOT LISTED](#domain-not-listed)
    - [FALLBACK TTL](#fallback-ttl)
  - [Cache Staleness](#cache-staleness)
    - [PROVIDER STALE](#provider-stale)
  - [Configuration](#configuration)
    - [CONFIG VALUE UNSET](#config-value-unset)
  - [Source Failure](#source-failure)
    - [UNRECOGNIZED NOTE](#unrecognized-note)
- [AIR](#air)
  - [Configuration](#configuration-1)
    - [AIR COORDINATES MISSING](#air-coordinates-missing)
    - [AIR API KEY MISSING](#air-api-key-missing)
  - [Source Failure](#source-failure-1)
    - [AIR NO CACHE](#air-no-cache)
    - [AIR NO TIMESTAMP](#air-no-timestamp)
  - [Silent Gaps](#silent-gaps)
    - [AIR OPENWEATHER DEGRADED](#air-openweather-degraded)
    - [AIR AIRNOW DEGRADED](#air-airnow-degraded)
- [ALERTS](#alerts)
  - [Cache Staleness](#cache-staleness-1)
    - [ALERTS NOT RUNNING](#alerts-not-running)
- [AP](#ap)
  - [Configuration](#configuration-2)
    - [AP NO IPS CONFIGURED](#ap-no-ips-configured)
    - [AP PASSWORD FILE MISSING](#ap-password-file-missing)
  - [SSH Gate](#ssh-gate)
    - [AP SSH GATE](#ap-ssh-gate)
- [ASTRO](#astro)
  - [Configuration](#configuration-3)
    - [ASTRO LOCATION MISSING](#astro-location-missing)
  - [Enablement](#enablement-1)
    - [ASTRO FALLBACK TTL](#astro-fallback-ttl)
- [AVIATION](#aviation)
  - [Source Failure](#source-failure-2)
    - [AVIATION DEGRADED](#aviation-degraded)
    - [AVIATION NO CACHE](#aviation-no-cache)
- [CALENDAR](#calendar)
  - [Cache Staleness](#cache-staleness-2)
    - [CALENDAR NEVER RUN](#calendar-never-run)
- [CONNECT](#connect)
  - [Silent Gaps](#silent-gaps-1)
    - [CONNECT SPEEDTEST FAILING](#connect-speedtest-failing)
  - [Cache Staleness](#cache-staleness-3)
    - [CONNECT SPEEDTEST STALE](#connect-speedtest-stale)
- [GITHUB](#github)
  - [Configuration](#configuration-4)
    - [GITHUB REGISTRY EMPTY](#github-registry-empty)
  - [Source Failure](#source-failure-3)
    - [GITHUB FETCH FAILING](#github-fetch-failing)
  - [Cache Staleness](#cache-staleness-4)
    - [GITHUB NEVER RUN](#github-never-run)
  - [Refresh Deadline](#refresh-deadline)
    - [GITHUB REFRESH](#github-refresh)
- [MEDIA](#media)
  - [Dependency](#dependency)
    - [MEDIA LOCAL DIR UNREACHABLE](#media-local-dir-unreachable)
- [MODEM](#modem)
  - [Configuration](#configuration-5)
    - [MODEM PASSWORD NOT SET](#modem-password-not-set)
  - [Source Failure](#source-failure-4)
    - [MODEM UNREACHABLE](#modem-unreachable)
    - [MODEM AUTH FAILED](#modem-auth-failed)
  - [Silent Gaps](#silent-gaps-2)
    - [MODEM CONN DEGRADED](#modem-conn-degraded)
    - [MODEM HEADER MAPPING](#modem-header-mapping)
    - [MODEM NO UPSTREAM LOCK](#modem-no-upstream-lock)
- [MTR](#mtr)
  - [Configuration](#configuration-6)
    - [MTR NO SSH TARGET](#mtr-no-ssh-target)
  - [SSH Gate](#ssh-gate-1)
    - [MTR SSH GATE](#mtr-ssh-gate)
- [NET](#net)
  - [Enablement](#enablement-2)
    - [NET FALLBACK TTL](#net-fallback-ttl)
  - [Cache Staleness](#cache-staleness-5)
    - [NET NOT RUNNING](#net-not-running)
- [NETWORK](#network)
  - [Silent Gaps](#silent-gaps-3)
    - [NETWORK NULL FIELDS](#network-null-fields)
- [ORB](#orb)
  - [Enablement](#enablement-3)
    - [ORB FALLBACK TTL](#orb-fallback-ttl)
- [PFSENSE](#pfsense)
  - [Configuration](#configuration-7)
    - [PFSENSE NO SSH TARGET](#pfsense-no-ssh-target)
  - [Source Failure](#source-failure-5)
    - [PFSENSE SUBCACHE DEGRADED](#pfsense-subcache-degraded)
  - [SSH Gate](#ssh-gate-2)
    - [PFSENSE SSH GATE](#pfsense-ssh-gate)
  - [Cache Staleness](#cache-staleness-6)
    - [PFSENSE SUBCACHE STALE](#pfsense-subcache-stale)
- [PIHOLE](#pihole)
  - [Configuration](#configuration-8)
    - [PIHOLE NO SSH TARGET](#pihole-no-ssh-target)
  - [SSH Gate](#ssh-gate-3)
    - [PIHOLE SSH GATE](#pihole-ssh-gate)
- [SOLAR](#solar)
  - [Dependency](#dependency-1)
    - [SOLAR WAITING](#solar-waiting)
- [SYSTEM](#system)
  - [Cache Staleness](#cache-staleness-7)
    - [SYSTEM NOT RUNNING](#system-not-running)
- [TIME](#time)
  - [Cache Staleness](#cache-staleness-8)
    - [TIME NOT RUNNING](#time-not-running)
- [VPN](#vpn)
  - [Configuration](#configuration-9)
    - [VPN PIACTL MISSING](#vpn-piactl-missing)
  - [Silent Gaps](#silent-gaps-4)
    - [VPN WG STATS DEGRADED](#vpn-wg-stats-degraded)
    - [VPN TUNNEL PING DEGRADED](#vpn-tunnel-ping-degraded)
- [WEATHER](#weather)
  - [Configuration](#configuration-10)
    - [WEATHER CONFIG MISSING](#weather-config-missing)
  - [Source Failure](#source-failure-6)
    - [WEATHER DEGRADED](#weather-degraded)
    - [WEATHER NO CACHE](#weather-no-cache)

---

## GENERIC

Procedures more than one domain points to, taken from the generic fallback shape in
Actions / Remediation. A domain with its own procedure uses that one instead.

### Enablement

<a id="profile-toml-missing"></a>**PROFILE TOML MISSING**

**Indications:** any enabled domain's row shows WARN / ERROR with `note:"missing profile toml"`; DCM entry reads the generic text "Add `<domain>.toml.example` under `examples/runtime/`, rerun bootstrap".

`ERROR` — `state:"error"`, `note:"missing profile toml"`. The domain is enabled, but
`profiles/<domain>/<profile>.toml` was never installed under the runtime root
(`~/.config/gtex62-core/`). Most domains check for this explicitly and say so; the ones that
don't are listed below.

● IF the domain ships a `.toml.example` under `examples/runtime/profiles/<domain>/`:

```text
-RERUN BOOTSTRAP.......................bin/gtex62-core-bootstrap-runtime
```

● IF the domain has no `.toml.example` (a newly added provider):

```text
-ADD EXAMPLE...examples/runtime/profiles/<domain>/<profile>.toml.example
-RERUN BOOTSTRAP.......................bin/gtex62-core-bootstrap-runtime
```

> **NOTE:** Bootstrap skips any file that already exists (`skip  <path>`) unless run with
> `--force`. That makes it the right fix for a file that is *absent*, which is this
> procedure. It does nothing for a file that is present but incomplete — see PROC: NET
> FALLBACK TTL.
>
> **NOTE:** These do not raise this procedure. NET never checks for its profile (PROC: NET
> FALLBACK TTL). ORB is not confirmed either way (PROC: ORB FALLBACK TTL). AP has no
> missing-profile path at all. GITHUB proceeds on in-script defaults, harmlessly. MTR reads a
> missing profile as `state:"disabled"`, so it shows DISABLED, not `ERROR`.

[End of Procedure]

---

<a id="domain-not-listed"></a>**DOMAIN NOT LISTED**

**Indications:** a VPN, AP, MODEM, ALERTS, MTR or PIHOLE row shows WARN / MISSING or STALE while its `core.toml [providers]` flag is `true`; DCM entry reads "`<DOMAIN>` is enabled in `core.toml` but not listed in `[domains]` of `suites/doctor.toml` — add it, or the launcher never starts it."

`MISSING` or `STALE` — the flag is on but the cache is absent or old, and the launching
suite's `[domains]` list omits the domain. Those six domains are dual-gated: the launcher
starts a fetch loop only when the `core.toml` flag is `true` **and** the suite lists the
domain, so a domain the suite omits never gets one. Nobody turned it off, which is why the
row is not DISABLED. It keeps whatever STATE and NOTE the cache gives it (WARN, `MISSING` or
`STALE`); only the cause changes.

● IF Doctor should poll the domain:

```text
-EDIT FILE......~/.config/gtex62-core/suites/doctor.toml, [domains]
-ADD DOMAIN.............................to `required` or `optional`
-RESTART SUITE.....................launcher reads [domains] once, at startup
```

● IF Doctor should not poll it and another suite's launcher already keeps its cache fresh:

```text
-NO ACTION..................the row is NOMINAL while that cache is fresh
```

● IF the domain is not wanted at all:

```text
-SET FLAG.............core.toml [providers] <domain> = false, then restart
```

> **CAUTION:** Edit the installed `suites/doctor.toml` under the runtime root, not
> `examples/runtime/suites/doctor.toml.example`. Bootstrap skips a file that already exists
> (`skip  <path>`), so a change to the example never reaches an installed runtime.
>
> **NOTE:** Doctor can only read its own launching suite's list (`suites/doctor.toml`). It
> has no view of which domains any other suite's launcher started.
>
> **NOTE:** Listing a domain makes a Doctor launch start that provider's poller, with the
> same SSH and scrape load as any other suite that lists it.

```text
PROC: PROVIDER STALE
```

[End of Procedure]

---

<a id="fallback-ttl"></a>**FALLBACK TTL**

**Indications:** a row shows `MISSING` — any domain except NET, ORB and ASTRO, which have their own procedures; the TTL cell reads the intended value while the launcher runs the domain on its default; DCM entry reads "`<DOMAIN>` profile TOML has no `<key>` — running on the launcher's default cadence, not the configured one."

`MISSING` — the domain's profile TOML exists but lacks the key the launcher parses its TTL
from. `bin/gtex62-core-launch` reads that key with `awk`; an absent key returns empty and the
launcher's bash default (`<DOMAIN>_TTL="${<DOMAIN>_TTL:-N}"`) silently takes over the
`refresh_loop` cadence. `status.json` still reports `state:"ok"` and nothing else notices.
Doctor detects it by reading the profile, and shows the *intended* TTL beside the flag
(never the fallback), so the TTL cell alone cannot confirm the real cadence.

| Domain | Key the launcher parses | Launcher default | Shipped example |
| --- | --- | --- | --- |
| AIR | `[cache] ttl_sec` | 900s | 900 |
| AVIATION | `[cache] metar_ttl_sec`, `taf_ttl_sec` | 600s | 600 |
| CALENDAR | `[events] cache_ttl_sec` (the TTL Doctor reports) | — | 86400 |
| MODEM | `cache_ttl_sec` | 300s | 300 |
| MTR | `cache_ttl_sec` | 15s | 15 |
| NETWORK | `[cache] refresh_sec` | 5s | 5 |
| PFSENSE | `cache_ttl_sec` | 5s | 1 |
| PIHOLE | `[pihole] cache_ttl_sec` | 300s | 60 |
| SOLAR | `[cache] refresh_sec` | 300s | 300 |
| SYSTEM | `[cache] refresh_sec` | 1s | 1 |
| TIME | `[cache] refresh_sec` | 1s | 1 |
| VPN | `cache_ttl_sec` | 10s | 10 |
| WEATHER | `[request] cache_ttl_sec` | 300s | 300 |

● IF the fetch script reports `state:"error"`, `note:"missing profile toml"` — the file is
absent, not incomplete: this is not the procedure.

```text
PROC: PROFILE TOML MISSING
```

● IF the profile exists but lacks the key:

```text
-ADD KEY.............................the key above, shipped-example value
-RESTART SUITE......................launcher reads TTLs once, at startup
```

> **CAUTION:** Bootstrap will not fix this. It skips a file that already exists
> (`skip  <path>`), and `--force` overwrites the whole profile, discarding local edits.
>
> **CAUTION:** The restart is not optional. The launcher parses each TTL once, at startup,
> and passes it to `refresh_loop` for the life of the process. A repaired profile does not
> change a running loop.

```text
PROC: NET FALLBACK TTL
PROC: ORB FALLBACK TTL
PROC: ASTRO FALLBACK TTL
```

[End of Procedure]

---

### Cache Staleness

<a id="provider-stale"></a>**PROVIDER STALE**

**Indications:** any row shows WARN / STALE with the provider still reporting `state:"ok"` and no `degraded`; DCM entry reads the generic text "Check API key / network reachability for `<domain>`".

`STALE` — the cache is older than the domain's TTL while `status.json` still says
`state:"ok"`. Doctor-derived; the provider has not reported anything wrong, so there is no
`note` to key off.

```text
-API KEY...........................................................CHECK
-NETWORK REACHABILITY..............................................CHECK
```

> **NOTE:** Several domains have a better answer than this one. ALERTS has no API, so "check
> the API key" would be wrong for it. CALENDAR reads local files only. NET, SYSTEM and TIME
> at a 1s TTL mean a dead loop. PFSENSE is a family of sub-caches. GITHUB never uses `STALE`.
> Use the domain's own procedure.

```text
PROC: ALERTS NOT RUNNING
PROC: CALENDAR NEVER RUN
PROC: NET NOT RUNNING
PROC: SYSTEM NOT RUNNING
PROC: TIME NOT RUNNING
PROC: PFSENSE SUBCACHE STALE
PROC: CONNECT SPEEDTEST STALE
```

[End of Procedure]

---

### Configuration

<a id="config-value-unset"></a>**CONFIG VALUE UNSET**

**Indications:** no row NOTE — a config variable that is present but still a placeholder (`LAT=`, `LON=-`) raises none, so the row does not highlight. Whether DCM raises an entry for it is an open question (`doctor-design.md`, Open Questions — DCM active-state details); if it does, the generic text is "Edit `<file>`, set `<var>`".

A config variable is present but still a placeholder (`LAT=`, `LON=-`). This is a
config-completeness alert: checked once when the file is read, not recomputed against a
threshold.

```text
-EDIT FILE.................................<file named in the DCM entry>
-SET VARIABLE...............................<var named in the DCM entry>
```

> **NOTE:** A config-completeness condition has no row NOTE. Whether DCM raises an entry for
> one is an open question in `doctor-design.md` (Open Questions, DCM active-state details).

[End of Procedure]

---

### Source Failure

<a id="unrecognized-note"></a>**UNRECOGNIZED NOTE**

**Indications:** any row shows WARN with `ERROR`, `DEGRADED`, `PARTIAL` or `WAITING` and the provider's own `note` matches no condition Doctor knows; DCM entry reads "`<DOMAIN>` reports `<TAG>`: `<the provider's note, verbatim>`" — the generic fallback entry.

The provider reported a non-ok `state` and its `note` matches no known condition, so no
domain procedure applies. Typically a failure path added to a fetch script after the design
pass, or a note whose wording changed. The row is still WARN and highlighted: the provider's
own `state` is trustworthy, only the cause is unmapped.

```text
-READ NOTE.............shared/<domain>/<profile>/status.json, `note`
-FIND WRITER.......................providers/<domain>/, where it is written
```

● IF the note names a fixable cause (a credential, a path, a missing tool):

```text
-FIX CAUSE........................the row clears on the next fetch cycle
```

● IF the condition is real and recurring:

```text
-RECORD CONDITION......doctor-missing-conditions.md, then doctor-design.md's Actions table
-ADD PROCEDURE.......................this handbook, titled `<DOMAIN> <CONDITION>`
-ADD MATCH...............providers/doctor/fetch_doctor.sh, the note needle
```

> **NOTE:** Every domain-specific procedure keys off the same `note` text. This one exists
> so that an unmapped note still raises a DCM entry instead of a WARN row with nothing
> to read.

[End of Procedure]

---

---

## AIR

AIR reads two AQI sources — OpenWeather Air Pollution and AirNow — each with its own validity
flag in `current.json` (`openweather.valid`, `airnow.valid`). The row's own `partial` state
is AIR-only.

### Configuration

<a id="air-coordinates-missing"></a>**AIR COORDINATES MISSING**

**Indications:** AIR row shows WARN / ERROR (missing coordinates); DCM entry reads "Set `[location] lat`/`lon` in the air profile or `site.toml`".

`ERROR` — pre-flight failure; `note` reports missing coordinates.

```text
-SET [location] LAT/LON.........................air profile or site.toml
```

[End of Procedure]

---

<a id="air-api-key-missing"></a>**AIR API KEY MISSING**

**Indications:** AIR row shows WARN / ERROR (missing API key); DCM entry reads "Set OpenWeather Air Pollution API key in the air profile".

`ERROR` — pre-flight failure; `note` reports the OpenWeather API key is missing.

```text
-SET API KEY..................OpenWeather Air Pollution key, air profile
```

[End of Procedure]

---

### Source Failure

<a id="air-no-cache"></a>**AIR NO CACHE**

**Indications:** AIR row shows WARN / ERROR (no cache yet); DCM entry reads "Check OpenWeather/AirNow API reachability for AIR".

`ERROR` — `note:"air fetch failed; no cache"`. The first fetch failed and there is no prior
cache to serve. Clears on the first successful fetch.

```text
-CHECK REACHABILITY..................................OpenWeather, AirNow
```

[End of Procedure]

---

<a id="air-no-timestamp"></a>**AIR NO TIMESTAMP**

**Indications:** AIR row shows WARN / PARTIAL (no provider timestamp); DCM entry reads "AIR cache has data but no reliable timestamp — check AirNow/OpenWeather API status".

`PARTIAL` — `state:"partial"`, `note:"air cache has no provider timestamp"`. The cache holds
data, but neither source yielded a usable observed timestamp. This can happen even when both
sources returned data.

```text
-CHECK API STATUS....................................AirNow, OpenWeather
```

> **NOTE:** `PARTIAL` fires only when *neither* source resolves a timestamp. If one source
> still resolves one and the other is down, the row is `DEGRADED` instead.

```text
PROC: AIR OPENWEATHER DEGRADED
PROC: AIR AIRNOW DEGRADED
```

[End of Procedure]

---

### Silent Gaps

<a id="air-openweather-degraded"></a>**AIR OPENWEATHER DEGRADED**

**Indications:** AIR row shows WARN / DEGRADED (`note` starts "openweather source invalid"); DCM entry reads "OpenWeather AQI source down — check API key/quota".

`DEGRADED` — `note` starts "openweather source invalid". `openweather.valid` is `false` while
AirNow still resolves a timestamp. Fires only when OpenWeather is actually enabled in the
profile, so a site that never configured it is not flagged.

```text
-CHECK API KEY...............................................OpenWeather
-CHECK QUOTA.................................................OpenWeather
```

```text
PROC: AIR NO TIMESTAMP
```

[End of Procedure]

---

<a id="air-airnow-degraded"></a>**AIR AIRNOW DEGRADED**

**Indications:** AIR row shows WARN / DEGRADED (`note` starts "airnow source invalid"); DCM entry reads "AirNow AQI source down — check API key/quota".

`DEGRADED` — `note` starts "airnow source invalid". `airnow.valid` is `false` while
OpenWeather still resolves a timestamp. Fires only when AirNow is actually enabled in the
profile, so a site that never configured it is not flagged.

```text
-CHECK API KEY....................................................AirNow
-CHECK QUOTA......................................................AirNow
```

```text
PROC: AIR NO TIMESTAMP
```

[End of Procedure]

---

---

## ALERTS

### Cache Staleness

<a id="alerts-not-running"></a>**ALERTS NOT RUNNING**

**Indications:** ALERTS row shows WARN / STALE (missing or stale `banner.json`); DCM entry reads "Alerts provider isn't running — check `fetch_alerts.sh` is wired into the refresh loop".

`STALE` — `banner.json` is missing or past its TTL. ALERTS recomputes `banner.json` from
other domains' caches on every run and always writes `state:"ok"` when it runs at all, so
stale or missing means the script did not run: crashed, never invoked, or its cache
directory is unwritable.

```text
-FETCH_ALERTS.SH.................................WIRED INTO REFRESH LOOP
```

> **NOTE:** Not an API-key or network problem. ALERTS has no API of its own and no
> failure path. Its 60s TTL is the launcher's bash default — no `profiles/alerts/*.toml`
> ships.

[End of Procedure]

---

---

## AP

AP runs its own SSH session to each Zyxel AP, with its own gate (`runtime/ap/ssh_state`) and
its own cache-freshness check. It writes its output into pfSense's cache directory
(`ap_status.json`, `ap_clients.json`) as a storage-location choice only — it has no
functional dependency on PFSENSE, and a missing pfSense profile TOML has no effect on it.

### Configuration

<a id="ap-no-ips-configured"></a>**AP NO IPS CONFIGURED**

**Indications:** AP row shows WARN / ERROR (no AP IPs configured); DCM entry reads "Set `[ap] ips`/`labels` in `site.toml`".

`ERROR` — `note:"no ap ips configured"`. `site.toml [ap] ips` is empty or unset.

```text
-SET [ap] ips/labels...........................................site.toml
```

[End of Procedure]

---

<a id="ap-password-file-missing"></a>**AP PASSWORD FILE MISSING**

**Indications:** AP row shows WARN / ERROR (password file not found); DCM entry reads "Create `~/.config/zyxel_ap/.pass`".

`ERROR` — `note:"password file not found: <path>"`. The Zyxel `sshpass` credential file does
not exist.

```text
-CREATE FILE....................................~/.config/zyxel_ap/.pass
```

[End of Procedure]

---

### SSH Gate

<a id="ap-ssh-gate"></a>**AP SSH GATE**

**Indications:** AP row shows WARN / DEGRADED (SSH gate tripped); DCM entry reads "Check SSH alias / sshpass credentials for AP".

`DEGRADED` — `note:"ssh gate tripped"`. AP's own gate, independent of pfSense's and
Pi-hole's.

```text
-CHECK SSH ALIAS......................................................AP
-CHECK SSHPASS CREDENTIALS............................................AP
```

> **NOTE:** Never "check the PFSENSE row." AP's gate and cache are self-contained;
> sending someone to PFSENSE means hunting for a cause that isn't there.

[End of Procedure]

---

---

## ASTRO

### Configuration

<a id="astro-location-missing"></a>**ASTRO LOCATION MISSING**

**Indications:** ASTRO row shows WARN / ERROR (missing location); DCM entry reads "Set `[location] lat`/`lon` in the astro profile or `site.toml`".

`ERROR` — `note:"missing location"`.

```text
-SET [location] LAT/LON.......................astro profile or site.toml
```

[End of Procedure]

---

### Enablement

<a id="astro-fallback-ttl"></a>**ASTRO FALLBACK TTL**

**Indications:** ASTRO row shows NOMINAL / MISSING (TTL reads 60s, cannot confirm real versus fallback); STATE stays derived from AGE, which sits under TTL, so only the flag raises the NOTE and highlights the row; DCM entry reads "ASTRO profile TOML has no `[cache]` section — cannot confirm the 60s TTL is configured, not a fallback.".

`MISSING` — the TTL cell reads 60s and Doctor cannot confirm it is configured rather than a
fallback. The launcher takes ASTRO's cadence from `[cache] refresh_sec` in the astro profile
and falls back to a bare 60 when the file or the key is absent; `status.json` never says
which. ASTRO's data collection is unaffected — pure `pyephem`, and its own failures
(`missing profile toml`, `missing location`) are loud.

> **NOTE:** The shipped `home.toml.example` sets `refresh_sec = 60`, so the configured value
> and the fallback are the same number. Fixing this changes no behavior; it lets Doctor
> confirm what is running. The same collision is why ORB cannot be told apart by TTL alone.

● IF `profiles/astro/<profile>.toml` does not exist:

```text
-RERUN BOOTSTRAP.......................bin/gtex62-core-bootstrap-runtime
-RESTART SUITE......................launcher reads TTLs once, at startup
```

● IF the profile exists but has no `[cache]` section:

```text
-ADD [cache] refresh_sec...............................60, astro profile
-RESTART SUITE......................launcher reads TTLs once, at startup
```

> **CAUTION:** Bootstrap will not fix this second case. It skips a file that already exists,
> and `--force` overwrites the whole profile, discarding local edits.

```text
PROC: NET FALLBACK TTL
PROC: ORB FALLBACK TTL
```

[End of Procedure]

---

---

## AVIATION

The reference model for per-field staleness: `metar` and `taf` are tracked as independent
fields, each with its own `state` and `last_ok`.

### Source Failure

<a id="aviation-degraded"></a>**AVIATION DEGRADED**

**Indications:** AVIATION row shows WARN / DEGRADED (one of metar/taf failing, or both); DCM entry reads "`<FIELD>` fetch failing for AVIATION; serving cached data from `<last_ok>`", or "METAR and TAF both failing for AVIATION; serving cached data" when both fail.

`DEGRADED` — one or both of `metar`/`taf` is failing while cached data still exists to serve.
The field name and its `last_ok` timestamp come straight from `note`
(`"taf fetch failing; serving cached data from <last_ok>"`).

● IF `note` names one field:

```text
-<FIELD> FETCH...................................................FAILING
-SERVING CACHED DATA FROM......................................<last_ok>
-CHECK REACHABILITY..................................aviationweather.gov
```

● IF `note` names both `metar` and `taf`:

```text
-METAR AND TAF FETCH........................................BOTH FAILING
-SERVING CACHED DATA.................................................YES
-CHECK REACHABILITY..................................aviationweather.gov
```

> **NOTE:** Both failing still degrades rather than errors, as long as some cache exists to
> keep serving.

[End of Procedure]

---

<a id="aviation-no-cache"></a>**AVIATION NO CACHE**

**Indications:** AVIATION row shows WARN / ERROR (no cache yet); DCM entry reads "Check aviationweather.gov reachability for AVIATION".

`ERROR` — `note:"aviation fetch failed; no cache"`. The first fetch failed and there is
nothing to serve.

```text
-CHECK REACHABILITY..................................aviationweather.gov
```

[End of Procedure]

---

---

## CALENDAR

### Cache Staleness

<a id="calendar-never-run"></a>**CALENDAR NEVER RUN**

**Indications:** CALENDAR row shows WARN / MISSING (missing cache entirely; AGE blank, since there is nothing to compute it from); DCM entry reads "Calendar has never run — check `refresh_loop`/`initial_refresh` wiring".

`MISSING` — no cache exists. CALENDAR reads local text files only, so this is not a
credentials problem. At an 86400s TTL a calendar that was simply never triggered would sit
missing far longer than any staleness check would catch.

```text
-REFRESH_LOOP WIRING...............................................CHECK
-INITIAL_REFRESH WIRING............................................CHECK
```

> **NOTE:** A cache that exists but holds zero events is not this procedure. Past
> pre-flight CALENDAR always writes `state:"ok"`, and nothing in the cache distinguishes
> "nothing on the calendar" from "the source file was never read."

```text
PROC: PROFILE TOML MISSING
```

[End of Procedure]

---

---

## CONNECT

CONNECT has `initial_refresh` in the launcher but no `refresh_loop`: speedtest snapshots are
on-demand only.

### Silent Gaps

<a id="connect-speedtest-failing"></a>**CONNECT SPEEDTEST FAILING**

**Indications:** CONNECT row shows WARN / DEGRADED (`note` starts "speedtest failing"); DCM entry reads "Speedtest failing — check `speedtest` CLI is installed/licensed (`--accept-license --accept-gdpr`)".

`DEGRADED` — `note` starts "speedtest failing" (`"speedtest failing: speedtest failed or
unavailable"`). `status.json`'s `state` now follows `current.json`'s nested
`speedtest.state`; a failed `speedtest` call is `speedtest.state:"error"`.

```text
-SPEEDTEST CLI.................................................INSTALLED
-LICENSE FLAGS............................--accept-license --accept-gdpr
```

> **NOTE:** `speedtest.state:"disabled"` (speedtest never enabled in the profile) still
> reads `state:"ok"`. That is a choice, not a failure — there is no procedure for it.

[End of Procedure]

---

### Cache Staleness

<a id="connect-speedtest-stale"></a>**CONNECT SPEEDTEST STALE**

**Indications:** CONNECT row shows WARN / STALE (speedtest older than `max_age_days`, no error; AGE shows the last manual run); DCM entry reads "No speedtest has run in N days (on-demand only, no automatic refresh) — run manually".

`STALE` — no speedtest has run in N days, past `max_age_days`, with no error. Doctor-derived
from `current.json`'s own `age_days`, not from `status.json`'s age.

```text
-RUN SPEEDTEST..................................................MANUALLY
```

> **NOTE:** There is no automatic refresh to fall back on. The AGE cell shows the time of the
> last manual run.

[End of Procedure]

---

---

## GITHUB

GITHUB is maintainer-only: its STATE is hardcoded PRIVATE and never computed. PRIVATE does
not suppress a NOTE. It runs on a systemd user timer
(`gtex62-github-traffic.timer`), entirely outside the launcher's `refresh_loop`, so no
procedure here is a `fetch_github.sh` or profile-TOML fix. `STALE` is not used for GITHUB —
`MISSING` covers a cache never written, and `REFRESH` covers the deadline.

### Configuration

<a id="github-registry-empty"></a>**GITHUB REGISTRY EMPTY**

**Indications:** GITHUB row shows PRIVATE / ERROR (empty repo registry) — STATE is hardcoded PRIVATE, so the NOTE alone highlights the row; DCM entry reads "Populate `~/.config/conky/github-traffic-repos.json`".

`ERROR` — `note:"no repos configured"`. The repo registry is empty.

```text
-POPULATE FILE.................~/.config/conky/github-traffic-repos.json
```

[End of Procedure]

---

### Source Failure

<a id="github-fetch-failing"></a>**GITHUB FETCH FAILING**

**Indications:** GITHUB row shows PRIVATE / ERROR (fetch failed for one or more repos), possibly beside REFRESH in the same NOTE cell; DCM entry reads "GitHub API fetch failing for: `<repos>` — check `gh auth status`".

`ERROR` — `note:"fetch failed for: <repos>"`. A `gh api` call failed for one or more repos;
one failing repo raises `ERROR` for the whole domain.

```text
-CHECK AUTH...............................................gh auth status
```

> **NOTE:** This can sit in the same NOTE cell as `REFRESH` — fetches failing *and* the
> deadline approaching.

```text
PROC: GITHUB REFRESH
```

[End of Procedure]

---

### Cache Staleness

<a id="github-never-run"></a>**GITHUB NEVER RUN**

**Indications:** GITHUB row shows PRIVATE / MISSING (cache never written; GITHUB has no STALE); DCM entry reads "Check `systemctl --user status gtex62-github-traffic.timer`".

`MISSING` — the cache was never written. GITHUB is on a systemd timer, so a missing cache
means the timer needs attention, not a launcher script.

```text
-CHECK TIMER.........systemctl --user status gtex62-github-traffic.timer
```

[End of Procedure]

---

### Refresh Deadline

<a id="github-refresh"></a>**GITHUB REFRESH**

**Indications:** GITHUB row shows PRIVATE / REFRESH, independent of STATE and possibly beside ERROR, with AGE switched to `N/14` (for example `10/14`) once the last successful fetch is 10 days old; DCM entry begins "GitHub traffic copy is `N`/14 days behind".

`REFRESH` — the last successful fetch is 10 days old or older. Unlike every other tag,
`REFRESH` tells you what to do rather than what is true.

GitHub's traffic API keeps only a rolling 14-day window. `fetch_github_traffic.py`
accumulates `history_days` from each fetch, so a day not captured before it rolls out of
that window is gone for good. `REFRESH` fires at 10 days: a 4-day buffer before that cliff.

```text
-START SERVICE......systemctl --user start gtex62-github-traffic.service
```

Then find out why it needed starting:

● IF `REFRESH` is the only tag in the NOTE cell — fetches are not failing, the timer has
stopped firing:

```text
-CHECK TIMER.........systemctl --user status gtex62-github-traffic.timer
```

● IF `ERROR` shares the NOTE cell — the timer fires but the fetches fail:

```text
-CHECK AUTH...............................................gh auth status
```

```text
PROC: GITHUB FETCH FAILING
```

● IF the machine was powered off — no fault. The AGE timestamp is the real last-successful-pull
time regardless of uptime, so it is correct the moment the widget is next checked. The timer
runs 10 minutes after boot (`OnBootSec=10m`) and every 12 hours after that
(`OnUnitActiveSec=12h`).

```text
-CHECK TIMER.........systemctl --user status gtex62-github-traffic.timer
```

Confirm the fix:

```text
-AGE........................................RETURNS TO A YYYY-MM-DD DATE
-REFRESH..........................................................CLEARS
```

> **NOTE — reading AGE.** Before `REFRESH` fires, AGE is a date, `YYYY-MM-DD`: the newest
> `history_days` day, which trails the pull by about a day. A date that has stopped advancing
> is the early warning, well ahead of the tag — a dead timer is visible there first. Once
> `REFRESH` is active, AGE switches to whole days elapsed over the window, `N/14` (for
> example `10/14`), because days remaining before loss is more urgent than the raw date.
> `REFRESH` clears when the age drops back under 10 days.
>
> **NOTE — how the age is measured.** From `history_days`, not file mtime or `status.json`.
> The script rewrites `current.json` and `status.json` on every run, even one where every
> repo failed, but a repo's newest `history_days` key advances only when its `gh api` pull
> succeeds (zero-traffic days are stored too, so a quiet repo does not stall it). Doctor takes
> the *oldest* newest-key across the repos currently in the registry; a repo dropped from the
> registry stays in the cache and does not count. The key is day-granular, so the 10-day
> line effectively trips about 9 days after the last pull.
>
> **CAUTION:** The API keeps only a rolling 14-day window, so older data is lost. Starting
> the service after the window has passed does not bring it back.

[End of Procedure]

---

---

## MEDIA

**Provisional.** MEDIA's entries have not had the script-level verification pass the other
domains had (`doctor-design.md`, Open Questions). Treat these as the design table's text, not
as confirmed against `fetch_lyrics.sh` / `fetch_lyrics.py`.

### Dependency

<a id="media-local-dir-unreachable"></a>**MEDIA LOCAL DIR UNREACHABLE**

**Indications:** MEDIA row shows WARN / DEGRADED (`local_dir` unreachable); DCM entry reads "local_dir unreachable — check NAS mount".

`DEGRADED` — `local_dir`, the configured lyrics library, is unreachable. `local_dir` may be
a symlink to network storage; the provider only needs it configured and reachable.

```text
-CHECK NAS MOUNT................................[media.lyrics] local_dir
```

[End of Procedure]

---

## MODEM

MODEM's link to pfSense is a network path only: it reaches the modem's admin UI at
`192.168.100.1` through pfSense's NAT-to-VIP routing, and reads no pfSense cache. A pfSense
outage can therefore surface here, as MODEM's own state.

Three `DEGRADED` conditions were silent gaps, closed at the source on 2026-09-17: a bad
DOCSIS registration value (**MODEM CONN DEGRADED**), an all-unlocked upstream array
(**MODEM NO UPSTREAM LOCK**), and a channel-table parse failure (**MODEM HEADER MAPPING**).
They can fire together, in which case `note` carries every reason.

### Configuration

<a id="modem-password-not-set"></a>**MODEM PASSWORD NOT SET**

**Indications:** MODEM row shows WARN / ERROR (password not configured); DCM entry reads "Set `[credentials].password` in the modem profile TOML (not `CHANGE_ME`)".

`ERROR` — `note` names the exact TOML key: the password is missing or still `CHANGE_ME`.

```text
-SET [credentials].password...........................modem profile TOML
```

● IF `note` is `"missing profile toml"`:

```text
PROC: PROFILE TOML MISSING
```

> **NOTE:** `ERROR` also covers an unexpected exception. There is no fixed remediation for
> that; read `note` in the modem `status.json`.

[End of Procedure]

---

### Source Failure

<a id="modem-unreachable"></a>**MODEM UNREACHABLE**

**Indications:** MODEM row shows WARN / DEGRADED (`note` starts "modem unreachable"); DCM entry reads "Check pfSense NAT path to 192.168.100.1 (modem admin UI)".

`DEGRADED` — `note` starts "modem unreachable: `<exc>`". A network-level failure reaching
the modem's admin UI.

```text
-CHECK PFSENSE NAT PATH....................................192.168.100.1
```

> **NOTE:** This is the scrape failing, not the modem's DOCSIS state. If the modem answered
> and the row still reads `DEGRADED`, this is the wrong procedure — see PROC: MODEM AUTH
> FAILED and PROC: MODEM CONN DEGRADED.

[End of Procedure]

---

<a id="modem-auth-failed"></a>**MODEM AUTH FAILED**

**Indications:** MODEM row shows WARN / DEGRADED (`note` starts "modem auth failed"); DCM entry reads "Check modem credentials in `[credentials].password`".

`DEGRADED` — `note` starts "modem auth failed". The modem was reached; login or session
setup failed. Kept distinct from MODEM UNREACHABLE in `note` even though both map to the
same `state`.

```text
-CHECK CREDENTIALS................................[credentials].password
```

```text
PROC: MODEM UNREACHABLE
```

[End of Procedure]

---

### Silent Gaps

<a id="modem-conn-degraded"></a>**MODEM CONN DEGRADED**

**Indications:** MODEM row shows WARN / DEGRADED (`note` starts "modem not registered with Comcast"); DCM entry reads "Modem not registered with Comcast (`<connectivity_state.status>`) — check DOCSIS sync, not the scraper".

`DEGRADED` — `note` starts "modem not registered with Comcast (connectivity state:
`<value>`)". `connectivity_state.status`, the CM1000's own DOCSIS registration state, is
present and is neither empty nor `"OK"` (case-insensitive). The modem is reachable and the
scrape is clean; the modem is not registered with Comcast.

`connectivity_state.status` is SitRep's primary modem-health signal: its DOCSIS header line
exists to answer "is the modem actually registered," not "did the scrape succeed."

```text
-CHECK DOCSIS SYNC.................................................MODEM
-SCRAPER...................................................NOT THE CAUSE
```

> **NOTE:** The scrape worked, so the NAT path to `192.168.100.1` is working — do not
> send the reader there. That check belongs to PROC: MODEM UNREACHABLE.

● IF `note` instead mentions "header mapping incomplete", "not found" or "has no rows" —
the modem answered, but the admin UI's channel tables came back empty. A different cause,
with a different fix:

```text
PROC: MODEM HEADER MAPPING
```

● IF `note` also carries "no locked upstream channels" — the upstream side is down too:

```text
PROC: MODEM NO UPSTREAM LOCK
```

> **NOTE:** A `connectivity_state` row missing from the status table entirely is a
> different, un-elevated case. It adds a `note` fragment, but `state` stays `"ok"`, so no
> NOTE tag appears and no procedure applies. Only a *present* row with a bad value raises
> this one.

[End of Procedure]

---

<a id="modem-header-mapping"></a>**MODEM HEADER MAPPING**

**Indications:** MODEM row shows WARN / DEGRADED (`note` mentions "header mapping incomplete", "not found", or "has no rows"); DCM entry reads "Modem admin UI layout may have changed — check the channel-table note in MODEM's status".

`DEGRADED` — `note` mentions "header mapping incomplete", "not found" or "has no rows"
(`parse_channel_table()`'s own text, for example `"table #<id> header mapping
incomplete…"`). Either `upstream_channels` or `downstream_ofdm_channels` came back empty.
The modem's admin UI layout has probably changed — a firmware update, for one — and the
scraper's parser no longer finds the columns it expects. Reachability, login and
`connectivity_state.status` are all fine.

```text
-READ NOTE............................shared/modem/{profile}/status.json
-CHECK ADMIN UI LAYOUT...............................usTable, d31dsTable
```

● IF `upstream_channels` is the empty array — the upstream table (`usTable`) did not parse.

● IF `downstream_ofdm_channels` is the empty array — the downstream table (`d31dsTable`)
did not parse.

● IF both arrays are empty — both tables did not parse; the layout change is broad.

> **NOTE:** An *empty* upstream array is this procedure. A non-empty array in which no channel
> is `locked:true` is a different one — PROC: MODEM NO UPSTREAM LOCK. The two checks are
> deliberately kept apart.

```text
PROC: MODEM CONN DEGRADED
PROC: MODEM NO UPSTREAM LOCK
```

[End of Procedure]

---

<a id="modem-no-upstream-lock"></a>**MODEM NO UPSTREAM LOCK**

**Indications:** MODEM row shows WARN / DEGRADED (`note` starts "no locked upstream channels"); DCM entry reads "Modem has no locked upstream channels — check DOCSIS upstream sync".

`DEGRADED` — `note` starts "no locked upstream channels (modem cannot transmit upstream)".
`upstream_channels` is non-empty and no entry has `locked:true`.

```text
-CHECK DOCSIS UPSTREAM SYNC........................................MODEM
```

> **NOTE:** A `0.0` in SitRep's US AVG while this NOTE is present is not a real
> reading. The average used to render a fully-unlocked array as a plausible `0.0`; the NOTE
> is what flags it now.

```text
PROC: MODEM CONN DEGRADED
PROC: MODEM HEADER MAPPING
```

[End of Procedure]

---

---

## MTR

MTR is trigger-armed and has its own SSH gate (`runtime/mtr`), independent of pfSense's and
AP's.

### Configuration

<a id="mtr-no-ssh-target"></a>**MTR NO SSH TARGET**

**Indications:** MTR row shows WARN / ERROR (no `ssh_target` configured); DCM entry reads "Set `ssh_target` in the mtr profile TOML".

`ERROR` — `note:"no ssh_target configured"`.

```text
-SET ssh_target.........................................mtr profile TOML
```

[End of Procedure]

---

### SSH Gate

<a id="mtr-ssh-gate"></a>**MTR SSH GATE**

**Indications:** MTR row shows WARN / DEGRADED (SSH gate tripped); DCM entry reads "Check SSH alias / sshpass credentials for MTR (Pi5)".

`DEGRADED` — `ssh_gate.tripped:true`. `note` names which SSH step failed: `"ssh failed during
confirm"`, `"…during start"` or `"…during outer-cap stop"`. All three trip the same gate.

```text
-CHECK SSH ALIAS...............................................MTR (Pi5)
-CHECK SSHPASS CREDENTIALS.....................................MTR (Pi5)
```

[End of Procedure]

---

---

## NET

### Enablement

<a id="net-fallback-ttl"></a>**NET FALLBACK TTL**

**Indications:** NET row shows WARN / MISSING (profile TOML missing or lacks `[cache] ttl_sec`; `state` stays `"ok"`), and under this condition the TTL cell cannot be trusted: it can read `1` while the real cadence is 60s and AGE climbs toward 60 before each refresh — the row reads WARN once AGE passes the TTL the cell reports, not because of the flag; DCM entry reads "NET profile TOML missing or has no `[cache] ttl_sec` — VLAN/ping meters are running at the 60s fallback cadence, not 1s.".

`MISSING` — the NET profile TOML is missing, or has no `[cache] ttl_sec`, and NET is running
on the launcher's 60s fallback instead of its real 1s TTL. VLAN and ping meters appear
frozen: a 60x slowdown in a fast-track domain.

`status.json` reports `state:"ok"` the whole time. `fetch_net.sh` never checks whether its
profile exists (`ENABLED="${ENABLED:-true}"` proceeds either way), so nothing NET writes ever
reflects it. The launcher's `NET_TTL="${NET_TTL:-60}"` silently takes over. Doctor detects
it independently, by checking the profile's existence and its `[cache] ttl_sec` key rather
than inferring from the TTL number.

This is the canonical, documented instance of the bootstrap gap in `architecture.md` and
this project's `CLAUDE.md`.

> **NOTE:** Do not trust the TTL cell at face value for this domain. It can read `1`
> while NET is actually refreshing every 60 seconds. Confirm from AGE instead. A healthy
> NET at its real 1s TTL shows a blank AGE (near-zero, never past a second or two); on the
> fallback, AGE becomes a populated value that climbs toward 60 before each refresh resets
> it. The two describe different operating states, so a populated, climbing AGE is itself
> the tell.

● IF `profiles/net/<profile>.toml` does not exist:

```text
-RERUN BOOTSTRAP.......................bin/gtex62-core-bootstrap-runtime
-RESTART SUITE......................launcher reads TTLs once, at startup
```

● IF the profile exists but has no `[cache] ttl_sec`:

```text
-ADD [cache] ttl_sec......................................1, NET profile
-RESTART SUITE......................launcher reads TTLs once, at startup
```

> **CAUTION:** Bootstrap will not fix this second case. It skips a file that already exists
> (`skip  <path>`), and `--force` overwrites the whole profile, discarding local edits.
>
> **CAUTION:** The restart is not optional. `bin/gtex62-core-launch` parses each domain's TTL
> once, at startup, and passes it to `refresh_loop` for the life of the process. A repaired
> profile does not change a running loop.

```text
PROC: ORB FALLBACK TTL
PROC: ASTRO FALLBACK TTL
PROC: FALLBACK TTL
PROC: NET NOT RUNNING
```

[End of Procedure]

---

### Cache Staleness

<a id="net-not-running"></a>**NET NOT RUNNING**

**Indications:** NET row shows WARN / STALE (missing or not refreshing at all); DCM entry reads "NET provider isn't running — check `refresh_loop` is alive".

`STALE` — NET's cache is missing or not refreshing at all. At a 1s TTL, a fast-track domain
missing for more than a couple of poll cycles means the loop itself is dead, not that a
fetch missed.

```text
-REFRESH_LOOP......................................................ALIVE
```

> **NOTE:** Different from NET FALLBACK TTL. There the cache *is* refreshing, just at 60s;
> here it is not refreshing at all.

```text
PROC: NET FALLBACK TTL
```

[End of Procedure]

---

---

## NETWORK

### Silent Gaps

<a id="network-null-fields"></a>**NETWORK NULL FIELDS**

**Indications:** NETWORK row shows WARN / DEGRADED (`note` starts "null field(s):"); DCM entry reads "NIC detection or public-IP lookup failing — check `primary_interface` config and outbound connectivity".

`DEGRADED` — `note` starts "null field(s):" and names exactly which of `wan_ip`, `dns` and
`gateway` came back empty — one, two or all three. A NIC-detection or lookup failure that
used to leave `state:"ok"`.

```text
-CHECK primary_interface.................................NETWORK profile
-CHECK OUTBOUND CONNECTIVITY.........................................WAN
```

● IF `wan_ip` alone is named — the public-IP lookup is failing while the interface is up.
Concentrate on outbound connectivity.

● IF `dns` alone is named — DNS resolution is failing.

● IF `gateway` alone is named — the default-route lookup found nothing.

● IF all three are named — the interface is effectively down. Concentrate on
`primary_interface`.

> **NOTE:** `lan_ip` can also go null but is not checked. There will be no NOTE for it — a
> known gap, not a fault-free reading.

```text
PROC: PROFILE TOML MISSING
```

[End of Procedure]

---

---

## ORB

### Enablement

<a id="orb-fallback-ttl"></a>**ORB FALLBACK TTL**

**Indications:** ORB row shows NOMINAL / MISSING (TTL reads 60s, cannot confirm real versus fallback); AGE looks healthy either way, so STATE stays NOMINAL and only the flag raises the NOTE and highlights the row; DCM entry reads "ORB profile TOML missing or has no `[cache] ttl_sec` — cannot confirm the 60s TTL is configured, not a fallback.".

`MISSING` — the TTL cell reads 60s and Doctor cannot confirm it is configured rather than a
fallback. The installed profile (`profiles/orb/home.toml`) sets `[cache] ttl_sec = 60`, and
the launcher's own fallback (`ORB_TTL="${ORB_TTL:-60}"`) is also 60, so a configured ORB and
a fallen-back ORB behave identically. The explicit flag is the only way to tell them apart.

> **NOTE:** Unlike NET, AGE cannot break the tie. The real cadence and the fallback
> cadence are the same, so the row looks healthy either way. Doctor's own check of the
> profile's existence and `[cache] ttl_sec` key is the only evidence.

● IF `profiles/orb/<profile>.toml` does not exist:

```text
-RERUN BOOTSTRAP.......................bin/gtex62-core-bootstrap-runtime
-RESTART SUITE......................launcher reads TTLs once, at startup
```

● IF the profile exists but has no `[cache] ttl_sec`:

```text
-ADD [cache] ttl_sec.....................................60, ORB profile
-RESTART SUITE......................launcher reads TTLs once, at startup
```

> **CAUTION:** Bootstrap will not fix this second case. It skips a file that already exists,
> and `--force` overwrites the whole profile, discarding local edits.

```text
PROC: NET FALLBACK TTL
```

[End of Procedure]

---

---

## PFSENSE

PFSENSE is a family of independently gated sub-caches, not one TTL. Pi-hole is not one of
them — see PIHOLE.

| Sub-cache | `[providers.pfsense]` flag | Script | Launcher default |
| --- | --- | --- | --- |
| `status` (gateway, interfaces) | `status` | `fetch_pfsense.sh` | 5s |
| `router` | `router` | `fetch_router.sh` | 60s |
| `pfblockerng` | `pfblockerng` | `fetch_pfblockerng.sh` | 300s |
| `ifaces` (interface byte counters) | `ifaces` | `fetch_pfsense_ifaces.sh` | 1s |
| `arp` | rides on `status` | within `fetch_pfsense.sh` | 180s |
| `leases` | rides on `status` | within `fetch_pfsense.sh` | 180s |

The launcher defaults are the fallbacks; a profile can override them (`status` is 30s in the
live profile).

### Configuration

<a id="pfsense-no-ssh-target"></a>**PFSENSE NO SSH TARGET**

**Indications:** PFSENSE row shows WARN / ERROR (no `ssh_target` configured); DCM entry reads "Set `ssh_target` in the pfsense profile TOML".

`ERROR` — no `ssh_target` configured.

```text
-SET ssh_target.....................................pfsense profile TOML
```

[End of Procedure]

---

### Source Failure

<a id="pfsense-subcache-degraded"></a>**PFSENSE SUBCACHE DEGRADED**

**Indications:** PFSENSE row shows WARN / DEGRADED (or `ERROR`, `PARTIAL`, `WAITING`) while the sub-caches are fresh; DCM entry names the sub-cache and its own note — for example "`router`: ssh gate tripped". WARN overrides HYBRID.

`DEGRADED` — an *enabled* sub-cache wrote its own non-ok `state` while its cache is still
fresh. Different from PFSENSE SUBCACHE STALE, where the cache is old. Each sub-cache has its
own script and its own SSH gate, so one can fail while the others are healthy:

| Sub-cache | Gate state directory |
| --- | --- |
| `status` (also arp, leases) | `runtime/pfsense` |
| `router` | `runtime/router` |
| `pfblockerng` | `runtime/pfblockerng` |
| `ifaces` | `runtime/pfsense_ifaces` |

This entry covers `router`, `pfblockerng` and `ifaces`. `status` (and arp and leases, which
mirror it) raise PFSENSE SSH GATE or PFSENSE NO SSH TARGET directly.

```text
-IDENTIFY SUB-CACHE..............router, pfblockerng or ifaces, from DCM
-READ NOTE.....shared/pfsense/<profile>/<sub-cache>.json, `note`
```

● IF the note is `ssh gate tripped` or `ssh failed`:

```text
PROC: PFSENSE SSH GATE
```

● IF the note is `no ssh_target configured`:

```text
PROC: PFSENSE NO SSH TARGET
```

● IF the note is anything else:

```text
PROC: UNRECOGNIZED NOTE
```

> **NOTE:** Clearing one sub-cache's gate does not clear the others: they share the SSH
> alias and credentials but not the gate.

[End of Procedure]

---

### SSH Gate

<a id="pfsense-ssh-gate"></a>**PFSENSE SSH GATE**

**Indications:** PFSENSE row shows WARN / DEGRADED (SSH gate tripped or failed); DCM entry reads "Check SSH alias / sshpass credentials".

`DEGRADED` — the SSH gate tripped, or an SSH call failed. Both paths write stub `arp_leases`
and `history` envelopes matching the main envelope's state.

```text
-CHECK SSH ALIAS.................................................PFSENSE
-CHECK SSHPASS CREDENTIALS.......................................PFSENSE
```

> **NOTE:** Shared wording with AP and MTR's gates, but each has its own gate and cache.

[End of Procedure]

---

### Cache Staleness

<a id="pfsense-subcache-stale"></a>**PFSENSE SUBCACHE STALE**

**Indications:** PFSENSE row shows WARN / STALE (any one enabled sub-cache stale; WARN overrides HYBRID); DCM entry names the specific sub-cache (status, router, pfblockerng, ifaces, arp or leases), not just "PFSENSE".

`STALE` — any one *enabled* sub-cache is past its TTL. The row is worst-state-wins, and a
single `DEGRADED` or `STALE` can originate from any one of the independently gated fetches,
so identify which one.

```text
-IDENTIFY SUB-CACHE.....status, router, pfblockerng, ifaces, arp, leases
```

> **NOTE:** Only enabled sub-caches count. A sub-cache whose flag is off leaves a cache file
> behind that does not make the row stale, and `STALE` overrides the row's HYBRID state — it
> is never masked.

```text
PROC: PFSENSE SSH GATE
PROC: PFSENSE SUBCACHE DEGRADED
```

[End of Procedure]

---

---

## PIHOLE

PIHOLE runs on Pi5 with its own script (`fetch_pihole.sh`), its own SSH gate
(`runtime/pihole`) and its own TTL. It shares PFSENSE's cache directory
(`shared/pfsense/{profile}/pihole.json`) and the pfsense profile TOML's `[pihole]` section,
and nothing else.

### Configuration

<a id="pihole-no-ssh-target"></a>**PIHOLE NO SSH TARGET**

**Indications:** PIHOLE row shows WARN / ERROR (no `ssh_target` configured); DCM entry reads "Set `ssh_target` in the `[pihole]` section of the pfsense profile TOML, or `[pihole] ssh_target` in `site.toml`".

`ERROR` — `note:"no ssh_target configured"`.

```text
-SET ssh_target.....................[pihole] of the pfsense profile TOML
-OR SET [pihole] ssh_target....................................site.toml
```

[End of Procedure]

---

### SSH Gate

<a id="pihole-ssh-gate"></a>**PIHOLE SSH GATE**

**Indications:** PIHOLE row shows WARN / DEGRADED (`note` is "ssh gate tripped" or "ssh failed"); DCM entry reads "Check SSH alias / sshpass credentials for PIHOLE (Pi5)".

`DEGRADED` — `note` is "ssh gate tripped" or "ssh failed".

```text
-CHECK SSH ALIAS............................................PIHOLE (Pi5)
-CHECK SSHPASS CREDENTIALS..................................PIHOLE (Pi5)
```

> **NOTE:** Never "check the PFSENSE row." PIHOLE's gate and cache are independent of
> pfSense's, the same self-containment as AP and MTR.

[End of Procedure]

---

---

## SOLAR

### Dependency

<a id="solar-waiting"></a>**SOLAR WAITING**

**Indications:** SOLAR row shows WARN / WAITING (`state:"waiting"`); DCM entry reads "SOLAR is waiting on the WEATHER cache — check the WEATHER row, not SOLAR's own config".

`WAITING` — `state:"waiting"`, `note:"waiting for weather cache"`. SOLAR polls for up to 20s
(40 × 0.5s) for the WEATHER cache
(`shared/weather/<profile>/raw_current.json` or `current.json`) to appear, and writes this
explicit state if neither does. It is never a SOLAR-side fault.

```text
-CHECK ROW.......................................................WEATHER
```

> **NOTE:** Defer entirely to WEATHER. Do not render SOLAR-specific remediation — there
> is nothing wrong with SOLAR's own configuration.

```text
PROC: WEATHER NO CACHE
PROC: WEATHER DEGRADED
PROC: WEATHER CONFIG MISSING
```

[End of Procedure]

---

---

## SYSTEM

### Cache Staleness

<a id="system-not-running"></a>**SYSTEM NOT RUNNING**

**Indications:** SYSTEM row shows WARN / STALE (missing or stale at 1s TTL); DCM entry reads "SYSTEM provider isn't running — check `refresh_loop` is alive".

`STALE` — the cache is missing or stale at a 1s TTL. SYSTEM is local-only with no network
dependency and no error path past pre-flight, so a cache missing for more than a couple of
poll cycles means the refresh loop is dead, not that a fetch failed.

```text
-REFRESH_LOOP......................................................ALIVE
```

[End of Procedure]

---

---

## TIME

### Cache Staleness

<a id="time-not-running"></a>**TIME NOT RUNNING**

**Indications:** TIME row shows WARN / STALE (missing or stale at 1s TTL); DCM entry reads "TIME provider isn't running — check `refresh_loop` is alive".

`STALE` — the cache is missing or stale at a 1s TTL. TIME is pure `zoneinfo`/`datetime`
arithmetic with no external call that can fail, so this means the refresh loop is dead.

```text
-REFRESH_LOOP......................................................ALIVE
```

```text
PROC: PROFILE TOML MISSING
```

[End of Procedure]

---

---

## VPN

Both VPN `DEGRADED` conditions were silent gaps, now closed at the source: `state` is
trustworthy on its own, and Doctor never needs to read `health` instead. Read `health`
(`HEALTHY`, `STALE`, `DEAD`) for a richer picture, but not to catch either case.

### Configuration

<a id="vpn-piactl-missing"></a>**VPN PIACTL MISSING**

**Indications:** VPN row shows WARN / ERROR (`note` "piactl not found"); DCM entry reads "PIA client not installed or not on PATH".

`ERROR` — `note:"piactl not found"`. The PIA client is not installed or not on `PATH`. Not
the same as a cache that was never written.

```text
-PIA CLIENT....................................................INSTALLED
-PIACTL..........................................................ON PATH
```

● IF `note` is `"missing profile toml"`:

```text
PROC: PROFILE TOML MISSING
```

[End of Procedure]

---

### Silent Gaps

<a id="vpn-wg-stats-degraded"></a>**VPN WG STATS DEGRADED**

**Indications:** VPN row shows WARN / DEGRADED (`note` mentions "sudo wg dump failed" or "wg not found", with `connectionstate:"Connected"`); DCM entry reads "WireGuard stats unavailable — check `/etc/sudoers.d/gtex62-core-vpn`".

`DEGRADED` — `note` mentions "sudo wg dump failed" or "wg not found", and
`connectionstate` is `"Connected"`. piactl believes the tunnel is up, but the WireGuard stats
could not be read: `latest_handshake_seconds` and `transfer` go `null`, and `health` reads
`"DEAD"`.

● IF `note` mentions "sudo wg dump failed":

```text
-CHECK SUDOERS RULE......................./etc/sudoers.d/gtex62-core-vpn
```

● IF `note` mentions "wg not found":

```text
-CONFIRM wg BINARY.............................................INSTALLED
```

> **NOTE:** `health:"DEAD"` on its own is not this procedure. PIA tears the `wgpia0`
> interface down on an ordinary voluntary disconnect, which drives `health` to `"DEAD"` and
> makes the dump fail for a non-alarming reason. The check is gated on
> `connectionstate == "Connected"` for exactly that reason, so a routine disconnect stays
> `state:"ok"`.
>
> **NOTE:** At most one of this procedure's note fragments and VPN TUNNEL PING DEGRADED's
> appears per poll. A failed dump forces `health` to `"DEAD"`, which is the condition that
> excludes the ping check.

```text
PROC: VPN TUNNEL PING DEGRADED
```

[End of Procedure]

---

<a id="vpn-tunnel-ping-degraded"></a>**VPN TUNNEL PING DEGRADED**

**Indications:** VPN row shows WARN / DEGRADED (`note` starts "tunnel ping failing"); DCM entry reads "VPN tunnel ping failing — check tunnel interface routing (transient, or `1.1.1.1` unreachable through the tunnel)".

`DEGRADED` — `note` starts "tunnel ping failing". `tunnel_latency_ms` is `null` while `health`
is not `"DEAD"`: the tunnel is otherwise connected, but the ping through it failed. `note`
names when the tunnel ping last succeeded (`tunnel_latency_last_ok_epoch`), or says "no prior
successful ping on record" if none is tracked yet.

```text
-CHECK TUNNEL INTERFACE ROUTING......................................VPN
-CHECK 1.1.1.1 THROUGH TUNNEL..................................REACHABLE
```

● IF this is a single occurrence — a lone dropped ping is transient and clears on the next
poll.

● IF it persists — `1.1.1.1` is unreachable through the tunnel.

> **NOTE:** A disconnected VPN (`health:"DEAD"`) with a failing ping stays `state:"ok"`.
> `health` already covers that case, so it is not double-flagged.

```text
PROC: VPN WG STATS DEGRADED
```

[End of Procedure]

---

---

## WEATHER

`current` and `forecast` are tracked as independent fields, the same pattern as AVIATION's
`metar` and `taf`. WEATHER has no third `partial` state — only `error`, `disabled`,
`degraded` and `ok`.

### Configuration

<a id="weather-config-missing"></a>**WEATHER CONFIG MISSING**

**Indications:** WEATHER row shows WARN / ERROR (missing credentials/coordinates); DCM entry reads "Set API key and `[location] lat`/`lon` in the weather profile".

`ERROR` — missing credentials or coordinates.

```text
-SET API KEY.............................................weather profile
-SET [location] LAT/LON..................................weather profile
```

[End of Procedure]

---

### Source Failure

<a id="weather-degraded"></a>**WEATHER DEGRADED**

**Indications:** WEATHER row shows WARN / DEGRADED (one of current/forecast failing); DCM entry reads "`<FIELD>` fetch failing for WEATHER; serving cached data from `<last_ok>`".

`DEGRADED` — one of `current` or `forecast` is failing while cached data still exists. The
field and its `last_ok` timestamp come straight from `note`
(`"forecast fetch failing; serving cached data from <last_ok>"`).

```text
-<FIELD> FETCH...................................................FAILING
-SERVING CACHED DATA FROM......................................<last_ok>
-CHECK REACHABILITY..........................................OpenWeather
```

```text
PROC: SOLAR WAITING
```

[End of Procedure]

---

<a id="weather-no-cache"></a>**WEATHER NO CACHE**

**Indications:** WEATHER row shows WARN / ERROR (no cache yet); DCM entry reads "Check OpenWeather API reachability for WEATHER".

`ERROR` — `note:"weather fetch failed; no cache"`. The first fetch failed and there is
nothing to serve.

```text
-CHECK REACHABILITY..........................................OpenWeather
```

> **NOTE:** SOLAR depends on WEATHER's cache. A WEATHER row stuck here is what SOLAR
> reports as `WAITING`.

```text
PROC: SOLAR WAITING
```

[End of Procedure]

---

---

## Deliberately Absent

Conditions that look like they should have a procedure and do not:

- **MTR `IDLE` and `RUNNING`.** Both are `state:"ok"`, carry no NOTE, and do not highlight a
  row or raise a DCM entry. Idle is armed-and-waiting; running is the overnight capture doing
  its job in response to a real condition. The gateway-offline problem behind a capture is
  surfaced by ALERTS and DCM's active state, so MTR does not duplicate it. There is nothing
  to look up.
- **PFSENSE `HYBRID`.** Not a fault: one to three of the four `[providers.pfsense]` sub-flags
  are enabled and every enabled sub-cache is fresh. `STALE` overrides it when a sub-cache
  is not — see PROC: PFSENSE SUBCACHE STALE.
- **DISABLED, any domain.** Administratively off, not broken. Every DISABLED row collapses to
  the widget footer pointer, `TO ENABLE PROVIDERS, SEE README § Provider Toggles`, and gets
  no per-domain text.
- **MEDIA's unset Genius token.** It no longer shows an `OPTIONAL` NOTE — it flagged permanently
  for a feature that is inert today. The fact stays in `status.json`'s MEDIA detail snapshot,
  so there is nothing to look up.
- **MEDIA's lyrics bugs** — the stale-lyrics bug and the 12-hour-miss bug. These are tracked
  as in-tree bug docs under `gtex62-core/docs/` (`2026-09-20-lyrics-*.md`), a different kind
  of document from a QRH procedure.

---

## Procedure Index

Every procedure, A–Z regardless of domain. A DCM entry's `PROC:` line gives one of these
titles exactly.

- [AIR AIRNOW DEGRADED](#air-airnow-degraded)
- [AIR API KEY MISSING](#air-api-key-missing)
- [AIR COORDINATES MISSING](#air-coordinates-missing)
- [AIR NO CACHE](#air-no-cache)
- [AIR NO TIMESTAMP](#air-no-timestamp)
- [AIR OPENWEATHER DEGRADED](#air-openweather-degraded)
- [ALERTS NOT RUNNING](#alerts-not-running)
- [AP NO IPS CONFIGURED](#ap-no-ips-configured)
- [AP PASSWORD FILE MISSING](#ap-password-file-missing)
- [AP SSH GATE](#ap-ssh-gate)
- [ASTRO FALLBACK TTL](#astro-fallback-ttl)
- [ASTRO LOCATION MISSING](#astro-location-missing)
- [AVIATION DEGRADED](#aviation-degraded)
- [AVIATION NO CACHE](#aviation-no-cache)
- [CALENDAR NEVER RUN](#calendar-never-run)
- [CONFIG VALUE UNSET](#config-value-unset)
- [CONNECT SPEEDTEST FAILING](#connect-speedtest-failing)
- [CONNECT SPEEDTEST STALE](#connect-speedtest-stale)
- [DOMAIN NOT LISTED](#domain-not-listed)
- [FALLBACK TTL](#fallback-ttl)
- [GITHUB FETCH FAILING](#github-fetch-failing)
- [GITHUB NEVER RUN](#github-never-run)
- [GITHUB REFRESH](#github-refresh)
- [GITHUB REGISTRY EMPTY](#github-registry-empty)
- [MEDIA LOCAL DIR UNREACHABLE](#media-local-dir-unreachable)
- [MODEM AUTH FAILED](#modem-auth-failed)
- [MODEM CONN DEGRADED](#modem-conn-degraded)
- [MODEM HEADER MAPPING](#modem-header-mapping)
- [MODEM NO UPSTREAM LOCK](#modem-no-upstream-lock)
- [MODEM PASSWORD NOT SET](#modem-password-not-set)
- [MODEM UNREACHABLE](#modem-unreachable)
- [MTR NO SSH TARGET](#mtr-no-ssh-target)
- [MTR SSH GATE](#mtr-ssh-gate)
- [NET FALLBACK TTL](#net-fallback-ttl)
- [NET NOT RUNNING](#net-not-running)
- [NETWORK NULL FIELDS](#network-null-fields)
- [ORB FALLBACK TTL](#orb-fallback-ttl)
- [PFSENSE NO SSH TARGET](#pfsense-no-ssh-target)
- [PFSENSE SSH GATE](#pfsense-ssh-gate)
- [PFSENSE SUBCACHE DEGRADED](#pfsense-subcache-degraded)
- [PFSENSE SUBCACHE STALE](#pfsense-subcache-stale)
- [PIHOLE NO SSH TARGET](#pihole-no-ssh-target)
- [PIHOLE SSH GATE](#pihole-ssh-gate)
- [PROFILE TOML MISSING](#profile-toml-missing)
- [PROVIDER STALE](#provider-stale)
- [SOLAR WAITING](#solar-waiting)
- [SYSTEM NOT RUNNING](#system-not-running)
- [TIME NOT RUNNING](#time-not-running)
- [UNRECOGNIZED NOTE](#unrecognized-note)
- [VPN PIACTL MISSING](#vpn-piactl-missing)
- [VPN TUNNEL PING DEGRADED](#vpn-tunnel-ping-degraded)
- [VPN WG STATS DEGRADED](#vpn-wg-stats-degraded)
- [WEATHER CONFIG MISSING](#weather-config-missing)
- [WEATHER DEGRADED](#weather-degraded)
- [WEATHER NO CACHE](#weather-no-cache)
