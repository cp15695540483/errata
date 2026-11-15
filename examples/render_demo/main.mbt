///|
/// Print one rendered diagnostic, so the library has an output a reader can
/// look at without writing any code.
fn main {
  let source = "let y = x + 1"
  let message = "unknown type"
  let report = @diagnostic.Diagnostic::error(message).with_label(
    @diagnostic.Label::focused(@diagnostic.Span::new(8, 9), message),
  )
  let text = @render_ansi.render(
    report,
    "demo.mbt",
    source,
    @render_ansi.RenderOptions::new(4),
  )
  println(text)
}
