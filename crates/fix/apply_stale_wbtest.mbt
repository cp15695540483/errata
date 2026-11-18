///|
test "apply_verified accepts a set that fits" {
  let fixes = [fix(1, 1, "X")]
  assert_eq(text_of(apply_verified("abc", fixes)), "aXc")
}

///|
test "apply_verified refuses a set that no longer fits" {
  let fixes = [fix(5, 1, "X")]
  assert_eq(text_of(apply_verified("abc", fixes)), "REFUSED:stale(0)")
}

///|
test "apply_verified refuses a set that shrank out from under it" {
  let fixes = [fix(2, 3, "X")]
  assert_eq(text_of(apply_verified("ab", fixes)), "REFUSED:stale(0)")
}
