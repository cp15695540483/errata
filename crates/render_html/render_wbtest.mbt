///|
fn sample_diag(
  msg : String,
  start : Int32,
  end : Int32,
) -> @diagnostic.Diagnostic {
  @diagnostic.Diagnostic::error(msg).with_label(
    @diagnostic.Label::focused(@diagnostic.Span::new(start, end), msg),
  )
}

///|
test "escape replaces markup characters" {
  assert_eq(escape_html("<a&b>"), "&lt;a&amp;b&gt;")
  assert_eq(escape_html("\""), "&quot;")
  assert_eq(escape_html("plain"), "plain")
  assert_eq(escape_html(""), "")
}

///|
test "figure carries the severity class and the headline" {
  let d = sample_diag("unknown type", 8, 9)
  let out = render_html(
    d,
    "demo.mbt",
    "let y = x + 1",
    @render_ansi.RenderOptions::new(4),
  )
  assert_eq(out.has_prefix("<figure class='errata errata--error'>"), true)
  assert_eq(out.contains("<figcaption class='errata__headline'>"), true)
  assert_eq(
    out.contains("<span class='errata__message'>unknown type</span>"),
    true,
  )
  assert_eq(out.has_suffix("</figure>\n"), true)
}

///|
test "code is rendered in the caption" {
  let d = sample_diag("unknown type", 8, 9).with_code("E0001")
  let out = render_html(
    d,
    "demo.mbt",
    "let y = x + 1",
    @render_ansi.RenderOptions::new(4),
  )
  assert_eq(out.contains("<span class='errata__code'>[E0001]</span>"), true)
}

///|
test "markup in the source cannot break the page" {
  let d = sample_diag("bad", 0, 1)
  let out = render_html(
    d,
    "demo.mbt",
    "x<y",
    @render_ansi.RenderOptions::new(4),
  )
  assert_eq(out.contains("x&lt;y"), true)
  assert_eq(out.contains("x<y"), false)
}

///|
test "notes stay inside the snippet block" {
  let d = sample_diag("e", 0, 1).with_note("first")
  let out = render_html(
    d,
    "demo.mbt",
    "abc",
    @render_ansi.RenderOptions::new(4),
  )
  assert_eq(out.contains("= note: first"), true)
  assert_eq(out.contains("<pre class='errata__snippet'>"), true)
}
