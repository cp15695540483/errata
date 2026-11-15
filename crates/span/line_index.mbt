///|
/// A 1-based position inside a UTF-8 source buffer.
///
/// `column` counts bytes from the start of the line, so a tab is one column
/// until display-width handling lands in `crates/width`.
pub struct Location {
  line : Int32
  column : Int32
}

///|
/// Line table for a UTF-8 byte buffer.
///
/// A line break is LF (0x0A). In a CRLF pair the CR stays on the line it
/// terminates, so CRLF and LF text agree on the line numbering of everything
/// after the break.
pub struct LineIndex {
  starts : Array[Int32]
  size : Int32
}

///|
/// Build the line table for a raw UTF-8 buffer.
pub fn LineIndex::from_bytes(bytes : Bytes) -> LineIndex {
  let starts : Array[Int32] = [0]
  let size = bytes.length()
  for i = 0; i < size; i = i + 1 {
    if bytes[i].to_int() == 10 {
      starts.push(i + 1)
    }
  }
  { starts, size, }
}

///|
/// Build the line table for a `String` by encoding it as UTF-8 first.
pub fn LineIndex::from_string(text : String) -> LineIndex {
  LineIndex::from_bytes(@utf8.encode(text))
}

///|
/// Number of lines. An empty buffer still has one empty line.
pub fn LineIndex::line_count(self : LineIndex) -> Int32 {
  self.starts.length()
}

///|
/// Size of the indexed buffer in bytes.
pub fn LineIndex::byte_length(self : LineIndex) -> Int32 {
  self.size
}

///|
/// Byte offset where `line` (1-based) starts.
pub fn LineIndex::line_start(self : LineIndex, line : Int32) -> Int32? {
  if line < 1 || line > self.starts.length() {
    return None
  }
  Some(self.starts[line - 1])
}

///|
/// Map a byte offset to its `(line, column)`.
///
/// Offsets `0 ..= byte_length()` are valid; anything outside returns `None`.
pub fn LineIndex::locate(self : LineIndex, offset : Int32) -> Location? {
  if offset < 0 || offset > self.size {
    return None
  }
  let mut lo = 0
  let mut hi = self.starts.length() - 1
  while lo < hi {
    let mid = (lo + hi + 1) / 2
    if self.starts[mid] <= offset {
      lo = mid
    } else {
      hi = mid - 1
    }
  }
  Some(Location::{ line: lo + 1, column: offset - self.starts[lo] + 1, })
}
