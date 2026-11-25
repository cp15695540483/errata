# Design

## Purpose

Turn a set of machine-applicable fixes into either a new file or a refusal.
Nothing in between: a half-applied file is worse than an unapplied one.

## Layering

| Directory | Responsibility | IO |
| --- | --- | --- |
| `crates/fix` | check, apply, manifest parsing, diff | none |
| `crates/moonc` | compiler JSON record to an error-report `Report` | none |
| `cmd/errata` | argument parsing, file reads and writes | all of it |

`crates/fix` is pure: text in, text or a refusal out. That is why it can be
tested exhaustively and why the same code runs on every backend.

## What is reused

`marianoguerra/error-report` owns the diagnostic model (`Report`, `Label`,
`Span`, `Source`, `Sources`, `Fix`) and the renderers. errata depends on it,
constructs its types, and passes reports to `render_string`. There is no second
snippet layout in this repository.

## Invariants

1. `check` never mutates. It reports the first real problem in a fixed order:
   range, character boundary, intersection.
2. `apply` runs `check` first, so a refused set leaves the text untouched.
3. Edits are sorted by start offset, so input order cannot change the result.
4. Adjacent ranges are allowed; an empty range inserts.
5. A range may not start or end inside a multi-byte character.
6. Applying a set twice either changes nothing or is refused; it never doubles
   an edit.
7. The core crates do no IO and read no environment.

## Complexity

- `check`: O(n log n) in the number of fixes, dominated by the stable sort by start offset; the overlap sweep after it is O(n).
- `apply`: O(n + bytes), one pass over the sorted fixes and one pass over the text.
- `snapshot_of`: O(bytes), two FNV-1a 32 passes over the encoded text.
- `apply_all`: one `check` and one `apply` per file, so the sum over the transaction.
- `diff`: O(bytes) to strip the common prefix and suffix, then O(changed lines).

## Roadmap

- Fixpoint loop: after applying, re-collect diagnostics and apply again until
  the set is empty.
- Report set: sort, dedupe, group by file, summary counts, exit-code policy.
- JSON manifest in addition to the tab-separated one.

