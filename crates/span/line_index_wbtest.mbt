///|
fn as_pair(loc : Location?) -> (Int32, Int32)? {
  match loc {
    Some(l) => Some((l.line, l.column))
    None => None
  }
}

///|
test "offset zero is the first cell" {
  let index = LineIndex::from_string("abc")
  assert_eq(as_pair(index.locate(0)), Some((1, 1)))
}

///|
test "columns advance inside a line" {
  let index = LineIndex::from_string("hello")
  assert_eq(as_pair(index.locate(4)), Some((1, 5)))
}

///|
test "a newline starts the next line at column one" {
  let index = LineIndex::from_string("ab\ncd\nef")
  assert_eq(index.line_count(), 3)
  assert_eq(index.line_start(2), Some(3))
  assert_eq(as_pair(index.locate(3)), Some((2, 1)))
  assert_eq(as_pair(index.locate(7)), Some((3, 2)))
}

///|
test "CRLF and LF agree after the break" {
  let lf = LineIndex::from_string("ab\ncd")
  let crlf = LineIndex::from_string("ab\r\ncd")
  assert_eq(lf.line_count(), 2)
  assert_eq(crlf.line_count(), 2)
  assert_eq(as_pair(lf.locate(3)), Some((2, 1)))
  assert_eq(as_pair(crlf.locate(4)), Some((2, 1)))
}

///|
test "the offset past the last byte is valid" {
  let index = LineIndex::from_string("abc\ndef")
  assert_eq(index.byte_length(), 7)
  assert_eq(as_pair(index.locate(7)), Some((2, 4)))
}

///|
test "empty input has one line and one valid offset" {
  let index = LineIndex::from_string("")
  assert_eq(index.line_count(), 1)
  assert_eq(index.byte_length(), 0)
  assert_eq(as_pair(index.locate(0)), Some((1, 1)))
  assert_eq(as_pair(index.locate(1)), None)
}

///|
test "columns count bytes in multi-byte text" {
  let index = LineIndex::from_string("héllo")
  assert_eq(index.byte_length(), 6)
  assert_eq(as_pair(index.locate(3)), Some((1, 4)))
}

///|
test "line_start returns the byte offset of a line" {
  let index = LineIndex::from_string("ab\ncd\nef")
  assert_eq(index.line_start(1), Some(0))
  assert_eq(index.line_start(3), Some(6))
  assert_eq(index.line_start(4), None)
  assert_eq(index.line_start(0), None)
}

///|
test "offsets outside the buffer return None" {
  let index = LineIndex::from_string("abc")
  assert_eq(as_pair(index.locate(-1)), None)
  assert_eq(as_pair(index.locate(4)), None)
}
