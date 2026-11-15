# errata

Readable source diagnostics for MoonBit: map a byte offset to a 1-based
`(line, column)` and render the surrounding source as an annotated snippet.

Pure MoonBit, no FFI, and no IO in the core crates, so the same code runs on
`wasm-gc`, `js` and `native`.

## Status

Every row describes what is in the repository today; nothing is claimed ahead
of its implementation.

| Capability | State |
| --- | --- |
| Line table: byte offset to `(line, column)`, `
` and `
` agree | implemented |
| `LineIndex::line_start`, `line_count`, `byte_length` | implemented |
| Diagnostic model: severity, code, labelled spans, notes | implemented |
| Display width: control 0, combining 0, CJK and emoji 2, tab stops | implemented |
| Plain-text renderer: header, code line, caret, notes | implemented |
| HTML renderer: escaped markup wrapped around the plain-text snippet | implemented |
| Compiler JSON adapter: parse one diagnostic line into a rendered snippet | implemented |
| `errata` CLI: render one compiler record, file name only | implemented |

## Quick start

```bash
moon check
moon test
```

```moonbit
let index = @span.LineIndex::from_string("line one
line two")
match index.locate(9) {
  Some(loc) => println("\{loc.line}:\{loc.column}")
  None => println("offset out of range")
}
```

`locate` accepts every offset from `0` through `byte_length()` inclusive; the
offset equal to the buffer length is the position just past the last byte.

## Runnable example

`examples/render_demo` renders one diagnostic and prints the snippet:

    moon run examples/render_demo

    error: unknown type
      ╭─[ demo.mbt:1:9 ]
    1 │ let y = x + 1
      │         ^ unknown type

The file name is always a base name: a compiler path is absolute, and a
snippet must not repeat a machine directory.

## Command line

The executable takes the record the toolchain prints and the source text:

    moon run cmd/errata -- '{"level":"error",...}' 'let y = x + 1'

Output:

    error: Expr Type Mismatch
      ╭─[ bad.mbt:1:9 ]
    1 │ let y = x + 1
      │         ^ Expr Type Mismatch

The file name in the header is always a base name, because a compiler path is
absolute and a snippet must not repeat a machine directory.

## Documentation

- [docs/DESIGN.md](docs/DESIGN.md) - layering, invariants and roadmap
- [docs/PORTING.md](docs/PORTING.md) - upstream projects that inform the design
- [docs/adr](docs/adr) - decision records

## License

MIT, see [LICENSE](LICENSE).
