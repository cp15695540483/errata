# 1. One crate per responsibility under `crates/`

Date: 2026-11-15

## Context

The project grows feature by feature: a line table, then display width, then two
renderers, then a CLI. Each is independently testable and each has a different
dependency footprint: width needs Unicode tables, renderers need none, the CLI
needs IO.

## Decision

Every responsibility lives in its own package under `crates/`, named after the
responsibility, with tests next to the code as `*_wbtest.mbt`. No package mixes IO
with pure computation, and a crate is created together with its first
implemented feature rather than as an empty directory.

## Consequences

- Cross-crate imports are explicit and visible in `moon.pkg`.
- The pure crates stay usable from `wasm-gc`, `js` and `native` unchanged.
- Listing `crates/` tells a reader which capabilities exist.
