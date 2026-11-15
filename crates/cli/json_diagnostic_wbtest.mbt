///|
fn quote() -> String {
  "\""
}

///|
fn nl() -> String {
  "\n"
}

///|
/// One `"key":"value"` member of a flat JSON object.
fn entry(key : String, value : String) -> String {
  quote() + key + quote() + ":" + quote() + value + quote()
}

///|
/// One `"key":number` member of a flat JSON object.
fn num(key : String, value : String) -> String {
  quote() + key + quote() + ":" + value
}

///|
fn obj2(a : String, b : String) -> String {
  "{" + a + "," + b + "}"
}

///|
fn obj4(a : String, b : String, c : String, d : String) -> String {
  "{" + a + "," + b + "," + c + "," + d + "}"
}

///|
fn span_start(span : @diagnostic.Span?) -> Int32 {
  match span {
    Some(v) => v.start_offset()
    None => -100
  }
}

///|
fn span_end(span : @diagnostic.Span?) -> Int32 {
  match span {
    Some(v) => v.end_offset()
    None => -100
  }
}

///|
fn out_of(text : String?) -> String {
  match text {
    Some(v) => v
    None => "<none>"
  }
}

///|
test "field reads a string value" {
  let json = obj2(entry("level", "error"), entry("message", "hello"))
  assert_eq(field(json, "message"), Some("hello"))
}

///|
test "field decodes an escape" {
  let json = obj2(entry("level", "error"), entry("message", "a\\nb"))
  assert_eq(field(json, "message"), Some("a" + nl() + "b"))
}

///|
test "field reads a number in decimal form" {
  let json = obj2(entry("level", "error"), num("error_code", "4014"))
  assert_eq(field(json, "error_code"), Some("4014"))
}

///|
test "a missing field is none" {
  assert_eq(field("{}", "message"), None)
  assert_eq(
    field(obj2(entry("level", "error"), entry("path", "x")), "message"),
    None,
  )
}

///|
test "display path keeps only the file name" {
  assert_eq(display_path("E:\\proj\\bad.mbt"), "bad.mbt")
  assert_eq(display_path("src/lib.mbt"), "lib.mbt")
  assert_eq(display_path("bad.mbt"), "bad.mbt")
}

///|
test "loc maps to a byte span" {
  assert_eq(span_start(span_from_loc("let y = x + 1", "1:9-1:10")), 8)
  assert_eq(span_end(span_from_loc("let y = x + 1", "1:9-1:10")), 9)
  assert_eq(span_start(span_from_loc("ab" + nl() + "cd", "2:1-2:3")), 3)
  assert_eq(span_end(span_from_loc("ab" + nl() + "cd", "2:1-2:3")), 5)
  assert_eq(span_start(span_from_loc("abc", "1:2")), 1)
  assert_eq(span_end(span_from_loc("abc", "1:2")), 2)
  assert_eq(span_start(span_from_loc("abc", "9:1-9:2")), -100)
}

///|
test "render_json produces the snippet" {
  let json = obj4(
    entry("level", "error"),
    entry("path", "bad.mbt"),
    entry("loc", "1:9-1:10"),
    entry("message", "Expr Type Mismatch"),
  )
  let out = out_of(
    render_json(json, "let y = x + 1", @render_ansi.RenderOptions::new(4)),
  )
  assert_eq(out.has_prefix("error: Expr Type Mismatch"), true)
  assert_eq(out.contains("bad.mbt:1:9"), true)
  assert_eq(out.contains("^ Expr Type Mismatch"), true)
  assert_eq(out.has_suffix("^ Expr Type Mismatch" + nl()), true)
}

///|
test "render_json shows the error code" {
  let json = obj4(
    entry("level", "error"),
    num("error_code", "4014"),
    entry("loc", "1:1-1:2"),
    entry("message", "boom"),
  )
  let out = out_of(render_json(json, "abc", @render_ansi.RenderOptions::new(4)))
  assert_eq(out.has_prefix("error[4014]: boom"), true)
  assert_eq(out.contains("^ boom"), true)
}

///|
test "render_json rejects a line without a message" {
  let json = obj2(entry("level", "error"), entry("path", "x"))
  assert_eq(render_json(json, "abc", @render_ansi.RenderOptions::new(4)), None)
}
