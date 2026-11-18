# Changelog

The format follows Keep a Changelog and the project uses Semantic Versioning.

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

