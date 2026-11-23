# Safety guarantees

For each guarantee: the mechanism, the boundary, and a case. Every case is a
test in `crates/fix/addressed_wbtest.mbt`, so the document cannot drift from
the code.

## Guarantee 1: a re-run does not modify the file a second time

### Mechanism

A fix may carry a **file snapshot**: the hash of the whole text the fix was
produced against. `snapshot_of(text)` is two independently seeded FNV-1a
hashes concatenated (64 bits of output). `check_addressed` recomputes the
snapshot of the current text and refuses the whole set as `Stale(i)` when it
differs. Position and range anchors are not used for this decision, because
they look at the same bytes the previous run just wrote.

### Why a range anchor is not enough

Anchoring the text to the right of an insertion point fails when the inserted
text equals the anchor. Case:

```
text      = "abc"
fix       = insert "b" at offset 1, range anchor Some("b")
run 1     -> "abbc"          (the anchor "b" matched)
run 2     -> reads "b" at offset 1, which is the b run 1 inserted
             the anchor matches again, so it inserts again -> "abbbc"
```

The same fix with a snapshot of `"abc"` refuses at run 2, because the file now
hashes to the hash of `"abbc"`. Both halves are asserted: the snapshot stops
the repeat, and the anchor-only variant is kept as a test so the boundary is
executable rather than a claim.

### Boundary

- The snapshot identifies a **content state**, not an operation history. If a
  file is edited back to exactly its earlier bytes, the snapshot matches again
  and the fix applies. That is intended: "unchanged content" is the contract,
  not "this command was not run before".
- A fix without a snapshot keeps positional semantics and makes no re-run
  claim. This is deliberate: a caller that omits the snapshot has told the
  library it does not want the check.
- The snapshot is 64 bits. It is a guard against a stale fix, not a
  cryptographic signature; a deliberate collision is out of scope.
- One snapshot covers one file. A transaction that touches several files needs
  one snapshot per file, which is what `apply_all` expects.

## Guarantee 2: a changed file is not edited at the wrong position

### Mechanism

Two independent checks run before any text is produced: the file snapshot
(above), and a **range anchor** `expected` — the exact text of the replaced
range when the fix was produced. `check_addressed` reads the range and refuses
on mismatch.

### Case

Source `abc`, fix `{start:1, len:1, replacement:"X", expected:Some("b")}`. If
the file became `adc` (same length, different character) the range anchor
refuses it; positional application alone would have replaced `d`.

### Boundary

A same-length edit outside the replaced range is caught by the snapshot, not by
the range anchor. Neither check understands syntax: the library guarantees the
bytes it replaces are the bytes it was told to replace, not that the edit is
semantically correct.

## Guarantee 3: no overlap, no broken character

### Mechanism

`check` refuses intersecting ranges and any range that starts or ends inside a
multi-byte character, before any text is produced.

### Case

`{0..2}` and `{1..2}` on `abcd` are refused as overlapping. `{1..2}` on `中`
(bytes 0..3) is refused as not on a character boundary.

## Guarantee 4: all-or-nothing across files

### Mechanism

`apply_all` dry-checks every file first and reports the failing path. The
caller writes only when it returns `AllApplied`. A refused transaction leaves
every file untouched.

### Case

Two plans, the second with a range past the end of its file: the result is
`Refused("b", ...)` and the first file is not written. A file whose text would
not change is not counted as applied.

## What is out of scope

No compiler re-run (the MoonBit core library has no subprocess API, so a
fixpoint loop must be driven by a shell script). No syntax parsing. No claim
that a fix is semantically right — only that it lands where it was aimed, once.

