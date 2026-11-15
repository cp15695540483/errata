///|
/// Byte range inside one source buffer. `start` is inclusive, `end` exclusive.
pub struct Span {
  start : Int32
  end : Int32
}

///|
pub fn Span::new(start : Int32, end : Int32) -> Span {
  { start, end, }
}

///|
/// Length in bytes; an inverted range reports zero rather than a negative size.
pub fn Span::byte_length(self : Span) -> Int32 {
  if self.end <= self.start {
    0
  } else {
    self.end - self.start
  }
}

///|
/// Whether a byte offset falls inside the half-open range.
pub fn Span::contains(self : Span, offset : Int32) -> Bool {
  offset >= self.start && offset < self.end
}
