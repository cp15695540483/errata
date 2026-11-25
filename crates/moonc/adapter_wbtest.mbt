///|
test "field reads a number" {
  let line = "{\"level\":\"error\",\"error_code\":4014,\"loc\":\"1:1\",\"message\":\"m\"}"
  assert_eq(field(line, "error_code"), Some("4014"))
}

///|
test "field reads a string" {
  let line = "{\"level\":\"error\",\"message\":\"boom\"}"
  assert_eq(field(line, "level"), Some("error"))
  assert_eq(field(line, "message"), Some("boom"))
}

///|
test "render_line keeps the code" {
  let line = "{\"level\":\"error\",\"error_code\":4014,\"loc\":\"1:1-1:2\",\"message\":\"boom\"}"
  let out = match render_line(line, "t.mbt", "abc", false) {
    Some(s) => s
    None => "NONE"
  }
  assert_eq(out.contains("4014"), true)
}

///|
test "range_of_loc maps a single-line location" {
  match range_of_loc("let y = x + 1", "1:9-1:10") {
    Some(r) => assert_eq(r.0, 8)
    None => assert_eq("none", "some")
  }
}
