///|
/// A refusal in words, for a terminal reader.
pub fn describe(r : Refusal) -> String {
  match r {
    OutOfRange(a, b) => "range at " + a.to_string() + " with length " + b.to_string() + " is outside the file"
    Overlap(a, b) => "fixes " + a.to_string() + " and " + b.to_string() + " overlap"
    NotBoundary(i) => "fix " + i.to_string() + " starts or ends inside a character"
  }
}

