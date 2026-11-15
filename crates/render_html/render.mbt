///|
/// Replace every occurrence of `needle` with `replacement`.
fn replace_all(
  text : String,
  needle : StringView,
  replacement : String,
) -> String {
  let mut out = ""
  let mut first = true
  for part in text.split(needle) {
    if first {
      first = false
    } else {
      out = out + replacement
    }
    out = out + part.to_owned()
  }
  out
}

///|
/// Escape the characters that would otherwise start markup.
///
/// The ampersand is escaped first, so the entities introduced afterwards stay
/// literal instead of being escaped a second time.
pub fn escape_html(text : String) -> String {
  let amp = replace_all(text, "&", "&amp;")
  let lt = replace_all(amp, "<", "&lt;")
  let gt = replace_all(lt, ">", "&gt;")
  replace_all(gt, "\"", "&quot;")
}

///|
/// Render a diagnostic as a self-contained HTML figure.
///
/// The snippet is the plain-text layout with markup escaped, so a source line
/// holding an angle bracket cannot break the page.
pub fn render_html(
  diag : @diagnostic.Diagnostic,
  source_name : String,
  source : String,
  options : @render_ansi.RenderOptions,
) -> String {
  let severity = @diagnostic.severity_name(diag.severity_rank())
  let mut out = "<figure class='errata errata--" +
    escape_html(severity) +
    "'>\n"
  out = out + "<figcaption class='errata__headline'>"
  out = out +
    "<span class='errata__severity'>" +
    escape_html(severity) +
    "</span>"
  if diag.code_or_empty() != "" {
    out = out +
      "<span class='errata__code'>[" +
      escape_html(diag.code_or_empty()) +
      "]</span>"
  }
  out = out +
    "<span class='errata__message'>" +
    escape_html(diag.headline()) +
    "</span>"
  out = out + "</figcaption>\n"
  let snippet = @render_ansi.render(diag, source_name, source, options)
  out = out +
    "<pre class='errata__snippet'>" +
    escape_html(snippet) +
    "</pre>\n"
  out + "</figure>\n"
}
