# Provenance

`errata` is an independent MoonBit implementation. No source code has been
copied from another project; the following upstream projects inform the design
and are listed so the lineage is explicit.

| Project | Language | License | What informs this repository |
| --- | --- | --- | --- |
| ariadne | Rust | MIT | multi-label snippet layout, caret placement |
| miette | Rust | Apache-2.0 | report structure and diagnostic chain |
| codespan-reporting | Rust | Apache-2.0 | terminal rendering of labelled spans |
| rich | Python | MIT | traceback framing and colour use |

If a later change adapts code from one of them, the file will carry that
project copyright notice and its license will be reproduced in `NOTICE`.
