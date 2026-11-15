///|
/// Byte offset where the range starts (inclusive).
pub fn Span::start_offset(self : Span) -> Int32 {
  self.start
}

///|
/// Byte offset where the range ends (exclusive).
pub fn Span::end_offset(self : Span) -> Int32 {
  self.end
}
