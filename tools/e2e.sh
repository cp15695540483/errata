#!/usr/bin/env bash
# Smoke test for cmd/errata: the CLI layer the unit tests cannot reach.
# Runs from the repository root; exits non-zero if any assertion fails.
set -u
cd "$(dirname "$0")/.." || exit 1

TMP="_build/e2e"
rm -rf "$TMP"
mkdir -p "$TMP"

pass=0
fail=0

check() {
  name="$1"
  want="$2"
  got="$3"
  if printf "%s" "$got" | grep -qF -- "$want"; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf "FAIL %s\n  want: %s\n  got:  %s\n" "$name" "$want" "$got"
  fi
}

assert_file() {
  name="$1"
  want="$2"
  file="$3"
  got=$(cat "$file" 2>/dev/null || true)
  if [ "$got" = "$want" ]; then
    pass=$((pass + 1))
  else
    fail=$((fail + 1))
    printf "FAIL %s\n  want: %s\n  got:  %s\n" "$name" "$want" "$got"
  fi
}

# 1. render prints a header and a caret
out=$(moon run cmd/errata -- render '{"level":"error","error_code":4014,"loc":"1:9-1:10","message":"Expr Type Mismatch"}' 'let y = x + 1' 2>&1)
check "render header" "error[4014]: Expr Type Mismatch" "$out"
check "render caret" "╰─ Expr Type Mismatch" "$out"

# 2. dry-run prints a diff and does not write
printf "let y = x + 1\n" > "$TMP/demo.mbt"
printf "%s\t8\t1\ty\n" "$TMP/demo.mbt" > "$TMP/fix.tsv"
out=$(moon run cmd/errata -- fix "$TMP/fix.tsv" 2>&1)
check "dry-run minus" "-let y = x + 1" "$out"
check "dry-run plus" "+let y = y + 1" "$out"
assert_file "dry-run leaves the file alone" "let y = x + 1" "$TMP/demo.mbt"

# 3. --write applies and reports the count
out=$(moon run cmd/errata -- fix "$TMP/fix.tsv" --write 2>&1)
check "write reports applied" "1 applied, 0 refused" "$out"
assert_file "write changes the file" "let y = y + 1" "$TMP/demo.mbt"

# 4. a second run is a no-op
out=$(moon run cmd/errata -- fix "$TMP/fix.tsv" --write 2>&1)
check "second run unchanged" "unchanged" "$out"
assert_file "second run keeps the text" "let y = y + 1" "$TMP/demo.mbt"

# 5. an empty manifest reports no fixes
: > "$TMP/empty.tsv"
out=$(moon run cmd/errata -- fix "$TMP/empty.tsv" 2>&1)
check "empty manifest" "no fixes" "$out"

# 6. a missing manifest is reported, not crashed on
out=$(moon run cmd/errata -- fix "$TMP/nope.tsv" 2>&1)
check "missing manifest" "cannot read" "$out"

# 7. a negative range is refused and the file is untouched
printf "abc\n" > "$TMP/t.mbt"
printf "%s\t-1\t1\tX\n" "$TMP/t.mbt" > "$TMP/neg.tsv"
out=$(moon run cmd/errata -- fix "$TMP/neg.tsv" --write 2>&1)
check "negative range refused" "outside the file" "$out"
assert_file "refused set leaves the file alone" "abc" "$TMP/t.mbt"

# 8. no arguments prints usage
out=$(moon run cmd/errata 2>&1)
check "usage" "usage: errata" "$out"

rm -rf "$TMP"
printf "\n%d passed, %d failed\n" "$pass" "$fail"
[ "$fail" -eq 0 ]

