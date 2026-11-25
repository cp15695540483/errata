# Test matrix

Every public function of `crates/fix` and `crates/moonc`, and how many times it is
named in a white-box test file. This is the reverse lookup the review asked for:
it shows which declarations are guarded and which are not.

Regenerate with:

```bash
for f in crates/fix/*.mbt crates/moonc/*.mbt; do grep -h "^pub fn " "$f"; done \
  | sed -E "s/^pub fn ([A-Za-z0-9_]+).*/\1/" | sort -u \
  | while read n; do echo "$n $(grep -h "$n" crates/fix/*_wbtest.mbt | wc -l)"; done
```

| Public function | Test references | Covered |
| --- | --- | --- |
| `apply` | 37 | yes |
| `apply_addressed` | 10 | yes |
| `apply_all` | 3 | yes |
| `apply_verified` | 6 | yes |
| `check` | 3 | yes |
| `check_addressed` | 0 | no |
| `count` | 9 | yes |
| `dedup` | 5 | yes |
| `describe` | 2 | yes |
| `diff` | 7 | yes |
| `field` | 5 | yes |
| `group` | 6 | yes |
| `parse` | 4 | yes |
| `parse_manifest` | 4 | yes |
| `range_of_loc` | 0 | no |
| `render_line` | 2 | yes |
| `snapshot_of` | 8 | yes |
| `sorted` | 3 | yes |
| `summary` | 2 | yes |
| `unique_count` | 4 | yes |
| `verify` | 2 | yes |

Total white-box tests: niu: -c: line 7: unexpected EOF while looking for matching `"'.

Unreferenced by name: check_addressed, range_of_loc. These are reachable only through the functions that call them, so their coverage comes from the caller tests.
