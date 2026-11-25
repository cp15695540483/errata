# errata

[![ci](https://github.com/cp15695540483/errata/actions/workflows/ci.yml/badge.svg)](https://github.com/cp15695540483/errata/actions/workflows/ci.yml)

Apply the fixes a tool already knows about, without corrupting the file.

errata is the missing half of source diagnostics. Rendering a snippet is a
solved problem: [marianoguerra/error-report](https://github.com/marianoguerra/shrubbery-mb)
already holds the report model and prints rich, short and JSON output. What no
MoonBit package does is take a set of machine-applicable fixes and land them
safely. errata does that, and reuses error-report for everything else.

## What this project adds

| Capability | State |
| --- | --- |
| Check a fix set before touching the file: range, character boundary, intersection | implemented |
| Apply a fix set in one pass, refusing instead of corrupting | implemented |
| Refuse a stale set whose range no longer fits the current text | implemented |
| All-or-nothing transaction across files, reporting the failing path | implemented |
| Order independence: the same set applies the same way whatever the input order | implemented |
| Manifest parsing, grouped per file, one bad line does not hide the rest | implemented |
| Unified-style diff for a dry run | implemented |
| `errata fix <manifest> [--write]` | implemented |
| `errata render <json-record> <source>` through error-report | implemented |
| Fixpoint loop that re-checks after applying | not implemented |
| Report set: sort, dedupe, group, summary counts, exit codes | not implemented |

## What this project deliberately does not do

- It does not render diagnostics. `error-report` does, and a second renderer
  would only drift from it.
- It does not implement display width, tab expansion or CJK alignment.
  `error-report/render` owns those.
- It does not parse MoonBit syntax, run the compiler, or replace `moon fmt`.

## Requirements

- MoonBit toolchain `0.1.20261104` or newer; that is the version this project is developed and tested against.
- `wasm-gc` and `js` are built and tested on every CI run. `native` needs a C toolchain: gcc on Linux, MSVC Build Tools with the Windows SDK on Windows.
- `snapshot_of` is a 64-bit content hash used to refuse a stale fix set. It is a guard, not a cryptographic signature.
- A file is read into memory as a whole, so the practical input limit is available memory rather than a fixed byte cap.
- A manifest is UTF-8 TSV: `path<TAB>start<TAB>len<TAB>replacement`, byte offsets, `#` comments. Malformed lines are skipped.

## Install

```bash
moon add cp15695540483/errata
moon add marianoguerra/error-report
```

The second dependency is required because the library API takes `@error-report.Fix`
values directly, so a caller constructs them in their own code.

## Usage

The commands below run from a checkout of this repository. The published package
provides the library API; it does not install a standalone executable, because
build artifacts are not part of a mooncakes package.

Render one compiler record the toolchain prints:

```bash
moon run cmd/errata -- render '{"level":"error","error_code":4014,"loc":"1:9-1:10","message":"Expr Type Mismatch"}' 'let y = x + 1'
```

Preview a fix set (no write):

```bash
moon run cmd/errata -- fix fixes.tsv
```

A manifest is one fix per line, tab separated:

```
# path	start	len	replacement
src/lib.mbt	8	1	y
```

Add `--write` to apply. A file whose text would not change is reported as
`unchanged`, so a second run is visibly a no-op rather than a second edit.

## From the library

A caller adds both packages, imports `@error-report` for the types and `@fix`
for the application layer, then:

```moonbit
let fixes : Array[@error-report.Fix] = [
  {
    source: @error-report.SourceId(0),
    span: @error-report.Span::{ start: 8, len: 1 },
    replacement: "y",
    description: "",
  },
]
match @fix.apply("let y = x + 1", fixes) {
  Applied(text) => println(text)
  Refused(reason) => println(@fix.describe(reason))
}
```

## Documentation

- [docs/DESIGN.md](docs/DESIGN.md) - layering, invariants and roadmap
- [docs/PORTING.md](docs/PORTING.md) - what is reused, what is new, and why
- [docs/adr](docs/adr) - decision records

## Publicity

The project may be named and shown in contest publicity material with attribution.

## License

MIT, see [LICENSE](LICENSE).

