# Dependencies and their licences

| Package | Version | Licence | What errata uses |
| --- | --- | --- | --- |
| `marianoguerra/error-report` | 0.1.2 | Apache-2.0 (`LICENSE` in the package) | `Report`, `Label`, `Span`, `Source`, `Sources`, `Fix`, and all rendering through `render_string` |
| `moonbitlang/x` | 0.5.7 | Apache-2.0 (`moon.mod` field and `licenserc.toml`) | `x/fs` for reading and writing files in the CLI |

Both are permissive and compatible with this project MIT licence. Nothing is
vendored: the packages are declared in `moon.mod` and resolved by the toolchain.

Reference only, not a dependency: `rustfix` (rust-lang/cargo, MIT OR Apache-2.0)
informs the three guarantees (no overlap, no stale span, no half-written file);
no code is copied from it.
