# Reuse and provenance

This project exists because a renderer already exists. Being explicit about
that is the point of this file.

## Dependency

| Package | Version | License | What errata uses |
| --- | --- | --- | --- |
| `marianoguerra/error-report` | 0.1.2 | Apache-2.0 | `Report`, `Label`, `Span`, `Source`, `Sources`, `Fix`, and all rendering (`render_string`, `rich`, `short`, `json`), including display width, tab expansion and CJK alignment |

It is declared in `moon.mod` and imported, not copied. Nothing from it lives in
this repository.

## Net contribution

error-report carries fixes as data (`Fix { source, span, replacement, description }`)
and offers no way to apply them. errata adds exactly that layer:

- a checker that reports range, boundary and intersection problems;
- an applier that refuses rather than producing a corrupt file;
- order-independent application;
- a manifest format and its parser;
- a dry-run diff;
- a command that ties the above to the compiler JSON format.

## Semantic reference

| Project | License | What informs the semantics |
| --- | --- | --- |
| rustfix, part of rust-lang/cargo | MIT OR Apache-2.0 | what "applying a suggestion" must guarantee: no overlap, no stale span, no partial write |

No code has been copied from either project. If a later change adapts code, the
file will carry the upstream notice and `NOTICE` will reproduce the license.

## Deliberately out of scope

Rendering, display width, CJK alignment, styling and the report model: owned by
error-report. Re-implementing them here would produce the drift this project
exists to avoid.

