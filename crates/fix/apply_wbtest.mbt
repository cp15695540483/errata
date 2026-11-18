fn multibyte() -> String {
  "中"
}

///|
fn has_refusal(r : Refusal?) -> Bool {
  match r {
    Some(_) => true
    None => false
  }
}

///|
fn fix(start : Int, len : Int, replacement : String) -> @error-report.Fix {
  {
    source: @error-report.SourceId(0),
    span: @error-report.Span::{ start: start, len: len },
    replacement: replacement,
    description: "",
  }
}

///|
fn text_of(o : ApplyOutcome) -> String {
  match o {
    Applied(s) => s
    Refused(r) => "REFUSED:" + describe_short(r)
  }
}

///|
fn describe_short(r : Refusal) -> String {
  match r {
    OutOfRange(a, b) => "range(" + a.to_string() + "," + b.to_string() + ")"
    Overlap(a, b) => "overlap(" + a.to_string() + "," + b.to_string() + ")"
    NotBoundary(i) => "boundary(" + i.to_string() + ")"
  }
}

///|
test "no fixes leaves the text alone" {
  assert_eq(text_of(apply("abc", [])), "abc")
}

///|
test "a single replacement" {
  let fixes = [fix(1, 1, "X")]
  assert_eq(text_of(apply("abc", fixes)), "aXc")
}

///|
test "an empty range inserts" {
  let fixes = [fix(1, 0, "XY")]
  assert_eq(text_of(apply("abc", fixes)), "aXYbc")
}

///|
test "several fixes apply in one pass" {
  let fixes = [fix(0, 1, "A"), fix(2, 1, "C")]
  assert_eq(text_of(apply("abc", fixes)), "AbC")
}

///|
test "input order does not matter" {
  let forward = [fix(0, 1, "A"), fix(2, 1, "C")]
  let backward = [fix(2, 1, "C"), fix(0, 1, "A")]
  assert_eq(text_of(apply("abc", forward)), text_of(apply("abc", backward)))
}

///|
test "adjacent ranges are allowed" {
  let fixes = [fix(0, 1, "A"), fix(1, 1, "B")]
  assert_eq(text_of(apply("abc", fixes)), "ABc")
}

///|
test "intersecting ranges are refused" {
  let fixes = [fix(0, 2, "A"), fix(1, 2, "B")]
  assert_eq(text_of(apply("abcd", fixes)), "REFUSED:overlap(0,1)")
}

///|
test "a range past the end is refused" {
  let fixes = [fix(2, 5, "A")]
  assert_eq(text_of(apply("abc", fixes)), "REFUSED:range(2,5)")
}

///|
test "a negative range is refused" {
  let fixes = [fix(-1, 1, "A")]
  assert_eq(text_of(apply("abc", fixes)), "REFUSED:range(-1,1)")
}

///|
test "a range inside a multi-byte character is refused" {
  // The CJK character occupies bytes 0..3, so 1 and 2 are inside it.
  let fixes = [fix(1, 1, "A")]
  let out = text_of(apply(multibyte(), fixes))
  assert_eq(out.has_prefix("REFUSED:boundary"), true)
}

///|
test "a range on character boundaries is accepted" {
  let fixes = [fix(0, 3, "z")]
  assert_eq(text_of(apply(multibyte(), fixes)), "z")
}

///|
test "applying the same fixes twice is refused the second time" {
  let fixes = [fix(0, 3, "z")]
  let first = text_of(apply(multibyte(), fixes))
  let second = text_of(apply(first, fixes))
  assert_eq(first, "z")
  assert_eq(second.has_prefix("REFUSED"), true)
}

///|
test "check reports without applying" {
  let fixes = [fix(0, 2, "A"), fix(1, 2, "B")]
  assert_eq(has_refusal(check("abcd", fixes)), true)
  assert_eq(has_refusal(check("abcd", [fix(0, 1, "A")])), false)
}

///|
test "count reports the set size" {
  assert_eq(count([]), 0)
  assert_eq(count([fix(0, 1, "a"), fix(1, 1, "b")]), 2)
}

