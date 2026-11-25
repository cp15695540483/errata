# Test matrix

Every public function of `crates/fix` and `crates/moonc`, and how many times it is
named in a white-box test file. This is the reverse lookup the review asked for:
which declarations are guarded by a test and which are only reached through callers.

Regenerate with:

```bash
for f in crates/fix/*.mbt crates/moonc/*.mbt; do grep -h "^pub fn " "$f"; done \
  | sed -E "s/^pub fn ([A-Za-z0-9_]+).*/\1/" | sort -u \
  | while read -r n; do echo "$n $(grep -h "$n" crates/fix/*_wbtest.mbt crates/moonc/*_wbtest.mbt | wc -l)"; done
```

| Public function | Test references | Covered |
| --- | --- | --- |
| `apply` | 37 | yes |
| `apply_addressed` | 10 | yes |
| `apply_all` | 3 | yes |
| `apply_verified` | 6 | yes |
| `check` | 5 | yes |
| `check_addressed` | 2 | yes |
| `count` | 9 | yes |
| `dedup` | 5 | yes |
| `describe` | 3 | yes |
| `diff` | 8 | yes |
| `field` | 5 | yes |
| `group` | 6 | yes |
| `parse` | 4 | yes |
| `parse_manifest` | 4 | yes |
| `range_of_loc` | 2 | yes |
| `render_line` | 2 | yes |
| `snapshot_of` | 9 | yes |
| `sorted` | 3 | yes |
| `summary` | 2 | yes |
| `unique_count` | 4 | yes |
| `verify` | 2 | yes |

Total white-box tests: 51 (wasm-gc; the same count passes on js).

Every public function is named in at least one test.
