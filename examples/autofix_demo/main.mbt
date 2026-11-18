///|
fn fix_at(
  start : Int32,
  len : Int32,
  replacement : String,
) -> @error-report.Fix {
  {
    source: @error-report.SourceId(0),
    span: @error-report.Span::{ start, len, },
    replacement,
    description: "",
  }
}

///|
/// Demonstrate the two outcomes of the application layer: an applied fix and a
/// refused set, printed with no further processing.
fn main {
  let source = "let y = x + 1"
  let ok = @fix.apply(source, [fix_at(8, 1, "y")])
  match ok {
    Applied(text) => println("applied: " + text)
    Refused(reason) => println("refused: " + @fix.describe(reason))
  }
  let bad = @fix.apply("abc", [fix_at(0, 2, "A"), fix_at(1, 2, "B")])
  match bad {
    Applied(text) => println("applied: " + text)
    Refused(reason) => println("refused: " + @fix.describe(reason))
  }
}
