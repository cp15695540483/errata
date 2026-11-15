///|
fn diag_error(
  msg : String,
  start : Int32,
  end : Int32,
) -> @diagnostic.Diagnostic {
  @diagnostic.Diagnostic::error(msg).with_label(
    @diagnostic.Label::focused(@diagnostic.Span::new(start, end), msg),
  )
}

///|
test "header, code line and caret" {
  let d = diag_error("unknown type", 8, 9)
  let expected = "error: unknown type\n" +
    "  ╭─[ demo.mbt:1:9 ]\n" +
    "1 │ let y = x + 1\n" +
    "  │         ^ unknown type\n"
  assert_eq(
    render(d, "demo.mbt", "let y = x + 1", RenderOptions::new(4)),
    expected,
  )
}

///|
test "a code is shown in brackets" {
  let d = diag_error("unknown type", 8, 9).with_code("E0001")
  let expected = "error[E0001]: unknown type\n" +
    "  ╭─[ demo.mbt:1:9 ]\n" +
    "1 │ let y = x + 1\n" +
    "  │         ^ unknown type\n"
  assert_eq(
    render(d, "demo.mbt", "let y = x + 1", RenderOptions::new(4)),
    expected,
  )
}

///|
test "warning severity is named" {
  let d = @diagnostic.Diagnostic::warning("w").with_label(
    @diagnostic.Label::focused(@diagnostic.Span::new(0, 1), "w"),
  )
  let expected = "warning: w\n" +
    "  ╭─[ demo.mbt:1:1 ]\n" +
    "1 │ abc\n" +
    "  │ ^ w\n"
  assert_eq(render(d, "demo.mbt", "abc", RenderOptions::new(4)), expected)
}

///|
test "caret width follows the span length" {
  let d = diag_error("sum", 8, 11)
  let expected = "error: sum\n" +
    "  ╭─[ demo.mbt:1:9 ]\n" +
    "1 │ let y = x + 1\n" +
    "  │         ^^^ sum\n"
  assert_eq(
    render(d, "demo.mbt", "let y = x + 1", RenderOptions::new(4)),
    expected,
  )
}

///|
test "cjk text occupies two columns" {
  let d = diag_error("here", 3, 4)
  let expected = "error: here\n" +
    "  ╭─[ demo.mbt:1:4 ]\n" +
    "1 │ 中a\n" +
    "  │   ^ here\n"
  assert_eq(render(d, "demo.mbt", "中a", RenderOptions::new(4)), expected)
}

///|
test "tab stops line the caret up" {
  let d = diag_error("b", 2, 3)
  let expected = "error: b\n" +
    "  ╭─[ demo.mbt:1:3 ]\n" +
    "1 │ a   b\n" +
    "  │     ^ b\n"
  assert_eq(render(d, "demo.mbt", "a\tb", RenderOptions::new(4)), expected)
}

///|
test "notes follow the labels" {
  let d = diag_error("e", 0, 1).with_note("first").with_note("second")
  let expected = "error: e\n" +
    "  ╭─[ demo.mbt:1:1 ]\n" +
    "1 │ abc\n" +
    "  │ ^ e\n" +
    "  = note: first\n" +
    "  = note: second\n"
  assert_eq(render(d, "demo.mbt", "abc", RenderOptions::new(4)), expected)
}

///|
test "an offset past the source is reported" {
  let d = diag_error("far", 50, 51)
  let expected = "error: far\n" +
    "  ╭─[ demo.mbt ]\n" +
    "  ╰─ label offset is outside the source\n"
  assert_eq(render(d, "demo.mbt", "abc", RenderOptions::new(4)), expected)
}

///|
test "a span crossing a line break clamps to the first line" {
  let d = diag_error("spans", 1, 4)
  let expected = "error: spans\n" +
    "  ╭─[ demo.mbt:1:2 ]\n" +
    "1 │ ab\n" +
    "  │  ^ spans\n"
  assert_eq(render(d, "demo.mbt", "ab\ncd", RenderOptions::new(4)), expected)
}
