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
| Display width (CJK, emoji, tabs) in columns | planned |
| ANSI snippet renderer | planned |
| HTML snippet renderer | planned |
| `errata` CLI | planned |

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

## Documentation

- [docs/DESIGN.md](docs/DESIGN.md) - layering, invariants and roadmap
- [docs/PORTING.md](docs/PORTING.md) - upstream projects that inform the design
- [docs/adr](docs/adr) - decision records

## License

MIT, see [LICENSE](LICENSE).
