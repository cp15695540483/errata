# Changelog

All notable changes to this project are documented here. The format follows
Keep a Changelog and the project uses Semantic Versioning.

## Unreleased

### Added

- `examples/render_demo`: a runnable program that renders one diagnostic.
  Its real output is checked in as `examples/render_demo/expected.txt`, so the
  documented snippet cannot drift from what the renderer prints.

- `crates/cli`: read the compiler JSON diagnostic line format. `field` decodes a
  string or number field, `display_path` keeps only the file name so a snippet
  never repeats a machine directory, `span_from_loc` turns `line:col-line:col`
  into a byte span and `render_json` produces the snippet.

- `crates/render_html`: render a diagnostic as an HTML figure. The snippet is the
  plain-text layout with markup escaped, so a source line containing an angle
  bracket or an ampersand cannot break the page; notes stay inside the snippet.

- `crates/render_ansi`: render a diagnostic against its source into plain text.
  A header carries severity and code, every label renders its source line with an
  expanded-tab copy and a caret aligned by display column, and notes follow as
  `= note:` lines. Nine white-box tests pin the exact output.

- `crates/width`: `decode_utf8`, `codepoint_width`, `column_after` and
  `text_width`. Control characters and combining marks take no column, CJK and
  emoji take two, and a tab jumps to the next multiple of the tab width.

- `crates/diagnostic`: `Span`, `Label` (focused or context) and an immutable
  `Diagnostic` carrying severity, code, headline, labels and notes. Builders copy
  the array they extend, so a derived diagnostic never mutates its source.

- `crates/span`: `LineIndex` builds a line table from a UTF-8 buffer and maps
  every valid byte offset to a 1-based `Location { line, column }`; `
` and
  `
` input agree on line numbering.
- `LineIndex::line_start`, `line_count` and `byte_length`.
- White-box tests for the first byte, in-line columns, line breaks, CRLF versus
  LF, the offset past the last byte, empty input, multi-byte text and
  out-of-range offsets.
