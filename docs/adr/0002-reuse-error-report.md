# 2. Depend on error-report instead of owning a renderer

Date: 2026-11-18

## Context

An earlier version of this repository implemented spans, display width, snippet
layout, an ANSI backend and an HTML backend. `marianoguerra/error-report` (0.1.2,
Apache-2.0) already covers all of that, including display width, tab expansion,
CJK alignment, ellipsis clipping and a JSON backend.

Maintaining a second renderer would mean two implementations of the same idea
drifting apart, and it leaves the actual gap untouched: nothing applies a fix
set safely.

## Decision

Delete the local renderer crates. Depend on error-report for the diagnostic
model and all rendering. Keep and grow `crates/fix`, which owns checking and
application, and `crates/moonc`, which adapts the compiler JSON record.

## Consequences

- The repository is smaller and its purpose is one sentence.
- A rendered snippet shows error-report output, so upstream improvements arrive
  for free.
- The project is judged on the application layer, which is the part that did not
  exist before.

