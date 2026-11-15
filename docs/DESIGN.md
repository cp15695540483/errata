# Design

## Purpose

`errata` turns a raw byte offset into a human-readable location and renders the
source around it. It is a library first: a renderer is a pure function from a
report value to a `String`, so the same code serves a terminal, a browser and a
test.

## Layering

| Directory | Responsibility | State |
| --- | --- | --- |
| `crates/span` | line table, byte offset to `(line, column)`, line starts | implemented |
| `crates/diagnostic` | severity ranks, code, labelled spans, notes; owns the `Span` range type | implemented |
| `crates/width` | UTF-8 decoding, code point display width, tab expansion, column advance | implemented |
| `crates/render_ansi` | plain-text snippet layout: header, code line, caret, notes | implemented |
| `crates/render-html` | the same layout emitted as HTML with CSS classes | planned |
| `cmd/errata` | CLI wrapper | planned |

A crate is created only together with its first implemented feature. Planned
rows are intent, not code, and no empty package exists in the tree.

## Invariants

1. Offsets are UTF-8 byte offsets. Callers holding a `String` use
   `LineIndex::from_string`, which encodes once.
2. `Location` is 1-based on both axes.
3. `
` ends a line; in `
` the `` belongs to the line it terminates, so
   CRLF and LF input agree on line numbering.
4. Every offset in `0 ..= byte_length()` maps to a location; anything else is
   `None`.
5. Core crates do no IO and read no environment.

## Roadmap

A row in the README table moves to `implemented` in the same commit that adds
its tests. Order of work: display width, ANSI renderer, HTML renderer, CLI.
