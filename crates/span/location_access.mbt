///|
/// Byte offset where the range starts (inclusive).
pub fn Location::line_number(self : Location) -> Int32 {
  self.line
}

///|
/// 1-based column of the location.
pub fn Location::column_number(self : Location) -> Int32 {
  self.column
}
