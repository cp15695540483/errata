///|
fn afix(
  start : Int32,
  len : Int32,
  replacement : String,
  expected : String?,
) -> AddressedFix {
  { fix: fix(start, len, replacement), expected, }
}

///|
test "an anchor that still matches is accepted" {
  let fixes = [afix(1, 1, "X", Some("b"))]
  assert_eq(text_of(apply_addressed("abc", fixes)), "aXc")
}

///|
test "a same-length edit that changed the anchored text is refused" {
  let fixes = [afix(1, 1, "X", Some("b"))]
  // The text is now "adc": same length, but the character at 1 is no longer b.
  assert_eq(text_of(apply_addressed("adc", fixes)), "REFUSED:stale(0)")
}

///|
test "a fix without an anchor keeps positional behaviour" {
  let fixes = [afix(1, 1, "X", None)]
  assert_eq(text_of(apply_addressed("abc", fixes)), "aXc")
  // Same length, changed text, no anchor: still applies by position.
  assert_eq(text_of(apply_addressed("adc", fixes)), "aXc")
}

///|
test "an empty insertion with an anchor refuses when the anchor moved" {
  let fixes = [afix(1, 0, "XY", Some("b"))]
  assert_eq(text_of(apply_addressed("abc", fixes)), "aXYbc")
}

///|
test "an anchored insertion refuses on re-run instead of inserting twice" {
  let fixes = [afix(1, 0, "XY", Some("b"))]
  let first = text_of(apply_addressed("abc", fixes))
  assert_eq(first, "aXYbc")
  let second = text_of(apply_addressed(first, fixes))
  assert_eq(second, "REFUSED:stale(0)")
}
