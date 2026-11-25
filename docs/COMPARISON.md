# Comparison with moonreport

What `zlhahaha/moonreport@0.1.0` already provides, and what errata adds. The
point of this file is to keep the proposal honest: three of the capabilities
errata once listed as its own are covered upstream, so they are not claimed.

## How this was checked

```bash
moon new probe && cd probe && moon add zlhahaha/moonreport
# then read .mooncakes/zlhahaha/moonreport/fix.mbt and fix_plan.mbt
grep -rn "fnv\|snapshot\|digest\|hash" .mooncakes/zlhahaha/moonreport
grep -rn "stale\|idempot\|re-run" .mooncakes/zlhahaha/moonreport
```

## Matrix

| Capability | moonreport 0.1.0 | errata | Verdict |
| --- | --- | --- | --- |
| Fix data model | `pub struct Fix`, `TextEdit` (UTF-8 byte range) | `@error-report.Fix`, `AddressedFix` | shares upstream |
| Ordering | `FixPlan` orders by `span.start()` | `sorted` | shared, not claimed |
| Range / out-of-bounds check | `FixValidation` with out-of-bounds cases | `check` → `OutOfRange` | shared, not claimed |
| Overlap / conflict check | error text `overlapping edits in source` | `check` → `Overlap` | shared, not claimed |
| Cross-file batch apply | `FixPlan::apply`, `FixMode` | `apply_all` | shared, not claimed |
| Character boundary check | not found | `check` → `NotBoundary` | errata only |
| Range anchor (`expected`) | absent | `AddressedFix.expected` | errata only |
| File snapshot / re-run detection | absent (no hash symbol; no stale or idempotence concept) | `snapshot_of`, `Refusal::Stale` | errata only |
| Unified diff | `fix_render.mbt` renders fixes | `diff` | partial overlap |

## What errata still claims

1. Content addressing: a range anchor plus a whole-file snapshot.
2. Re-run recognition: a second run of the same fix set is refused, including
   the case where the inserted text equals the anchor.
3. Character boundary refusal.
4. Unified diff output.

Ordering, range and overlap validation, and cross-file batch application are
named as shared with moonreport rather than claimed as new work.

