# Safety guarantees

This document answers, for each guarantee the project makes: what input it
needs, where it applies, what the user flow is, and a concrete case.

## Guarantee 1: stale detection

**Input basis.** A fix may carry an `expected` anchor: the exact text that was
present at the fix span when the fix was produced. Position alone cannot
detect a same-length edit; the anchor can.

**Applicability.** Anchored fixes are refused when the current text at the span
differs from `expected`. Fixes without an anchor keep positional semantics and
make no staleness claim.

**User flow.** A tool records the source text alongside the fix. Before
applying, `check_addressed` reads the span, compares it to the anchor, and
refuses with `Stale(i)` on mismatch. Nothing is written.

**Case.** Source `abc`, fix `{span:1..2, replacement:X, expected:Some("b")}`.
If the file has become `adc` (same length, different character), position would
still allow the edit, but the anchor refuses it. If the file is still `abc`,
the edit applies and produces `aXc`.

## Guarantee 2: repeated runs change nothing

**Input basis.** The applied result is compared to the input. When they are
equal, the operation reports `unchanged` instead of `applied`. An anchored
insertion that has already been applied cannot find its anchor again and is
refused as stale rather than inserted twice.

**Applicability.** `apply_all` counts a file as applied only when its text
changes. `apply_addressed` refuses a re-run of an anchored insertion whose
anchor no longer matches.

**User flow.** Run the same manifest twice. The first run applies and reports
the file. The second run finds either an unchanged text (reported `unchanged`)
or a moved anchor (refused as stale). Neither is a second edit.

**Case.** Insert `XY` at offset 1 with anchor `Some("b")` (the text to the
gives `aXYbc`. Second run on `aXYbc` finds the character at the insertion point
is no longer `b` and refuses as stale; it does not insert a second `XY`.

## Guarantee 3: overlap and boundary

**Input basis.** Byte ranges and a UTF-8 buffer.

**Applicability.** Two intersecting ranges are refused; a range that starts or
ends inside a multi-byte character is refused.

**User flow.** `check` runs first, before any text is produced.

**Case.** Fixes `{0..2}` and `{1..2}` on `abcd` are refused as overlapping.
A fix `{1..2}` on `中` (bytes 0..3) is refused as not on a character boundary.

## What this does not promise

It does not re-run the compiler. There is no subprocess API in the MoonBit
core library, so a fixpoint loop must be driven by a shell script. It does not
parse MoonBit syntax, and it does not guarantee a fix is semantically correct,
only that the text it replaces is the text it was told to replace.

