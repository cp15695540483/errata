# Deduplication check

Recorded before submission, so the claim "no package on mooncakes.io does this"
is a search statement with evidence rather than an assertion.

Run on 2026-11-25 with `moon search <keyword> --limit 6`.

## `fix`

```
6 modules found

cp15695540483/errata@0.4.1 (48 downloads)
  Apply machine-applicable fixes safely: refuse overlap, keep order independent, diff before writing. Rendering is delegated to marianoguerra/error-report.
  Repository: https://github.com/cp15695540483/errata

  cp15695540483/errata/crates/fix
    A pure fix-application library that applies, checks, verifies, and plans text edits described by @marianoguerra/error-report.Fix values. It offers safe all-or-nothing transactions over multiple files, snapshot and anchor guards against stale edits, refusal reporting, fix grouping, deduplicat
```

## `autofix`

```
5 modules found

cp15695540483/errata@0.4.1 (48 downloads)
  Apply machine-applicable fixes safely: refuse overlap, keep order independent, diff before writing. Rendering is delegated to marianoguerra/error-report.
  Repository: https://github.com/cp15695540483/errata

  cp15695540483/errata/examples/autofix_demo
    The public API documentation for cp15695540483/errata/examples/autofix_demo lists no public types, traits, errors, values, or other declarations, and no package README content is su
```

## `errata`

```
2 modules found

cp15695540483/errata@0.4.1 (48 downloads)
  Apply machine-applicable fixes safely: refuse overlap, keep order independent, diff before writing. Rendering is delegated to marianoguerra/error-report.
  Repository: https://github.com/cp15695540483/errata

  cp15695540483/errata/crates/moonc
    Provides an adapter for the Moon compiler: parses a compiler JSON diagnostic line into a Record with level, code, message, and loc fields, converts a loc such as 3:3-3:15 into a byte range o
```

## Reading

- `fix` returns errata itself plus packages where "fix" is a qualifier
  (`moonvar/fixed`, a fixed-income package); none applies fix sets to source text.
- `autofix` returns errata plus font and WebAuthn packages; `autofit` there is
  typography, not source editing.
- `errata` returns only this project.
- The nearest neighbour is `zlhahaha/moonreport`, which covers ordering, range and
  overlap validation and batch application; `docs/COMPARISON.md` records exactly
  what is shared and what errata adds.
