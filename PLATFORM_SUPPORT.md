# Platform support policy

MeerkatKit tracks **Apple’s latest stable OS releases** (betas excluded). Package semver (`0.0.x`) is unrelated to deployment targets.

## Supported major versions (3)

We support the **three most recent major OS releases** per platform (stable only).

| Platform | Supported majors (current) | Drop rule |
|----------|---------------------------|-----------|
| iOS / iPadOS | 17, 18, 26 | When iOS 27 ships stable → drop 17 → support 18, 26, 27 |
| macOS | 14, 15, 26 | When macOS 27 ships stable → drop 14 → support 15, 26, 27 |
| tvOS | 17, 18, 26 | Same pattern as iOS |

iPadOS uses the iOS deployment target and build.

## Minimum deployment (minor follows latest stable)

The **minimum** deployment version uses:

1. **Major** = oldest supported major (e.g. iOS **17**)
2. **Minor** = minor component of the **latest stable** OS on that platform (e.g. iOS **26.5.2** → minor **5**)

**Formula:** `min = {oldestMajor}.{latestStableMinor}`

| Latest stable | Minimum iOS | Minimum macOS | Minimum tvOS |
|---------------|-------------|---------------|--------------|
| 26.5.x | 17.5 | 14.5 | 17.5 |
| 26.6.x | 17.6 | 14.6 | 17.6 |

When Apple ships a new **0.1** stable (e.g. 26.5 → 26.6), bump all minimum minors in `Package.swift` and run CI.

Patch releases (26.5.1 → 26.5.2) do **not** change the minimum unless the minor digit changes.

## Maintenance

1. Update `scripts/platform-targets.json` when Apple releases a new **stable** version (not beta).
2. Run: `node scripts/sync-platform-targets.mjs`
3. Verify: `xcodebuild -scheme MeerkatKit … build test`
4. Commit `Package.swift` + `platform-targets.json` (not tied to `0.0.x` package tags unless you choose to release).

## CI

Job names show the **minimum deployment** from `Package.swift` (e.g. `iOS (deploy ≥17.5)`).

The runner picks an available iOS Simulator (often iOS 18.x on `macos-15`) to **build and test** the package. Simulator OS version is not the same as the deployment target — xcodebuild still compiles with `-target …-ios17.5-simulator`.

## Current targets (auto-synced)

See `scripts/platform-targets.json` for the source of truth used by `sync-platform-targets.mjs`.
