///|
test "ascii text is one column per code point" {
  assert_eq(text_width(""), 0)
  assert_eq(text_width("abc"), 3)
  assert_eq(text_width("hello, world"), 12)
}

///|
test "code point widths follow the tables" {
  assert_eq(codepoint_width(0x41), 1)
  assert_eq(codepoint_width(0x4E2D), 2)
  assert_eq(codepoint_width(0x3042), 2)
  assert_eq(codepoint_width(0xFF21), 2)
  assert_eq(codepoint_width(0x1F600), 2)
  assert_eq(codepoint_width(0x0301), 0)
  assert_eq(codepoint_width(0x200B), 0)
  assert_eq(codepoint_width(0x09), 0)
  assert_eq(codepoint_width(0x1B), 0)
  assert_eq(codepoint_width(0x7F), 0)
}

///|
test "a tab jumps to the next stop" {
  assert_eq(column_after(@utf8.encode("a\tb"), 0, 0, 4), 5)
  assert_eq(column_after(@utf8.encode("\t"), 0, 0, 8), 8)
  assert_eq(column_after(@utf8.encode("abcd\tz"), 0, 0, 4), 9)
  assert_eq(column_after(@utf8.encode("\t"), 0, 0, 0), 1)
}

///|
test "a line break resets the column" {
  assert_eq(column_after(@utf8.encode("ab\ncd"), 0, 0, 4), 2)
  assert_eq(column_after(@utf8.encode("ab\r\nc"), 0, 0, 4), 1)
}

///|
test "column_after can start in the middle of a buffer" {
  let bytes = @utf8.encode("abc")
  assert_eq(column_after(bytes, 2, 6, 4), 7)
  assert_eq(column_after(bytes, 3, 6, 4), 6)
}

///|
test "utf8 decoding reports code point and byte length" {
  let (cp1, l1) = decode_utf8(@utf8.encode("A"), 0)
  assert_eq(cp1, 65)
  assert_eq(l1, 1)
  let (cp2, l2) = decode_utf8(@utf8.encode("é"), 0)
  assert_eq(cp2, 0xE9)
  assert_eq(l2, 2)
  let (cp3, l3) = decode_utf8(@utf8.encode("中"), 0)
  assert_eq(cp3, 0x4E2D)
  assert_eq(l3, 3)
  let (cp4, l4) = decode_utf8(@utf8.encode("😀"), 0)
  assert_eq(cp4, 0x1F600)
  assert_eq(l4, 4)
}

///|
test "multi-byte text advances by display width" {
  assert_eq(text_width("é"), 1)
  assert_eq(text_width("中"), 2)
  assert_eq(text_width("中a"), 3)
  assert_eq(text_width("あ"), 2)
  assert_eq(text_width("😀😀"), 4)
  assert_eq(text_width("a中b"), 4)
}

///|
test "an index outside the buffer has no byte length" {
  let bytes = @utf8.encode("a")
  let (cp5, len5) = decode_utf8(bytes, 5)
  assert_eq(len5, 0)
  assert_eq(cp5, 0xFFFD)
  let (cp6, len6) = decode_utf8(bytes, -1)
  assert_eq(len6, 0)
  assert_eq(cp6, 0xFFFD)
}
