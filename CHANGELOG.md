# Changelog

The format follows Keep a Changelog and the project uses Semantic Versioning.

## 0.4.2

### Added

- `--help` lists the commands, the options and the exit-status policy;
  `tools/e2e.sh` asserts it, and also asserts that a refused set and a missing
  manifest still exit 0 so a CI step can read the report as data.
- `docs/TEST-MATRIX.md` maps every public function to its test references; two
  functions that were only reached through their callers now have their own
  assertions.
- `docs/DEPENDENCIES.md` and `docs/DEDUP.md` record the dependency licences and
  the keyword searches behind the no-duplicate claim.
- README gains `## Requirements` (toolchain version, backends, what the 64-bit
  snapshot is and is not, the real input limit) and `## Publicity`.

### Fixed

- `field()` refused a numeric JSON value because it only accepted a quoted
  string, so `error_code` never reached the rendered report.

## 0.4.1

### Changed

- `snapshot_of` now uses standard FNV-1a 32 (computed in Int64 so the offset
  basis fits) with two offset bases, and the tests pin the published vectors
  `811c9dc5`, `e40c292c`, `1a47e90b`, `bf9cf968`. The previous version masked to
  31 bits each round, so it could not be checked against a reference.
- README states that the CLI runs from a checkout and that the package ships the
  library API, not a standalone executable.

## 0.4.0

### Changed

- **Breaking:** `AddressedFix` gained a `snapshot` field. A fix can now carry the
  hash of the whole file it was produced against; a re-run is recognised by the
  bytes of the file rather than by a range anchor, so an insertion whose text
  equals its anchor is no longer applied twice.
- `snapshot_of(text)` exposes the hash so a caller can record it when producing
  fixes.

### Added

- Tests for the equal-anchor insertion case, and for the anchor-only variant that
  still repeats, so the boundary is executable.

## 0.3.0

### Added

- `AddressedFix` and `check_addressed` / `apply_addressed`: a fix may carry an
  `expected` anchor; same-length edits that changed the text are refused as
  stale, and an empty insertion anchors on the text to its right so a re-run
  refuses instead of inserting twice.

## 0.2.0

### Changed

- **Breaking:** rendering and the diagnostic model now come from
  `marianoguerra/error-report@0.1.2`. The local `span`, `width`, `diagnostic`,
  `render_ansi` and `render_html` crates are removed, together with their public
  API. A snippet is produced by passing a `Report` to `render_string`.
- `errata render` takes a compiler JSON record and the source text, and prints
  the snippet error-report renders.

### Added

- `crates/fix`: `check` reports range, character-boundary and intersection
  problems without touching the text; `apply` refuses instead of corrupting;
  edits are sorted so input order cannot change the result; adjacent ranges are
  allowed and an empty range inserts.
- `crates/fix`: manifest parsing (one fix per line, tab separated, grouped per
  file, a malformed line is skipped) and `diff` for a dry run.
- `errata fix <manifest> [--write]`: dry-run diff by default, `unchanged` for a
  file whose text would not change.

## 0.1.0

First published version: byte offset to line and column, display width, snippet
rendering and a compiler JSON adapter. Superseded by 0.2.0, which reuses
error-report for those responsibilities.

