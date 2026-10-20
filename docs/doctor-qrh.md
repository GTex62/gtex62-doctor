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

**Status (2026-10-19): reference for the built suite (v0.2.0).** The provider behavior each
procedure cites — `note` text, `state` values, launcher defaults, timer settings — is the
verified behavior recorded in `doctor-missing-conditions.md`, re-checked against
`bin/gtex62-core-launch` and `bin/gtex62-core-bootstrap-runtime` where a procedure depends on
them. The commands in each procedure were run against the live providers when they were
written (2026-10-19), except the ones that change system state (restarting the suite, editing
sudoers, installing packages, reconnecting the VPN).

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
| 1 | `ERROR`, `DEGRADED` (and `PARTIAL`, the provider-reported fault state only AIR and AIRGRADIENT use) | A provider-reported fault is driving the row |
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
- [AIRGRADIENT](#airgradient)
  - [Configuration](#configuration-2)
    - [AIRGRADIENT HOST NOT SET](#airgradient-host-not-set)
  - [Source Failure](#source-failure-2)
    - [AIRGRADIENT UNREACHABLE](#airgradient-unreachable)
  - [Silent Gaps](#silent-gaps-1)
    - [AIRGRADIENT FIELDS MISSING](#airgradient-fields-missing)
  - [Cache Staleness](#cache-staleness-1)
    - [AIRGRADIENT NOT RUNNING](#airgradient-not-running)
- [ALERTS](#alerts)
  - [Cache Staleness](#cache-staleness-2)
    - [ALERTS NOT RUNNING](#alerts-not-running)
- [AP](#ap)
  - [Configuration](#configuration-3)
    - [AP NO IPS CONFIGURED](#ap-no-ips-configured)
    - [AP PASSWORD FILE MISSING](#ap-password-file-missing)
  - [SSH Gate](#ssh-gate)
    - [AP SSH GATE](#ap-ssh-gate)
- [ASTRO](#astro)
  - [Configuration](#configuration-4)
    - [ASTRO LOCATION MISSING](#astro-location-missing)
  - [Enablement](#enablement-1)
    - [ASTRO FALLBACK TTL](#astro-fallback-ttl)
- [AVIATION](#aviation)
  - [Source Failure](#source-failure-3)
    - [AVIATION DEGRADED](#aviation-degraded)
    - [AVIATION NO CACHE](#aviation-no-cache)
- [CALENDAR](#calendar)
  - [Cache Staleness](#cache-staleness-3)
    - [CALENDAR NEVER RUN](#calendar-never-run)
- [CONNECT](#connect)
  - [Silent Gaps](#silent-gaps-2)
    - [CONNECT SPEEDTEST FAILING](#connect-speedtest-failing)
  - [Cache Staleness](#cache-staleness-4)
    - [CONNECT SPEEDTEST STALE](#connect-speedtest-stale)
- [GITHUB](#github)
  - [Configuration](#configuration-5)
    - [GITHUB REGISTRY EMPTY](#github-registry-empty)
  - [Source Failure](#source-failure-4)
    - [GITHUB FETCH FAILING](#github-fetch-failing)
  - [Cache Staleness](#cache-staleness-5)
    - [GITHUB NEVER RUN](#github-never-run)
  - [Refresh Deadline](#refresh-deadline)
    - [GITHUB REFRESH](#github-refresh)
- [MEDIA](#media)
  - [Dependency](#dependency)
    - [MEDIA LOCAL DIR UNREACHABLE](#media-local-dir-unreachable)
- [MODEM](#modem)
  - [Configuration](#configuration-6)
    - [MODEM PASSWORD NOT SET](#modem-password-not-set)
  - [Source Failure](#source-failure-5)
    - [MODEM UNREACHABLE](#modem-unreachable)
    - [MODEM AUTH FAILED](#modem-auth-failed)
  - [Silent Gaps](#silent-gaps-3)
    - [MODEM CONN DEGRADED](#modem-conn-degraded)
    - [MODEM HEADER MAPPING](#modem-header-mapping)
    - [MODEM NO UPSTREAM LOCK](#modem-no-upstream-lock)
- [MTR](#mtr)
  - [Configuration](#configuration-7)
    - [MTR NO SSH TARGET](#mtr-no-ssh-target)
  - [SSH Gate](#ssh-gate-1)
    - [MTR SSH GATE](#mtr-ssh-gate)
- [NET](#net)
  - [Enablement](#enablement-2)
    - [NET FALLBACK TTL](#net-fallback-ttl)
  - [Cache Staleness](#cache-staleness-6)
    - [NET NOT RUNNING](#net-not-running)
- [NETWORK](#network)
  - [Silent Gaps](#silent-gaps-4)
    - [NETWORK NULL FIELDS](#network-null-fields)
- [ORB](#orb)
  - [Enablement](#enablement-3)
    - [ORB FALLBACK TTL](#orb-fallback-ttl)
- [PFSENSE](#pfsense)
  - [Configuration](#configuration-8)
    - [PFSENSE NO SSH TARGET](#pfsense-no-ssh-target)
  - [Source Failure](#source-failure-6)
    - [PFSENSE SUBCACHE DEGRADED](#pfsense-subcache-degraded)
  - [SSH Gate](#ssh-gate-2)
    - [PFSENSE SSH GATE](#pfsense-ssh-gate)
  - [Cache Staleness](#cache-staleness-7)
    - [PFSENSE SUBCACHE STALE](#pfsense-subcache-stale)
- [PIHOLE](#pihole)
  - [Configuration](#configuration-9)
    - [PIHOLE NO SSH TARGET](#pihole-no-ssh-target)
  - [SSH Gate](#ssh-gate-3)
    - [PIHOLE SSH GATE](#pihole-ssh-gate)
- [SOLAR](#solar)
  - [Dependency](#dependency-1)
    - [SOLAR WAITING](#solar-waiting)
- [SYSTEM](#system)
  - [Cache Staleness](#cache-staleness-8)
    - [SYSTEM NOT RUNNING](#system-not-running)
- [TIME](#time)
  - [Cache Staleness](#cache-staleness-9)
    - [TIME NOT RUNNING](#time-not-running)
- [VPN](#vpn)
  - [Configuration](#configuration-10)
    - [VPN PIACTL MISSING](#vpn-piactl-missing)
  - [Silent Gaps](#silent-gaps-5)
    - [VPN WG STATS DEGRADED](#vpn-wg-stats-degraded)
    - [VPN TUNNEL PING DEGRADED](#vpn-tunnel-ping-degraded)
- [WEATHER](#weather)
  - [Configuration](#configuration-11)
    - [WEATHER CONFIG MISSING](#weather-config-missing)
  - [Source Failure](#source-failure-7)
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

```bash
bash ~/.config/conky/gtex62-core/bin/gtex62-core-bootstrap-runtime
```

Each line it prints is `write <path>` for a file it installed or `skip <path>` for one that
already existed and was left alone. It installs every missing template, not only this
domain's, so expect a `write` line for the profile you needed. Confirm the file is there:

```bash
ls ~/.config/gtex62-core/profiles/<domain>/
```

The provider reads the profile on its next poll, so no restart is needed for a profile that
was simply absent. (A TTL is the exception: see PROC: FALLBACK TTL.)

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

**Indications:** a VPN, AP, MODEM, ALERTS, MTR, PIHOLE or AIRGRADIENT row shows WARN / MISSING or STALE while its `core.toml [providers]` flag is `true`; DCM entry reads "`<DOMAIN>` is enabled in `core.toml` but not listed in `[domains]` of `suites/doctor.toml` — add it, or the launcher never starts it."

`MISSING` or `STALE` — the flag is on but the cache is absent or old, and the launching
suite's `[domains]` list omits the domain. Those seven domains are dual-gated: the launcher
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

1. See whether the domain is listed. Use the domain's lowercase name.

   ```bash
   sed -n '/^\[domains\]/,$p' ~/.config/gtex62-core/suites/doctor.toml | grep '"alerts"'
   ```

   No output means it is missing.

2. Add it as a quoted entry inside the `required = [ ... ]` list, one per line, ending with
   a comma:

   ```toml
   required = [
     "doctor",
     "air",
     "alerts",
   ]
   ```

3. Restart the suite. The launcher reads `[domains]` once, at startup.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice).

4. Confirm the domain's loop now exists. Substitute the domain.

   ```bash
   kill -0 "$(cat ~/.cache/gtex62-core/runtime/pids/doctor-alerts-refresh.pid 2>/dev/null)" 2>/dev/null && echo ALIVE || echo DEAD
   ```

For the third case (domain not wanted at all), set the flag in `~/.config/gtex62-core/core.toml` under
`[providers]`, for example `alerts = false`, then restart as in step 3.

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

1. Find what the profile is missing by comparing it with the shipped example. Lines marked
   `>` are in the example but not in your profile.

   ```bash
   diff ~/.config/gtex62-core/profiles/<domain>/<profile>.toml \
        ~/.config/conky/gtex62-core/examples/runtime/profiles/<domain>/<profile>.toml.example
   ```

   `<profile>` is the domain's profile from `[profiles]` in
   `~/.config/gtex62-core/suites/doctor.toml`.

2. Add the key from the table above, with its shipped-example value, under the right section
   header in your profile. For example, for AIR:

   ```toml
   [cache]
   ttl_sec = 900
   ```

   If the section header is already there, add only the key beneath it.

3. Restart the suite so the launcher re-reads the TTL.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice). The row clears once Doctor next checks the profile.

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

This is the generic procedure, so the commands use placeholders. `<domain>` is the row's
domain in lowercase and `<profile>` is its profile from `[profiles]` in
`~/.config/gtex62-core/suites/doctor.toml`.

1. Run the provider once by hand and read what it reports.

   ```bash
   ls ~/.config/conky/gtex62-core/providers/<domain>/
   bash ~/.config/conky/gtex62-core/providers/<domain>/fetch_<domain>.sh <profile>
   jq '{state, note}' ~/.cache/gtex62-core/shared/<domain>/<profile>/status.json
   ```

   The script is `fetch_<domain>.sh` except WEATHER (`fetch_openweather.sh`) and MEDIA
   (`fetch_lyrics.sh`); the `ls` shows the real names. A `note` that matches a known
   condition has its own procedure; use it.

2. If `state` is `"ok"` and the cache refreshed, the fetch works and the loop is what
   stopped. Run the loop check and restart in PROC: TIME NOT RUNNING (steps 1 and 2),
   using the domain's own PID file name.

3. If the fetch fails, read the error it logged. Not every domain keeps a log. AIR, AVIATION,
   AIRGRADIENT, NET and WEATHER do.

   ```bash
   tail -n 5 ~/.cache/gtex62-core/shared/<domain>/<profile>/fetch.log
   ```

   `(6)` is DNS and `(28)` is a timeout: the network. `(22) ... 401` is a rejected API key
   and `(22) ... 429` is a quota. The domain's own procedure above has the exact test for its
   source.

   The log is never trimmed, and AIR and WEATHER lines carry no timestamp, so an old error
   can sit at the bottom. Run `ls -l` on `fetch.log` first: if it was last written long
   ago, the error is history, not the current fault.

> **NOTE:** Several domains have a better answer than this one. ALERTS has no API, so "check
> the API key" would be wrong for it. CALENDAR reads local files only. NET, SYSTEM and TIME
> at a 1s TTL mean a dead loop. PFSENSE is a family of sub-caches. GITHUB never uses `STALE`.
> AIRGRADIENT is a keyless LAN device and a stale file means its loop stopped. Use the domain's own
> procedure.

```text
PROC: AIRGRADIENT NOT RUNNING
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
is AIR's, and AIRGRADIENT's: here it means no provider timestamp.

### Configuration

<a id="air-coordinates-missing"></a>**AIR COORDINATES MISSING**

**Indications:** AIR row shows WARN / ERROR (missing coordinates); DCM entry reads "Set `[location] lat`/`lon` in the air profile or `site.toml`".

`ERROR` — pre-flight failure; `note` reports missing coordinates.

```text
-SET [location] LAT/LON.........................air profile or site.toml
```

1. Set the coordinates in one of two places. The air profile wins if both are set.

   - `~/.config/gtex62-core/site.toml`, shared by every domain (preferred):

     ```toml
     [location.home]
     lat = 35.0000
     lon = -89.0000
     ```

   - `~/.config/gtex62-core/profiles/air/home.toml`, for AIR only:

     ```toml
     [location]
     lat = 35.0000
     lon = -89.0000
     ```

   Use decimal degrees, negative for south and west.

2. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/air/fetch_air.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/air/home/status.json
   ```

[End of Procedure]

---

<a id="air-api-key-missing"></a>**AIR API KEY MISSING**

**Indications:** AIR row shows WARN / ERROR (missing API key); DCM entry reads "Set OpenWeather Air Pollution API key in the air profile".

`ERROR` — pre-flight failure; `note` reports the OpenWeather API key is missing.

```text
-SET API KEY..................OpenWeather Air Pollution key, air profile
```

1. Put the OpenWeather key in `~/.config/gtex62-core/site.toml`, where WEATHER also reads it:

   ```toml
   [credentials]
   openweather_api_key = "your-key-here"
   ```

   An `api_key` under `[openweather]` in `~/.config/gtex62-core/profiles/air/home.toml` overrides it for
   AIR alone. Keys are free from openweathermap.org; the Air Pollution API is included.

2. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/air/fetch_air.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/air/home/status.json
   ```

   If the state is not `"ok"`, test the key with PROC: AIR OPENWEATHER DEGRADED.

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

1. Read the error the fetch logged. `curl` writes its failure there, without the key.

   ```bash
   tail -n 5 ~/.cache/gtex62-core/shared/air/home/fetch.log
   ```

   `(6)` is DNS and `(28)` is a timeout: the network. `(22) ... 401` means a key was
   rejected. `(22) ... 429` means a quota was hit.

   The log is never trimmed, and AIR and WEATHER lines carry no timestamp, so an old error
   can sit at the bottom. Run `ls -l` on `fetch.log` first: if it was last written long
   ago, the error is history, not the current fault.

2. Test each source directly. Use the OpenWeather test in PROC: AIR OPENWEATHER DEGRADED
   and the AirNow test in PROC: AIR AIRNOW DEGRADED. Only OpenWeather is required for a
   first cache to exist.

3. Rerun the provider and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/air/fetch_air.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/air/home/status.json
   ```

   `state` of `"ok"` means the cache now exists.

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

1. See which source lost its timestamp.

   ```bash
   jq '{openweather: .openweather.valid, airnow: .airnow.valid}' ~/.cache/gtex62-core/shared/air/home/current.json
   ```

   A source reading `false` is the one to test.

2. Test that source directly. For OpenWeather use PROC: AIR OPENWEATHER DEGRADED. For
   AirNow use PROC: AIR AIRNOW DEGRADED.

3. If both tests return `200` and both flags still read `false`, AirNow's data may be older
   than the profile accepts. `max_age_sec` in `[airnow]` of
   `~/.config/gtex62-core/profiles/air/home.toml` discards readings older than that, and
   the profile's own comment says to keep it at 7200 or more.

4. Rerun the provider.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/air/fetch_air.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/air/home/status.json
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

1. Ask OpenWeather the same question the provider asks, and print only the HTTP status.
   The key is read from `site.toml` and never printed.

   ```bash
   SITE=~/.config/gtex62-core/site.toml
   lat=$(awk -F'= *' '/^lat/{print $2; exit}' $SITE)
   lon=$(awk -F'= *' '/^lon/{print $2; exit}' $SITE)
   key=$(awk -F'"' '/^openweather_api_key/{print $2}' $SITE)
   curl -sS -o /dev/null -w '%{http_code}\n' "https://api.openweathermap.org/data/2.5/air_pollution?lat=$lat&lon=$lon&appid=$key"
   ```

   - `200`: the key and the service are fine right now. Go to the rerun step.
   - `401` or `403`: the key was rejected. Replace it (see where the key lives, below).
   - `429`: the quota is used up. Wait for the window to reset, or use a different key.
   - A curl error instead of a code (`(6)` DNS, `(28)` timeout): the network, not the key.
     Test it with `curl -sS -o /dev/null -w '%{http_code}\n' https://example.com`.

   The key lives in `[credentials] openweather_api_key` of
   `~/.config/gtex62-core/site.toml`. An `[openweather] api_key` in the air profile
   overrides it. A new key can take a couple of hours to activate.

2. Rerun the provider and confirm the flag cleared.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/air/fetch_air.sh home
   jq '{openweather: .openweather.valid, airnow: .airnow.valid}' ~/.cache/gtex62-core/shared/air/home/current.json
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

1. Ask AirNow the same question the provider asks, and print only the HTTP status. The key
   is read from `site.toml` and never printed.

   ```bash
   SITE=~/.config/gtex62-core/site.toml
   lat=$(awk -F'= *' '/^lat/{print $2; exit}' $SITE)
   lon=$(awk -F'= *' '/^lon/{print $2; exit}' $SITE)
   key=$(awk -F'"' '/^airnow_api_key/{print $2}' $SITE)
   curl -sS -o /dev/null -w '%{http_code}\n' "https://www.airnowapi.org/aq/observation/current/ziplatlong/?format=application/json&latitude=$lat&longitude=$lon&distance=25&API_KEY=$key"
   ```

   - `200`: the key and the service are fine right now. Go to the rerun step.
   - `401` or `403`: the key was rejected. Replace it (see where the key lives, below).
   - `429`: the quota is used up. Wait for the window to reset, or use a different key.
   - A curl error instead of a code (`(6)` DNS, `(28)` timeout): the network, not the key.
     Test it with `curl -sS -o /dev/null -w '%{http_code}\n' https://example.com`.

   The key lives in `[credentials] airnow_api_key` of `~/.config/gtex62-core/site.toml`.

2. If the code is `200`, check that AirNow actually returned readings. The number printed
   should be above 0.

   ```bash
   curl -sS "https://www.airnowapi.org/aq/observation/current/ziplatlong/?format=application/json&latitude=$lat&longitude=$lon&distance=25&API_KEY=$key" | jq 'if type == "array" then length else . end'
   ```

   Run it in the same shell as step 1, which sets `key`, `lat` and `lon`. A number is the
   count of readings. An error message instead of a number is AirNow rejecting the request.
   `0` usually means no monitoring station within `distance_miles` (25 by default).
   Raise `distance_miles` in `[airnow]` of `~/.config/gtex62-core/profiles/air/home.toml`.
   Readings older than `max_age_sec` there are discarded, and the profile's own comment
   says to keep it at 7200 or more.

3. Rerun the provider and confirm the flag cleared.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/air/fetch_air.sh home
   jq '{openweather: .openweather.valid, airnow: .airnow.valid}' ~/.cache/gtex62-core/shared/air/home/current.json
   ```

```text
PROC: AIR NO TIMESTAMP
```

[End of Procedure]

---

---

## AIRGRADIENT

AIRGRADIENT is the optional indoor air-quality domain: an AirGradient ONE read over its local
HTTP API, plus the ventilation advisor that turns the readings into the OSA alert line. It is
dual-gated (the `core.toml` flag and the suite's `[domains]`) and ships off, so most installs
never see this row. The provider rewrites `status.json` on every run, including failed ones, so a
dead device never makes the file go stale; the row's `state` is what reports it. `generated_at`
inside the file stays at the last good reading.

### Configuration

<a id="airgradient-host-not-set"></a>**AIRGRADIENT HOST NOT SET**

**Indications:** AIRGRADIENT row shows WARN / ERROR (`note` starts "device host not configured"); DCM entry reads "AirGradient has no device host — set `[device].host` in the airgradient profile".

`ERROR` — `note` names the exact TOML key: `[device].host` in the airgradient profile is empty. The
shipped template leaves it blank on purpose, because the address is yours.

```text
-SET [device].host..............................airgradient profile TOML
```

1. Find the device's address. It is on the AirGradient's own display, and in your router's
   DHCP client list. A static reservation keeps it from changing.

2. Put it in `~/.config/gtex62-core/profiles/airgradient/indoor.toml`:

   ```toml
   [device]
   host = "192.168.x.x"
   ```

3. Check the device answers at that address.

   ```bash
   curl -sS -m 5 -o /dev/null -w '%{http_code}\n' http://192.168.x.x/measures/current
   ```

   `200` means the address is right. Then no restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/airgradient/fetch_airgradient.sh indoor home home home
   jq '{state, note}' ~/.cache/gtex62-core/shared/airgradient/indoor/status.json
   ```

● IF `note` is `"missing profile toml"`:

```text
PROC: PROFILE TOML MISSING
```

[End of Procedure]

---

### Source Failure

<a id="airgradient-unreachable"></a>**AIRGRADIENT UNREACHABLE**

**Indications:** AIRGRADIENT row shows WARN / DEGRADED (`note` starts "device unreachable"); DCM entry reads "AirGradient device unreachable — check device reachability".

`DEGRADED` — `note` starts "device unreachable: `<reason>`". The fetch from
`http://<host>/measures/current` failed: connection refused or timed out, an HTTP status other
than 200, a reply that is not JSON, or a reply missing CO2, VOC, NOx or PM readings (the reason says
which). The row keeps the last readings and the last verdict, and OSA shows `AG STALE` once the
last good reading is three minutes old.

```text
-CHECK DEVICE REACHABILITY............................./measures/current
```

> **NOTE:** From the machine running Conky, `curl http://<host>/measures/current` shows the same
> thing the provider sees. A timeout is usually the device's power or Wi-Fi, or its address having
> changed (a DHCP lease that moved, a different VLAN), rather than anything in core; a static
> reservation avoids the last one. A `degraded` row that clears on its own within a poll or two is a
> transient and needs no action.

[End of Procedure]

---

### Silent Gaps

<a id="airgradient-fields-missing"></a>**AIRGRADIENT FIELDS MISSING**

**Indications:** AIRGRADIENT row shows WARN / PARTIAL (`note` starts "fields unavailable"); DCM entry reads "AirGradient fields unavailable: `<fields>` — check device".

`PARTIAL` — `note` starts "fields unavailable: `<fields>`". The device is answering, but one or
more of the compensated readings (`pm25_ugm3`, `temp_f`, `humidity_pct`) have had no value for longer
than the carry window (ten minutes by default). Firmware 3.7.0 drops these fields together in about
one response in five, which the provider rides out by carrying the last values forward; this state
means that stopped being enough. With them missing, the advisor skips every rule that needs
temperature, humidity or PM2.5 (the humidity trip, the dew-point comparisons, free cooling and the
indoor PM2.5 trigger); the CO2 and VOC rules and the outdoor-air hazard rule still run.

```text
-CHECK DEVICE, FIRMWARE.............................POWER-CYCLE THE UNIT
```

> **NOTE:** The row clears by itself on the first response that carries the fields again. It is not
> raised in the first ten minutes after the provider starts, because there is nothing to carry yet
> and a dropped response is normal.

[End of Procedure]

---

### Cache Staleness

<a id="airgradient-not-running"></a>**AIRGRADIENT NOT RUNNING**

**Indications:** AIRGRADIENT row shows WARN / STALE (missing or stale `status.json`, `state` still `ok`); DCM entry reads "AirGradient provider isn't running — check the refresh loop".

`STALE` — `status.json` is missing or past its TTL (30s by default) with `state:"ok"`. The provider
rewrites the file on every run, including failed ones, so stale or missing means the script did not
run: the refresh loop is not alive, the launching suite never started it, or its cache directory is
unwritable.

```text
-CHECK REFRESH_LOOP................................................ALIVE
```

1. Check this suite's loop is alive. The launcher keeps one PID file per domain loop.

   ```bash
   kill -0 "$(cat ~/.cache/gtex62-core/runtime/pids/doctor-airgradient-refresh.pid 2>/dev/null)" 2>/dev/null && echo ALIVE || echo DEAD
   ```

   - `ALIVE`: go to step 3.
   - `DEAD`, or no PID file: go to step 2. If there is no PID file at all and the
     domain is dual-gated, the launcher never started it: see PROC: DOMAIN NOT LISTED first.

2. Restart the suite. The launcher starts every domain's initial refresh and loop at
   startup, so a restart brings back a dead one.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice). Repeat step 1.

3. The loop is alive but the cache is still missing or stale. Run the provider once by hand
   and read what it reports.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/airgradient/fetch_airgradient.sh indoor home home home
   jq '{state, note}' ~/.cache/gtex62-core/shared/airgradient/indoor/status.json
   ```

   `state` of `"ok"` means the cache is written and the row clears on Doctor's next
   refresh. Any other `state`: read `note` and follow the procedure for it.

> **NOTE:** The loops exit when the suite's Conky window does (each checks that
> Conky is still running on every cycle). Closing or crashing the Doctor window is the
> usual way a loop dies. `doctor-` in the PID file name is the suite ID; a cache fed by
> another suite's launcher uses that suite's ID (`sitrep-`, `osa-`). A fresh cache does
> not prove *this* suite's loop is alive: another suite's loop can be refreshing the same
> shared file.
>
> **NOTE:** Not a device, API-key or network problem. AirGradient is a keyless device on your LAN, and a
> dead or unreachable device leaves the file fresh and reads `DEGRADED` instead (PROC: AIRGRADIENT
> UNREACHABLE). If the cause is that the launching suite does not list the domain, the row says so
> (PROC: DOMAIN NOT LISTED).

[End of Procedure]

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

1. Check this suite's loop is alive. The launcher keeps one PID file per domain loop.

   ```bash
   kill -0 "$(cat ~/.cache/gtex62-core/runtime/pids/doctor-alerts-refresh.pid 2>/dev/null)" 2>/dev/null && echo ALIVE || echo DEAD
   ```

   - `ALIVE`: go to step 3.
   - `DEAD`, or no PID file: go to step 2. If there is no PID file at all and the
     domain is dual-gated, the launcher never started it: see PROC: DOMAIN NOT LISTED first.

2. Restart the suite. The launcher starts every domain's initial refresh and loop at
   startup, so a restart brings back a dead one.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice). Repeat step 1.

3. The loop is alive but the cache is still missing or stale. Run the provider once by hand
   and read what it reports.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/alerts/fetch_alerts.sh main_router pi5 local local
   jq '{state, note}' ~/.cache/gtex62-core/shared/alerts/main_router/banner.json
   ```

   `state` of `"ok"` means the cache is written and the row clears on Doctor's next
   refresh. Any other `state`: read `note` and follow the procedure for it.

> **NOTE:** The loops exit when the suite's Conky window does (each checks that
> Conky is still running on every cycle). Closing or crashing the Doctor window is the
> usual way a loop dies. `doctor-` in the PID file name is the suite ID; a cache fed by
> another suite's launcher uses that suite's ID (`sitrep-`, `osa-`). A fresh cache does
> not prove *this* suite's loop is alive: another suite's loop can be refreshing the same
> shared file.
>
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

1. Edit `~/.config/gtex62-core/site.toml`. Both values are comma-separated strings, in the same order,
   one label per IP:

   ```toml
   [ap]
   ips = "192.168.x.1,192.168.x.2,192.168.x.3"
   labels = "FIRST,SECOND,THIRD"
   ```

2. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/ap/fetch_ap.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/ap_status.json
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

1. Create the file with the APs' admin password on a single line and nothing else. This
   prompts for the password, so it never lands in your shell history.

   ```bash
   mkdir -p ~/.config/zyxel_ap
   read -rs -p 'AP admin password: ' pw; echo
   printf '%s\n' "$pw" > ~/.config/zyxel_ap/.pass
   unset pw
   chmod 600 ~/.config/zyxel_ap/.pass
   ```

2. Confirm it is non-empty. The provider treats an empty file as missing.

   ```bash
   test -s ~/.config/zyxel_ap/.pass && echo FILE OK || echo FILE EMPTY
   ```

3. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now. A wrong password then shows as PROC: AP SSH GATE.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/ap/fetch_ap.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/ap_status.json
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

AP differs from the others. Zyxel APs do not take key-based SSH, so AP logs in as `admin`
with a password that `sshpass` reads from `~/.config/zyxel_ap/.pass`, and it connects to the
IPs in `[ap] ips` of `~/.config/gtex62-core/site.toml`, not to an alias. The gate trips only
on an authentication-type failure (permission denied, authentication failed, access denied,
too many authentication failures, host key verification failed). A plain timeout does not
trip it.

1. Read the gate. It is a circuit breaker: after an SSH failure it blocks further attempts
   for a cooldown (3s, then 10s, 30s, 120s, and 600s from the fifth failure in a row), then
   lets the provider try again by itself.

   ```bash
   GATE_STATE_DIR=~/.cache/gtex62-core/runtime/ap bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh status
   ```

   `OK` means it has already cleared and the row follows on the next poll.
   `TRIPPED|left=N|fails=N|reason=...` means it is still holding. `fails` is how many
   attempts in a row have failed, so a high number means the cause has persisted.

2. Log in to one AP the way the provider does. Substitute an IP from `[ap] ips`.

   ```bash
   printf 'show version\nexit\n' | sshpass -f ~/.config/zyxel_ap/.pass ssh \
     -o ConnectTimeout=5 -o ConnectionAttempts=1 -o LogLevel=ERROR \
     -o PubkeyAuthentication=no -o KbdInteractiveAuthentication=yes \
     -o PreferredAuthentications=keyboard-interactive,password \
     -o NumberOfPasswordPrompts=1 -o StrictHostKeyChecking=accept-new \
     -tt admin@192.168.40.4
   ```

   A `Router>` prompt and a model line mean the login works. Otherwise:

   - `Permission denied` or `Authentication failed`: the password in `.pass` is wrong, or
     was changed on the AP. The file holds the password on one line, nothing else. Correct
     it (see PROC: AP PASSWORD FILE MISSING for the file itself).
   - `Connection timed out` or `No route to host`: the AP is off or unreachable. Ping it.
   - `Host key verification failed`: the AP's key changed. If you know why, clear it with
     `ssh-keygen -R <ip>`.

   Test each IP in `[ap] ips`. One bad AP trips the gate for the whole fleet.

3. Once the test passes, clear the gate rather than waiting out the cooldown. This
   fixes nothing by itself: if the cause is still there, the next poll trips it again.

   ```bash
   GATE_STATE_DIR=~/.cache/gtex62-core/runtime/ap bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh reset
   ```

4. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/ap/fetch_ap.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/ap_status.json
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

1. Set the coordinates in one of two places. The astro profile wins if both are set.

   - `~/.config/gtex62-core/site.toml`, shared by every domain (preferred):

     ```toml
     [location.home]
     lat = 35.0000
     lon = -89.0000
     ```

   - `~/.config/gtex62-core/profiles/astro/home.toml`, for ASTRO only:

     ```toml
     [location]
     lat = 35.0000
     lon = -89.0000
     ```

2. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/astro/fetch_astro.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/astro/home/status.json
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

1. Check which case applies.

   ```bash
   ls ~/.config/gtex62-core/profiles/astro/
   grep -n -A3 '^\[cache\]' ~/.config/gtex62-core/profiles/astro/home.toml
   ```

   No file listed: it is missing. A file with no `[cache]` lines, or a `[cache]` section
   without the key: the key is missing.

2. Fix it.

   - File missing: run `bash ~/.config/conky/gtex62-core/bin/gtex62-core-bootstrap-runtime`. It prints `write`
     for what it installed and `skip` for what already existed.
   - File present, key missing: add to `~/.config/gtex62-core/profiles/astro/home.toml`:

     ```toml
     [cache]
     refresh_sec = 60
     ```

     If a `[cache]` header is already there, add only the key beneath it.

3. Restart the suite. This step is not optional.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice).

4. The row clears once Doctor next checks the profile. ASTRO's configured and fallback
   cadence are both 60s, so the cache itself looks the same either way.

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

1. Read the error the fetch logged. Each line is tagged with the time and which call
   produced it.

   ```bash
   tail -n 10 ~/.cache/gtex62-core/shared/aviation/home/fetch.log
   ```

   `(6)` is DNS and `(28)` is a timeout: the network. `(22) ... 5xx` is aviationweather.gov
   itself having a bad moment, which usually passes by itself.

   The log is never trimmed, so check `ls -l` on `fetch.log` first: if it was last written
   long ago, the error is history, not the current fault.

2. Ask aviationweather.gov the same question the provider asks, and print only the HTTP
   status. The station comes from `[aviation] metar` in `~/.config/gtex62-core/site.toml`.

   ```bash
   st=$(awk -F'"' '/^metar/{print $2}' ~/.config/gtex62-core/site.toml)
   curl -sS -o /dev/null -w '%{http_code}\n' "https://aviationweather.gov/api/data/metar?ids=$st&format=raw&hours=1"
   curl -sS -o /dev/null -w '%{http_code}\n' "https://aviationweather.gov/api/data/taf?ids=$st&format=raw"
   ```

   `200` on both means the source is up now. Anything else, or a curl error, is the
   network or the source, and there is nothing to fix on this machine.

3. Rerun the provider and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/aviation/fetch_aviation.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/aviation/home/status.json
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

1. Read the error the fetch logged. Each line is tagged with the time and which call
   produced it.

   ```bash
   tail -n 10 ~/.cache/gtex62-core/shared/aviation/home/fetch.log
   ```

   `(6)` is DNS and `(28)` is a timeout: the network. `(22) ... 5xx` is aviationweather.gov
   itself having a bad moment, which usually passes by itself.

   The log is never trimmed, so check `ls -l` on `fetch.log` first: if it was last written
   long ago, the error is history, not the current fault.

2. Ask aviationweather.gov the same question the provider asks, and print only the HTTP
   status. The station comes from `[aviation] metar` in `~/.config/gtex62-core/site.toml`.

   ```bash
   st=$(awk -F'"' '/^metar/{print $2}' ~/.config/gtex62-core/site.toml)
   curl -sS -o /dev/null -w '%{http_code}\n' "https://aviationweather.gov/api/data/metar?ids=$st&format=raw&hours=1"
   curl -sS -o /dev/null -w '%{http_code}\n' "https://aviationweather.gov/api/data/taf?ids=$st&format=raw"
   ```

   `200` on both means the source is up now. Anything else, or a curl error, is the
   network or the source, and there is nothing to fix on this machine.

3. Rerun the provider and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/aviation/fetch_aviation.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/aviation/home/status.json
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

The wiring is in core's launcher (`bin/gtex62-core-launch`): CALENDAR gets an
`initial_refresh` and a `refresh_loop` unconditionally, with no flag to switch on. So a
missing cache is not a missing line of wiring. Either this suite's launcher never ran, or
the fetch itself failed.

1. Check this suite's loop is alive. The launcher keeps one PID file per domain loop.

   ```bash
   kill -0 "$(cat ~/.cache/gtex62-core/runtime/pids/doctor-calendar-refresh.pid 2>/dev/null)" 2>/dev/null && echo ALIVE || echo DEAD
   ```

   - `ALIVE`: go to step 3.
   - `DEAD`, or no PID file: go to step 2.

2. Restart the suite. The launcher starts every domain's initial refresh and loop at
   startup, so a restart brings back a dead one.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice). Repeat step 1.

3. The loop is alive but the cache is still missing or stale. Run the provider once by hand
   and read what it reports.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/calendar/fetch_calendar.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/calendar/local/status.json
   ```

   `state` of `"ok"` means the cache is written and the row clears on Doctor's next
   refresh. Any other `state`: read `note` and follow the procedure for it.

> **NOTE:** The loops exit when the suite's Conky window does (each checks that
> Conky is still running on every cycle). Closing or crashing the Doctor window is the
> usual way a loop dies. `doctor-` in the PID file name is the suite ID; a cache fed by
> another suite's launcher uses that suite's ID (`sitrep-`, `osa-`). A fresh cache does
> not prove *this* suite's loop is alive: another suite's loop can be refreshing the same
> shared file.
>
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

1. Confirm the CLI is the Ookla one. The provider calls `speedtest -f json --accept-license
   --accept-gdpr`, which only the Ookla client understands (not the Python `speedtest-cli`).

   ```bash
   command -v speedtest && speedtest --version
   ```

   - No path printed: the CLI is not installed. Install Ookla's `speedtest`, then go to step 3.
   - Version line does not start "Speedtest by Ookla": wrong client. Replace it with the
     Ookla one, then go to step 3.

2. Run the exact call by hand to see the real error. The provider discards it
   (`2>/dev/null`), so DCM only ever shows "speedtest failed or unavailable".

   ```bash
   speedtest -f json --accept-license --accept-gdpr
   ```

   - JSON prints: the CLI works from your shell. Go to step 3. The provider also passes
     `-s <server_id>` when one is set, so if the failure returns, check `server_id` as below.
   - An error prints: that message is the cause. A network or DNS error means fix the
     connection first. A server error with a `server_id` set in the profile or `site.toml`
     means the pinned server is gone: list servers with `speedtest -L` and update
     `server_id` (or clear it) in `~/.config/gtex62-core/profiles/connectivity/default.toml`.

3. Rerun the provider and verify the state cleared.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/connectivity/fetch_connectivity.sh default
   jq '.speedtest | {state, note}' ~/.cache/gtex62-core/shared/connectivity/default/current.json
   ```

   `state` should read `"ok"`. DCM and the CONNECT row clear on their next refresh.

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

```bash
bash ~/.config/conky/gtex62-core/providers/connectivity/fetch_connectivity.sh default
```

```text
-VERIFY...........shared/connectivity/default/current.json, speedtest.state "ok"
```

> **NOTE:** There is no automatic refresh to fall back on. The AGE cell shows the time of the
> last manual run.
>
> **NOTE:** The command blocks until it finishes, since it performs a real `speedtest`. The
> provider reuses a snapshot younger than `max_age_days` and tests only when it is older, so
> in this STALE state the command always runs a fresh test. A failed test leaves
> `speedtest.state:"error"` — see CONNECT SPEEDTEST FAILING.
>
> **NOTE:** Do not use `speedtest_snapshot.sh run` for this. It writes to the suite's
> `net/` cache, not the `shared/connectivity/` cache Doctor reads, so STALE would not clear.

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

1. Write the file as JSON, one `owner/repo` per entry:

   ```json
   {
     "repos": [
       "owner/first-repo",
       "owner/second-repo"
     ]
   }
   ```

   An entry may also be an object, `{"repo": "owner/name", "note": "..."}`.

2. Check it parses. A file that is missing, is not valid JSON, or has no `repos` list is
   all read as empty, so this exact message can also mean a typo.

   ```bash
   jq '.repos | length' ~/.config/conky/github-traffic-repos.json
   ```

   It should print the number of repos. A `jq` parse error is the cause.

3. The GITHUB provider runs from a systemd timer, not the launcher. Run it now, rather
   than waiting for the timer.

   ```bash
   systemctl --user start gtex62-github-traffic.service
   jq '{state, note}' ~/.cache/gtex62-core/shared/github/default/status.json
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

The provider's test is a plain directory listing of `local_dir`. Do the same by hand.

1. List the directory.

   ```bash
   dir=$(awk -F'"' '/^local_dir/{print $2}' ~/.config/gtex62-core/site.toml)
   ls "$dir" | head -3
   ```

   Files listed: the directory is reachable now. The condition was transient. Go to step 3.

2. If the listing fails or hangs, find out what the path is mounted from.

   ```bash
   findmnt -T "$dir"
   ```

   The `SOURCE` column names the NAS share. Check that the NAS host in it is on, and that
   you can reach it with `ping -c 3 <host>`. If the host answers, accessing the path again
   usually remounts it (an autofs mount mounts on first access).

3. Rerun the provider and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/media/fetch_lyrics.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/media/local/status.json
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

1. Edit `~/.config/gtex62-core/profiles/modem/local.toml` and replace `CHANGE_ME` with the modem
   admin password (the one you use to sign in at `http://192.168.100.1`):

   ```toml
   [credentials]
   password = "your-modem-password"
   ```

2. Restrict the file, since it now holds a password.

   ```bash
   chmod 600 ~/.config/gtex62-core/profiles/modem/local.toml
   ```

3. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm. A wrong password then shows as
   PROC: MODEM AUTH FAILED.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/modem/fetch_modem.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/modem/local/status.json
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

1. Try the modem's admin page directly and print only the HTTP status.

   ```bash
   curl -sS -m 8 -o /dev/null -w '%{http_code}\n' http://192.168.100.1/GenieLogin.asp
   ```

   - `200`: the modem answers now. The failure was transient. Go to step 3.
   - A curl error (`(7)` refused, `(28)` timeout) or `000`: the path is down. Go to step 2.

2. Work out where the path breaks, nearest hop first.

   ```bash
   ping -c 3 192.168.100.1
   ping -c 3 <pfSense address>
   ```

   The modem is reached through pfSense (a NAT rule to a virtual IP). If pfSense answers
   and the modem does not, check that the modem is powered and its cable link is up. If
   pfSense does not answer, the problem is upstream of MODEM; look at the PFSENSE row.

3. Rerun the provider and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/modem/fetch_modem.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/modem/local/status.json
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

1. Read the exact reason the login failed.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/modem/fetch_modem.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/modem/local/status.json
   ```

2. Check the credentials the provider uses. They are in
   `~/.config/gtex62-core/profiles/modem/local.toml`: `username` under `[connection]` and
   `password` under `[credentials]`.

3. Prove the credentials by logging in yourself. Open `http://192.168.100.1` in a browser and
   sign in with that username and password. If the browser login fails too, the password in
   the file is wrong or the modem's password was changed. Correct the file. If the browser
   login works and the provider still fails, keep the `note` from step 1: the provider's
   own message says whether it got no session cookie after login.

4. Rerun the provider (step 1) and confirm `state` is `"ok"`.

> **NOTE:** `chmod 600 ~/.config/gtex62-core/profiles/modem/local.toml` once the real password
> is in it. The provider warns, without blocking, if the file is readable by others.

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

1. Read what the provider scraped.

   ```bash
   jq '.connectivity_state' ~/.cache/gtex62-core/shared/modem/local/status.json
   ```

   `status` other than `"OK"` (the `comment` says why) is the modem's own report that it is
   not registered with Comcast.

2. Confirm it on the modem itself. Open the modem's own status page: `http://192.168.100.1` in a browser, sign in with the
`username` and `password` from `~/.config/gtex62-core/profiles/modem/local.toml`, then open
the DOCSIS status page (`DocsisStatus.asp`).
   The startup table there shows the same `Connectivity State` row. The modem's own page
   is the authority: if it reads OK there and the provider says otherwise, rerun the provider
   (step 4) before doing anything else.

3. If the modem confirms it is not registered, power-cycle it: unplug it for 30 seconds,
   plug it back in, and wait several minutes for it to re-register. If it still does not
   register, the cause is on the Comcast side or in the coax, not on this machine: check
   that the coax connectors are finger-tight, then contact Comcast.

4. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/modem/fetch_modem.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/modem/local/status.json
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

1. Read the exact note. It names which table failed and, for a header mismatch, lists the
   headers the provider actually saw.

   ```bash
   jq '{state, note}' ~/.cache/gtex62-core/shared/modem/local/status.json
   ```

2. Rule out a bad response. The modem sometimes returns a login or error page in place of
   the status page, which looks like a missing table. Rerun the provider.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/modem/fetch_modem.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/modem/local/status.json
   ```

   If the note is gone, it was a one-off. Stop here.

3. If the same note returns, the modem's page layout has changed. Open the modem's own status page: `http://192.168.100.1` in a browser, sign in with the
`username` and `password` from `~/.config/gtex62-core/profiles/modem/local.toml`, then open
the DOCSIS status page (`DocsisStatus.asp`). Compare the
   column headings of the upstream table (`usTable`) and the OFDM downstream table
   (`d31dsTable`) with the keywords the provider looks for:

   ```bash
   grep -n -A8 -E '^(US|DS_OFDM)_COLUMN_MAP' ~/.config/conky/gtex62-core/providers/modem/fetch_modem.py
   ```

   A heading the provider no longer matches (for example "Lock Status" renamed) is the
   cause. The fix is in core, not in this suite: update the keyword for that column in
   `fetch_modem.py`, then run the modem regression tests beside it
   (`~/.config/conky/gtex62-core/providers/modem/test_fetch_modem_regressions.py`). This is a core code change, so make it
   in the `gtex62-core` repo.

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

1. Read the upstream channels the provider scraped.

   ```bash
   jq '[.upstream_channels[] | {id, locked}]' ~/.cache/gtex62-core/shared/modem/local/status.json
   ```

   The condition is every channel showing `"locked": false`. A healthy modem here locks
   several upstream channels.

2. Confirm it on the modem. Open the modem's own status page: `http://192.168.100.1` in a browser, sign in with the
`username` and `password` from `~/.config/gtex62-core/profiles/modem/local.toml`, then open
the DOCSIS status page (`DocsisStatus.asp`). In the upstream table, every channel's Lock
   Status should read Locked. If the modem shows Locked and the provider shows `false`,
   the provider is misreading the page: treat it as PROC: MODEM HEADER MAPPING, and rerun
   the provider first.

3. If the modem confirms nothing is locked, it cannot send data upstream, so the internet
   is probably down as well. Power-cycle the modem (unplug 30 seconds, then wait several
   minutes). If it still will not lock, check the coax connectors, then contact Comcast.

4. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/modem/fetch_modem.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/modem/local/status.json
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

1. Set the SSH alias of the host that runs MTR, in `~/.config/gtex62-core/profiles/mtr/pi5.toml`:

   ```toml
   ssh_target = "pi5"
   ```

   The value is a `Host` alias from `~/.ssh/config`, not a bare hostname you have not
   configured. Check the alias connects first:

   ```bash
   ssh -o BatchMode=yes -o ConnectTimeout=5 pi5 true; echo rc=$?
   ```

2. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/mtr/fetch_mtr.sh pi5 main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/mtr/pi5/mtr_state.json
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

MTR connects with a key, not a password, so there are no sshpass credentials to check. The
alias is `ssh_target` in `~/.config/gtex62-core/profiles/mtr/pi5.toml` (`pi5` here).

1. Read the gate. It is a circuit breaker: after an SSH failure it blocks further attempts
   for a cooldown (3s, then 10s, 30s, 120s, and 600s from the fifth failure in a row), then
   lets the provider try again by itself.

   ```bash
   GATE_STATE_DIR=~/.cache/gtex62-core/runtime/mtr bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh status
   ```

   `OK` means it has already cleared and the row follows on the next poll.
   `TRIPPED|left=N|fails=N|reason=...` means it is still holding. `fails` is how many
   attempts in a row have failed, so a high number means the cause has persisted.

2. Run the exact SSH hop the provider uses.

   ```bash
   ssh -o BatchMode=yes -o ConnectTimeout=5 pi5 true; echo rc=$?
   ```

   `rc=0` means SSH works. Otherwise read the message:

   - `Permission denied (publickey)`: the key was not offered or is not authorized there.
     `BatchMode` never prompts, so a passphrase-protected key that is not loaded in
     `ssh-agent` fails here even though a plain `ssh pi5` works for you. Check with
     `ssh-add -l`, and see which key the alias uses with `ssh -G pi5 | grep identityfile`.
   - `Connection timed out`, `No route to host`, `Connection refused`: the host is down or
     unreachable. Ping its address (shown by `ssh -G pi5 | grep ^hostname`).
   - `Host key verification failed`: the host's key changed. If you know why (a reinstall),
     clear the old one with `ssh-keygen -R <hostname>`.
   - `Could not resolve hostname`: the alias is missing from `~/.ssh/config`.

3. Once the test passes, clear the gate rather than waiting out the cooldown. This
   fixes nothing by itself: if the cause is still there, the next poll trips it again.

   ```bash
   GATE_STATE_DIR=~/.cache/gtex62-core/runtime/mtr bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh reset
   ```

4. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/mtr/fetch_mtr.sh pi5 main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/mtr/pi5/mtr_state.json
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

1. Check which case applies.

   ```bash
   ls ~/.config/gtex62-core/profiles/net/
   grep -n -A3 '^\[cache\]' ~/.config/gtex62-core/profiles/net/local.toml
   ```

   No file listed: it is missing. A file with no `[cache]` lines, or a `[cache]` section
   without the key: the key is missing.

2. Fix it.

   - File missing: run `bash ~/.config/conky/gtex62-core/bin/gtex62-core-bootstrap-runtime`. It prints `write`
     for what it installed and `skip` for what already existed.
   - File present, key missing: add to `~/.config/gtex62-core/profiles/net/local.toml`:

     ```toml
     [cache]
     ttl_sec = 1
     ```

     If a `[cache]` header is already there, add only the key beneath it.

3. Restart the suite. This step is not optional.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice).

4. Confirm NET is refreshing every second. The two timestamps should differ.

   ```bash
   f=~/.cache/gtex62-core/shared/net/local/status.json; stat -c %y $f; sleep 3; stat -c %y $f
   ```

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

1. Check this suite's loop is alive. The launcher keeps one PID file per domain loop.

   ```bash
   kill -0 "$(cat ~/.cache/gtex62-core/runtime/pids/doctor-net-refresh.pid 2>/dev/null)" 2>/dev/null && echo ALIVE || echo DEAD
   ```

   - `ALIVE`: go to step 3.
   - `DEAD`, or no PID file: go to step 2.

2. Restart the suite. The launcher starts every domain's initial refresh and loop at
   startup, so a restart brings back a dead one.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice). Repeat step 1.

3. The loop is alive but the cache is still missing or stale. Run the provider once by hand
   and read what it reports.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/net/fetch_net.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/net/local/status.json
   ```

   `state` of `"ok"` means the cache is written and the row clears on Doctor's next
   refresh. Any other `state`: read `note` and follow the procedure for it.

> **NOTE:** The loops exit when the suite's Conky window does (each checks that
> Conky is still running on every cycle). Closing or crashing the Doctor window is the
> usual way a loop dies. `doctor-` in the PID file name is the suite ID; a cache fed by
> another suite's launcher uses that suite's ID (`sitrep-`, `osa-`). A fresh cache does
> not prove *this* suite's loop is alive: another suite's loop can be refreshing the same
> shared file.
>
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

1. See which fields are empty and which interface NETWORK is watching.

   ```bash
   jq '.' ~/.cache/gtex62-core/shared/network/local/current.json
   ```

   Look at `wan_ip`, `dns`, `gateway` and the interface name.

2. Check the interface exists and is up. The name comes from `primary_interface` under
   `[network]` in `~/.config/gtex62-core/site.toml`. If none is set, NETWORK uses the
   interface of the default route.

   ```bash
   awk -F'"' '/^primary_interface/{print $2}' ~/.config/gtex62-core/site.toml
   ip -br link
   ```

   The configured name must appear in `ip -br link` and read `UP`. A wrong name (a renamed
   NIC, a typo) empties all three fields. Correct `primary_interface` in `site.toml`.

3. Run the check for each field that was named, the same way the provider gets it.

   - `gateway`:

     ```bash
     ip route show default
     ```

     A line starting `default via <address>` is the gateway. No output means no default
     route: the connection itself is down.

   - `dns`:

     ```bash
     resolvectl dns <interface>
     ```

     Use the interface from step 2. It should list at least one address. None means DNS is
     not configured on that link.

   - `wan_ip`:

     ```bash
     curl -4fsS --max-time 2 https://api.ipify.org
     ```

     It should print your public address. A curl error means outbound internet is failing.
     A VPN will show the VPN's address here, which is expected.

4. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/network/fetch_network.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/network/local/status.json
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

1. Check which case applies.

   ```bash
   ls ~/.config/gtex62-core/profiles/orb/
   grep -n -A3 '^\[cache\]' ~/.config/gtex62-core/profiles/orb/home.toml
   ```

   No file listed: it is missing. A file with no `[cache]` lines, or a `[cache]` section
   without the key: the key is missing.

2. Fix it.

   - File missing: run `bash ~/.config/conky/gtex62-core/bin/gtex62-core-bootstrap-runtime`. It prints `write`
     for what it installed and `skip` for what already existed.
   - File present, key missing: add to `~/.config/gtex62-core/profiles/orb/home.toml`:

     ```toml
     [cache]
     ttl_sec = 60
     ```

     If a `[cache]` header is already there, add only the key beneath it.

3. Restart the suite. This step is not optional.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice).

4. The row clears once Doctor next checks the profile. ORB's configured and fallback cadence
   are both 60s, so the cache itself looks the same either way.

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

1. Set the SSH alias of the pfSense box in `~/.config/gtex62-core/site.toml` (preferred):

   ```toml
   [pfsense]
   ssh_target = "pf"
   ```

   A top-level `ssh_target` in `~/.config/gtex62-core/profiles/pfsense/main_router.toml` overrides it. The
   value is a `Host` alias from `~/.ssh/config`. Check the alias connects first:

   ```bash
   ssh -o BatchMode=yes -o ConnectTimeout=5 pf true; echo rc=$?
   ```

2. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/pfsense/fetch_pfsense.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/status.json
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

PFSENSE connects with a key, not a password, so there are no sshpass credentials to check.
The alias is `ssh_target` in `[pfsense]` of `~/.config/gtex62-core/site.toml` (`pf` here).
PFSENSE has four gates, one per script, so read all of them:

1. Read the gates. Each is a circuit breaker: after an SSH failure it blocks further
   attempts for a cooldown (3s, then 10s, 30s, 120s, and 600s from the fifth failure in a
   row), then lets the provider try again by itself.

   ```bash
   for d in pfsense router pfblockerng pfsense_ifaces; do
     printf '%s: ' $d
     GATE_STATE_DIR=~/.cache/gtex62-core/runtime/$d bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh status
   done
   ```

   `OK` means a gate has already cleared. `TRIPPED|left=N|fails=N|reason=...` means it is
   still holding, and `fails` shows how many attempts in a row have failed.

2. Run the exact SSH hop the providers use.

   ```bash
   ssh -o BatchMode=yes -o ConnectTimeout=5 pf true; echo rc=$?
   ```

   `rc=0` means SSH works. Otherwise read the message:

   - `Permission denied (publickey)`: the key was not offered or is not authorized there.
     `BatchMode` never prompts, so a passphrase-protected key that is not loaded in
     `ssh-agent` fails here even though a plain `ssh pf` works for you. Check with
     `ssh-add -l`, and see which key the alias uses with `ssh -G pf | grep identityfile`.
   - `Connection timed out`, `No route to host`, `Connection refused`: the host is down or
     unreachable. Ping its address (shown by `ssh -G pf | grep ^hostname`).
   - `Host key verification failed`: the host's key changed. If you know why (a reinstall),
     clear the old one with `ssh-keygen -R <hostname>`.
   - `Could not resolve hostname`: the alias is missing from `~/.ssh/config`.

3. Once the test passes, clear the gates rather than waiting out the cooldown. This fixes
   nothing by itself: if the cause is still there, the next poll trips them again.

   ```bash
   for d in pfsense router pfblockerng pfsense_ifaces; do
     GATE_STATE_DIR=~/.cache/gtex62-core/runtime/$d bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh reset
   done
   ```

4. Rerun the main provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/pfsense/fetch_pfsense.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/status.json
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

1. Identify the stale sub-cache. The DCM entry names it. To see for yourself, list the
   files by age; the oldest enabled one is the stale one.

   ```bash
   ls -l --time-style=+%T ~/.cache/gtex62-core/shared/pfsense/main_router/
   ```

   | Sub-cache | File | Script | Gate directory |
   | --- | --- | --- | --- |
   | `status` | `status.json` | `fetch_pfsense.sh` | `pfsense` |
   | `arp`, `leases` | `arp.json`, `leases.json` | `fetch_pfsense.sh` | `pfsense` |
   | `router` | `router.json` | `fetch_router.sh` | `router` |
   | `pfblockerng` | `pfblockerng.json` | `fetch_pfblockerng.sh` | `pfblockerng` |
   | `ifaces` | `ifaces.json` | `fetch_pfsense_ifaces.sh` | `pfsense_ifaces` |

2. Read that sub-cache's gate, using its gate directory from the table.

   ```bash
   GATE_STATE_DIR=~/.cache/gtex62-core/runtime/router bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh status
   ```

   `TRIPPED|...` means the cause is SSH: follow PROC: PFSENSE SSH GATE.

3. If the gate reads `OK`, run the sub-cache's script once by hand and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/pfsense/fetch_router.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/router.json
   ```

   Substitute the script and file from the table. If this refreshes the file, the script
   works and its loop stopped: use steps 1 and 2 of PROC: TIME NOT RUNNING with the PID file
   `doctor-<name>-refresh.pid`, where `<name>` is `pfsense`, `router`, `pfblockerng` or
   `pfsense-ifaces`.

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

1. Set the SSH alias of the Pi-hole host in `~/.config/gtex62-core/site.toml` (preferred):

   ```toml
   [pihole]
   ssh_target = "pi5"
   ```

   Or under `[pihole]` in `~/.config/gtex62-core/profiles/pfsense/main_router.toml`, which overrides it.
   The value is a `Host` alias from `~/.ssh/config`. Check the alias connects first:

   ```bash
   ssh -o BatchMode=yes -o ConnectTimeout=5 pi5 true; echo rc=$?
   ```

2. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/pfsense/fetch_pihole.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/pihole.json
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

PIHOLE connects with a key, not a password, so there are no sshpass credentials to check.
The alias is `ssh_target` in `[pihole]` of `~/.config/gtex62-core/site.toml` (`pi5` here).

1. Read the gate. It is a circuit breaker: after an SSH failure it blocks further attempts
   for a cooldown (3s, then 10s, 30s, 120s, and 600s from the fifth failure in a row), then
   lets the provider try again by itself.

   ```bash
   GATE_STATE_DIR=~/.cache/gtex62-core/runtime/pihole bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh status
   ```

   `OK` means it has already cleared and the row follows on the next poll.
   `TRIPPED|left=N|fails=N|reason=...` means it is still holding. `fails` is how many
   attempts in a row have failed, so a high number means the cause has persisted.

2. Run the exact SSH hop the provider uses.

   ```bash
   ssh -o BatchMode=yes -o ConnectTimeout=5 pi5 true; echo rc=$?
   ```

   `rc=0` means SSH works. Otherwise read the message:

   - `Permission denied (publickey)`: the key was not offered or is not authorized there.
     `BatchMode` never prompts, so a passphrase-protected key that is not loaded in
     `ssh-agent` fails here even though a plain `ssh pi5` works for you. Check with
     `ssh-add -l`, and see which key the alias uses with `ssh -G pi5 | grep identityfile`.
   - `Connection timed out`, `No route to host`, `Connection refused`: the host is down or
     unreachable. Ping its address (shown by `ssh -G pi5 | grep ^hostname`).
   - `Host key verification failed`: the host's key changed. If you know why (a reinstall),
     clear the old one with `ssh-keygen -R <hostname>`.
   - `Could not resolve hostname`: the alias is missing from `~/.ssh/config`.

3. Once the test passes, clear the gate rather than waiting out the cooldown. This
   fixes nothing by itself: if the cause is still there, the next poll trips it again.

   ```bash
   GATE_STATE_DIR=~/.cache/gtex62-core/runtime/pihole bash ~/.config/conky/gtex62-core/providers/pfsense/pf-ssh-gate.sh reset
   ```

4. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/pfsense/fetch_pihole.sh main_router
   jq '{state, note}' ~/.cache/gtex62-core/shared/pfsense/main_router/pihole.json
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

1. Check this suite's loop is alive. The launcher keeps one PID file per domain loop.

   ```bash
   kill -0 "$(cat ~/.cache/gtex62-core/runtime/pids/doctor-system-refresh.pid 2>/dev/null)" 2>/dev/null && echo ALIVE || echo DEAD
   ```

   - `ALIVE`: go to step 3.
   - `DEAD`, or no PID file: go to step 2.

2. Restart the suite. The launcher starts every domain's initial refresh and loop at
   startup, so a restart brings back a dead one.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice). Repeat step 1.

3. The loop is alive but the cache is still missing or stale. Run the provider once by hand
   and read what it reports.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/system/fetch_system.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/system/local/status.json
   ```

   `state` of `"ok"` means the cache is written and the row clears on Doctor's next
   refresh. Any other `state`: read `note` and follow the procedure for it.

> **NOTE:** The loops exit when the suite's Conky window does (each checks that
> Conky is still running on every cycle). Closing or crashing the Doctor window is the
> usual way a loop dies. `doctor-` in the PID file name is the suite ID; a cache fed by
> another suite's launcher uses that suite's ID (`sitrep-`, `osa-`). A fresh cache does
> not prove *this* suite's loop is alive: another suite's loop can be refreshing the same
> shared file.

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

1. Check this suite's loop is alive. The launcher keeps one PID file per domain loop.

   ```bash
   kill -0 "$(cat ~/.cache/gtex62-core/runtime/pids/doctor-time-refresh.pid 2>/dev/null)" 2>/dev/null && echo ALIVE || echo DEAD
   ```

   - `ALIVE`: go to step 3.
   - `DEAD`, or no PID file: go to step 2.

2. Restart the suite. The launcher starts every domain's initial refresh and loop at
   startup, so a restart brings back a dead one.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   ```

   It stops the running Doctor window first, then prompts for palette and wallpaper (Enter
   keeps the last choice). Repeat step 1.

3. The loop is alive but the cache is still missing or stale. Run the provider once by hand
   and read what it reports.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/time/fetch_time.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/time/local/status.json
   ```

   `state` of `"ok"` means the cache is written and the row clears on Doctor's next
   refresh. Any other `state`: read `note` and follow the procedure for it.

> **NOTE:** The loops exit when the suite's Conky window does (each checks that
> Conky is still running on every cycle). Closing or crashing the Doctor window is the
> usual way a loop dies. `doctor-` in the PID file name is the suite ID; a cache fed by
> another suite's launcher uses that suite's ID (`sitrep-`, `osa-`). A fresh cache does
> not prove *this* suite's loop is alive: another suite's loop can be refreshing the same
> shared file.

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

1. Check whether `piactl` is found, and where PIA put it.

   ```bash
   command -v piactl
   ls -l /opt/piavpn/bin/piactl
   ```

   - Neither exists: the PIA client is not installed. Install it from Private Internet
     Access, then go to step 3.
   - `/opt/piavpn/bin/piactl` exists but `command -v piactl` prints nothing: it is
     installed but not on `PATH`. Go to step 2.
   - `command -v piactl` prints a path in your shell but the row still reads `piactl not
     found`: the suite was started from an environment with a different `PATH`. Go to
     step 3.

2. Put `piactl` on the standard path.

   ```bash
   sudo ln -s /opt/piavpn/bin/piactl /usr/local/bin/piactl
   ```

3. Restart the suite so the loops inherit the corrected `PATH`, then confirm.

   ```bash
   bash ~/.config/conky/gtex62-doctor/scripts/start-conky.sh
   bash ~/.config/conky/gtex62-core/providers/vpn/fetch_vpn.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/vpn/local/vpn.json
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

1. Run the exact command the provider runs, without printing its output. It must succeed
   and must not ask for a password (`-n` forbids prompting).

   ```bash
   sudo -n wg show wgpia0 dump > /dev/null && echo RULE OK || echo RULE MISSING
   ```

   `RULE OK` means the rule works. `sudo: a password is required` followed by `RULE MISSING`
   means the rule is missing or does not match.

   > **CAUTION:** Do not run `wg show wgpia0 dump` without the redirect. Its first line is
   > the tunnel's private key, and it would print to your terminal and into any log or paste.

2. See which commands your user may run without a password.

   ```bash
   sudo -n -l | grep wg
   ```

   The expected line is `(root) NOPASSWD: /usr/bin/wg show wgpia0 dump`. The match is
   exact: the rule names the interface `wgpia0`, so if `[interface] name` in
   `~/.config/gtex62-core/profiles/vpn/local.toml` is anything else, it never matches.

3. If the rule is missing, create it, and validate it before relying on it.

   ```bash
   printf '%s ALL=(root) NOPASSWD: /usr/bin/wg show wgpia0 dump\n' "$USER" | sudo tee /etc/sudoers.d/gtex62-core-vpn
   sudo chmod 440 /etc/sudoers.d/gtex62-core-vpn
   sudo visudo -c -f /etc/sudoers.d/gtex62-core-vpn
   ```

   `visudo -c` must report the file as parsed OK.

   > **CAUTION:** A malformed file in `/etc/sudoers.d/` can break `sudo` for every user. Do
   > not skip the `visudo -c` check, and if it reports an error, delete the file with
   > `sudo rm /etc/sudoers.d/gtex62-core-vpn` and try again.

4. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/vpn/fetch_vpn.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/vpn/local/vpn.json
   ```

● IF `note` mentions "wg not found":

```text
-CONFIRM wg BINARY.............................................INSTALLED
```

```bash
command -v wg || sudo apt install wireguard-tools
```

Then rerun the provider as in step 4 above.

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

1. Send the same ping the provider sends, through the tunnel interface.

   ```bash
   ping -I wgpia0 -c1 -W1 1.1.1.1
   ```

   A reply with `time=` means the tunnel is passing traffic now. The failure was a single
   dropped ping and has already cleared.

2. If it fails, find out whether the tunnel or the whole connection is the problem.

   ```bash
   piactl get connectionstate
   ip -br addr show wgpia0
   ping -c1 -W1 1.1.1.1
   ```

   - The plain `ping` (no `-I`) works but the tunnel ping does not: the tunnel is the
     problem. Reconnect PIA, from the app or with `piactl disconnect` then `piactl connect`.
   - Neither works: the internet connection is down. The tunnel is not the cause; look at
     the NETWORK and CONNECT rows.
   - `wgpia0` is missing from `ip -br addr`, or `connectionstate` is not `Connected`: the VPN is
     not up. A disconnected VPN is not an error here; reconnect it if you want it on.

3. Rerun the provider and confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/vpn/fetch_vpn.sh local
   jq '{state, note}' ~/.cache/gtex62-core/shared/vpn/local/vpn.json
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

1. Put the OpenWeather key in `~/.config/gtex62-core/site.toml`, where AIR also reads it:

   ```toml
   [credentials]
   openweather_api_key = "your-key-here"
   ```

   An `owm_api_key` under `[credentials]` in `~/.config/gtex62-core/profiles/weather/home.toml` overrides it.

2. Set the coordinates, in `site.toml` (preferred) or, to override for WEATHER alone, under
   `[location]` in the weather profile:

   ```toml
   [location.home]
   lat = 35.0000
   lon = -89.0000
   ```

3. No restart is needed: the provider re-reads its TOML files on every run, so the next
poll picks the change up. Rerun it now to confirm.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/weather/fetch_openweather.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/weather/home/status.json
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

1. Read the error the fetch logged. `curl` writes its failure there, without the key.

   ```bash
   tail -n 5 ~/.cache/gtex62-core/shared/weather/home/fetch.log
   ```

   `(6)` is DNS and `(28)` is a timeout: the network. `(22) ... 401` means the key was
   rejected. `(22) ... 429` means the quota was hit.

   The log is never trimmed, and AIR and WEATHER lines carry no timestamp, so an old error
   can sit at the bottom. Run `ls -l` on `fetch.log` first: if it was last written long
   ago, the error is history, not the current fault.

2. Ask OpenWeather the same question the provider asks, and print only the HTTP status.
   The key is read from `site.toml` and never printed.

   ```bash
   SITE=~/.config/gtex62-core/site.toml
   lat=$(awk -F'= *' '/^lat/{print $2; exit}' $SITE)
   lon=$(awk -F'= *' '/^lon/{print $2; exit}' $SITE)
   key=$(awk -F'"' '/^openweather_api_key/{print $2}' $SITE)
   curl -sS -o /dev/null -w '%{http_code}\n' "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$key"
   curl -sS -o /dev/null -w '%{http_code}\n' "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$key"
   ```

   - `200`: the key and the service are fine right now. Go to the rerun step.
   - `401` or `403`: the key was rejected. Replace it (see where the key lives, below).
   - `429`: the quota is used up. Wait for the window to reset, or use a different key.
   - A curl error instead of a code (`(6)` DNS, `(28)` timeout): the network, not the key.
     Test it with `curl -sS -o /dev/null -w '%{http_code}\n' https://example.com`.

   The key lives in `[credentials] openweather_api_key` of
   `~/.config/gtex62-core/site.toml`. An `owm_api_key` under `[credentials]` in the weather
   profile overrides it. AIR uses the same OpenWeather key, so if AIR OPENWEATHER DEGRADED
   is also showing, suspect the key or quota first.

3. Rerun the provider and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/weather/fetch_openweather.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/weather/home/status.json
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

1. Read the error the fetch logged. `curl` writes its failure there, without the key.

   ```bash
   tail -n 5 ~/.cache/gtex62-core/shared/weather/home/fetch.log
   ```

   `(6)` is DNS and `(28)` is a timeout: the network. `(22) ... 401` means the key was
   rejected. `(22) ... 429` means the quota was hit.

   The log is never trimmed, and AIR and WEATHER lines carry no timestamp, so an old error
   can sit at the bottom. Run `ls -l` on `fetch.log` first: if it was last written long
   ago, the error is history, not the current fault.

2. Ask OpenWeather the same question the provider asks, and print only the HTTP status.
   The key is read from `site.toml` and never printed.

   ```bash
   SITE=~/.config/gtex62-core/site.toml
   lat=$(awk -F'= *' '/^lat/{print $2; exit}' $SITE)
   lon=$(awk -F'= *' '/^lon/{print $2; exit}' $SITE)
   key=$(awk -F'"' '/^openweather_api_key/{print $2}' $SITE)
   curl -sS -o /dev/null -w '%{http_code}\n' "https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$key"
   curl -sS -o /dev/null -w '%{http_code}\n' "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$key"
   ```

   - `200`: the key and the service are fine right now. Go to the rerun step.
   - `401` or `403`: the key was rejected. Replace it (see where the key lives, below).
   - `429`: the quota is used up. Wait for the window to reset, or use a different key.
   - A curl error instead of a code (`(6)` DNS, `(28)` timeout): the network, not the key.
     Test it with `curl -sS -o /dev/null -w '%{http_code}\n' https://example.com`.

   The key lives in `[credentials] openweather_api_key` of
   `~/.config/gtex62-core/site.toml`. An `owm_api_key` under `[credentials]` in the weather
   profile overrides it. AIR uses the same OpenWeather key, so if AIR OPENWEATHER DEGRADED
   is also showing, suspect the key or quota first.

3. Rerun the provider and read the result.

   ```bash
   bash ~/.config/conky/gtex62-core/providers/weather/fetch_openweather.sh home
   jq '{state, note}' ~/.cache/gtex62-core/shared/weather/home/status.json
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
- [AIRGRADIENT FIELDS MISSING](#airgradient-fields-missing)
- [AIRGRADIENT HOST NOT SET](#airgradient-host-not-set)
- [AIRGRADIENT NOT RUNNING](#airgradient-not-running)
- [AIRGRADIENT UNREACHABLE](#airgradient-unreachable)
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
