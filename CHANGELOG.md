# Changelog

All notable changes to this project are documented here. The format follows
Keep a Changelog and the project uses Semantic Versioning.

## Unreleased

### Added

- `crates/span`: `LineIndex` builds a line table from a UTF-8 buffer and maps
  every valid byte offset to a 1-based `Location { line, column }`; `
` and
  `
` input agree on line numbering.
- `LineIndex::line_start`, `line_count` and `byte_length`.
- White-box tests for the first byte, in-line columns, line breaks, CRLF versus
  LF, the offset past the last byte, empty input, multi-byte text and
  out-of-range offsets.
