///|
fn f(
  source : Int32,
  start : Int32,
  len : Int32,
  replacement : String,
) -> @error-report.Fix {
  {
    source: @error-report.SourceId(source),
    span: @error-report.Span::{ start, len, },
    replacement,
    description: "",
  }
}

///|
fn first_start(fixes : Array[@error-report.Fix]) -> Int32 {
  if fixes.length() == 0 {
    -1
  } else {
    fixes[0].span.start
  }
}

///|
test "sorting puts the smallest start first" {
  let fixes = [f(0, 5, 1, "a"), f(0, 1, 1, "b"), f(0, 3, 1, "c")]
  let out = sorted(fixes)
  assert_eq(first_start(out), 1)
  assert_eq(out[0].replacement, "b")
  assert_eq(out[2].replacement, "a")
}

///|
test "sorting is stable for equal starts" {
  let fixes = [f(0, 2, 5, "a"), f(0, 2, 1, "b")]
  let out = sorted(fixes)
  assert_eq(out[0].replacement, "b")
  assert_eq(out[1].replacement, "a")
}

///|
test "dedup drops an exact repeat" {
  let fixes = [f(0, 1, 1, "x"), f(0, 1, 1, "x")]
  assert_eq(unique_count(fixes), 1)
}

///|
test "dedup keeps a different replacement" {
  let fixes = [f(0, 1, 1, "x"), f(0, 1, 1, "y")]
  assert_eq(unique_count(fixes), 2)
}

///|
test "dedup keeps fixes on different sources" {
  let fixes = [f(0, 1, 1, "x"), f(1, 1, 1, "x")]
  assert_eq(unique_count(fixes), 2)
}

///|
test "an empty set is stable" {
  assert_eq(sorted([]).length(), 0)
  assert_eq(dedup([]).length(), 0)
  assert_eq(unique_count([]), 0)
}

///|
test "group splits by source and keeps order" {
  let fixes = [f(0, 0, 1, "a"), f(1, 0, 1, "b"), f(0, 2, 1, "c")]
  let groups = group(fixes)
  assert_eq(groups.length(), 2)
  assert_eq(groups[0].fixes.length(), 2)
  assert_eq(groups[1].fixes.length(), 1)
}

///|
test "summary counts deduplicated fixes" {
  let fixes = [f(0, 0, 1, "a"), f(0, 0, 1, "a"), f(1, 0, 1, "b")]
  let s = summary(fixes)
  assert_eq(s.files, 2)
  assert_eq(s.fixes, 2)
}
