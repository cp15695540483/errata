///|
fn afix(
  start : Int32,
  len : Int32,
  replacement : String,
  expected : String?,
) -> AddressedFix {
  { fix: fix(start, len, replacement), expected, snapshot: None, }
}

///|
fn sfix(
  start : Int32,
  len : Int32,
  replacement : String,
  expected : String?,
  snapshot : String,
) -> AddressedFix {
  { fix: fix(start, len, replacement), expected, snapshot: Some(snapshot), }
}

///|
test "an anchor that still matches is accepted" {
  let fixes = [afix(1, 1, "X", Some("b"))]
  assert_eq(text_of(apply_addressed("abc", fixes)), "aXc")
}

///|
test "a same-length edit that changed the anchored text is refused" {
  let fixes = [afix(1, 1, "X", Some("b"))]
  assert_eq(text_of(apply_addressed("adc", fixes)), "REFUSED:stale(0)")
}

///|
test "a fresh snapshot is accepted" {
  let fixes = [sfix(8, 1, "y", None, snapshot_of("let y = x + 1"))]
  assert_eq(text_of(apply_addressed("let y = x + 1", fixes)), "let y = y + 1")
}

///|
test "a stale snapshot is refused" {
  let fixes = [sfix(8, 1, "y", None, snapshot_of("let y = x + 1"))]
  assert_eq(
    text_of(apply_addressed("let y = z + 1", fixes)),
    "REFUSED:stale(0)",
  )
}

///|
test "an insertion whose text equals the anchor is not repeated" {
  // The anchor is "b" and the inserted text is also "b": after the first run
  // the character at the insertion point is the inserted "b", so a range
  // anchor would match again. The snapshot does not.
  let snap = snapshot_of("abc")
  let fixes = [sfix(1, 0, "b", Some("b"), snap)]
  let first = text_of(apply_addressed("abc", fixes))
  assert_eq(first, "abbc")
  let second = text_of(apply_addressed(first, fixes))
  assert_eq(second, "REFUSED:stale(0)")
}

///|
test "a plain anchor alone would repeat that insertion" {
  // This documents the boundary: without a snapshot the anchor is not enough.
  let fixes = [afix(1, 0, "b", Some("b"))]
  let first = text_of(apply_addressed("abc", fixes))
  let second = text_of(apply_addressed(first, fixes))
  assert_eq(first, "abbc")
  assert_eq(second, "abbbc")
}

///|
test "an anchored insertion refuses on re-run with a snapshot" {
  let snap = snapshot_of("abc")
  let fixes = [sfix(1, 0, "XY", Some("b"), snap)]
  let first = text_of(apply_addressed("abc", fixes))
  assert_eq(first, "aXYbc")
  let second = text_of(apply_addressed(first, fixes))
  assert_eq(second, "REFUSED:stale(0)")
}

///|
test "snapshot_of is stable and distinct for different texts" {
  assert_eq(snapshot_of("abc"), snapshot_of("abc"))
  assert_eq(snapshot_of("abc") != snapshot_of("abd"), true)
  assert_eq(snapshot_of("") != snapshot_of("a"), true)
}
