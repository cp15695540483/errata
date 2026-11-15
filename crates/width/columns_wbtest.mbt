///|
test "prefix width counts display columns up to an offset" {
  assert_eq(prefix_width("abc", 0, 4), 0)
  assert_eq(prefix_width("abc", 2, 4), 2)
  assert_eq(prefix_width("abc", 99, 4), 3)
  assert_eq(prefix_width("中a", 3, 4), 2)
  assert_eq(prefix_width("中a", 4, 4), 3)
}

///|
test "tabs count from the last stop" {
  assert_eq(prefix_width("a\tb", 2, 4), 4)
  assert_eq(prefix_width("a\tb", 3, 4), 5)
  assert_eq(prefix_width("\t", 1, 8), 8)
}

///|
test "expand tabs replaces each stop with spaces" {
  assert_eq(expand_tabs("a\tb", 4), "a   b")
  assert_eq(expand_tabs("abcd\tz", 4), "abcd    z")
  assert_eq(expand_tabs("no tabs", 4), "no tabs")
  assert_eq(expand_tabs("\t", 0), " ")
}
