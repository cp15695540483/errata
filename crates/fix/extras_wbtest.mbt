///|
test "identical text has no diff" {
  assert_eq(diff("a\nb", "a\nb"), "")
}

///|
test "a changed line shows as minus and plus" {
  let d = diff("a\nb\nc", "a\nB\nc")
  assert_eq(d.contains("-b"), true)
  assert_eq(d.contains("+B"), true)
}

///|
test "an inserted line shows as plus" {
  let d = diff("a\nb", "a\nx\nb")
  assert_eq(d.contains("+x"), true)
}

///|
test "a deleted line shows as minus" {
  let d = diff("a\nx\nb", "a\nb")
  assert_eq(d.contains("-x"), true)
}

///|
test "a manifest groups fixes by path" {
  let text = "a.mbt\t0\t1\tX\na.mbt\t2\t1\tY"
  let plans = parse_manifest(text)
  assert_eq(plans.length(), 1)
  assert_eq(plans[0].path, "a.mbt")
  assert_eq(plans[0].fixes.length(), 2)
}

///|
test "comments and blank lines are skipped" {
  let text = "# note\n\na.mbt\t1\t1\tz"
  let plans = parse_manifest(text)
  assert_eq(plans.length(), 1)
  assert_eq(plans[0].fixes.length(), 1)
}

///|
test "a malformed line is skipped" {
  let text = "a.mbt\tx\t1\tq"
  assert_eq(parse_manifest(text).length(), 0)
}

///|
test "manifest fixes apply to the text" {
  let text = "a.mbt\t0\t1\tA"
  let plans = parse_manifest(text)
  let out = match apply("abc", plans[0].fixes) {
    Applied(s) => s
    Refused(_) => "refused"
  }
  assert_eq(out, "Abc")
}
