///|
/// Options that affect the plain-text rendering.
pub struct RenderOptions {
  tab_width : Int32
}

///|
/// Build options; a tab width below one is treated as one.
pub fn RenderOptions::new(tab_width : Int32) -> RenderOptions {
  let mut tab = tab_width
  if tab < 1 {
    tab = 1
  }
  { tab_width: tab, }
}

///|
fn spaces(n : Int32) -> String {
  let mut out = ""
  for i = 0; i < n; i = i + 1 {
    out = out + " "
  }
  out
}

///|
fn carets(n : Int32) -> String {
  let mut out = ""
  for i = 0; i < n; i = i + 1 {
    out = out + "^"
  }
  out
}

///|
fn digit_count(n : Int32) -> Int32 {
  let mut d = 1
  let mut v = n
  while v >= 10 {
    v = v / 10
    d = d + 1
  }
  d
}

///|
fn split_lines(text : String) -> Array[String] {
  let out : Array[String] = []
  for part in text.split("\n") {
    out.push(part.to_owned())
  }
  out
}

///|
fn line_at(lines : Array[String], line : Int32) -> String {
  if line < 1 || line > lines.length() {
    ""
  } else {
    lines[line - 1]
  }
}

///|
fn header_line(diag : @diagnostic.Diagnostic) -> String {
  let name = @diagnostic.severity_name(diag.severity_rank())
  let code = diag.code_or_empty()
  if code == "" {
    name + ": " + diag.headline() + "\n"
  } else {
    name + "[" + code + "]: " + diag.headline() + "\n"
  }
}

///|
fn label_block(
  index : @span.LineIndex,
  lines : Array[String],
  source_name : String,
  label : @diagnostic.Label,
  tab_width : Int32,
) -> String {
  let span = label.span_view()
  let start = span.start_offset()
  let end = span.end_offset()
  match index.locate(start) {
    None =>
      spaces(2) +
      "╭─[ " +
      source_name +
      " ]\n" +
      spaces(2) +
      "╰─ label offset is outside the source\n"
    Some(loc) => {
      let line_no = loc.line_number()
      let line_text = line_at(lines, line_no)
      let line_len = @span.LineIndex::from_string(line_text).byte_length()
      let line_start = match index.line_start(line_no) {
        Some(b) => b
        None => 0
      }
      let mut rel_start = start - line_start
      if rel_start < 0 {
        rel_start = 0
      }
      if rel_start > line_len {
        rel_start = line_len
      }
      let mut rel_end = end - line_start
      if rel_end > line_len {
        rel_end = line_len
      }
      if rel_end < rel_start + 1 {
        rel_end = rel_start + 1
      }
      if rel_end > line_len {
        rel_end = line_len
      }
      let display_start = @width.prefix_width(line_text, rel_start, tab_width)
      let display_end = @width.prefix_width(line_text, rel_end, tab_width)
      let mut span_width = display_end - display_start
      if span_width < 1 {
        span_width = 1
      }
      let gutter_w = digit_count(line_no)
      let number = line_no.to_string()
      let expanded = @width.expand_tabs(line_text, tab_width)
      spaces(gutter_w + 1) +
      "╭─[ " +
      source_name +
      ":" +
      number +
      ":" +
      loc.column_number().to_string() +
      " ]\n" +
      number +
      " │ " +
      expanded +
      "\n" +
      spaces(gutter_w + 1) +
      "│ " +
      spaces(display_start) +
      carets(span_width) +
      " " +
      label.message_text() +
      "\n"
    }
  }
}

///|
/// Render a diagnostic against its source text.
///
/// The result is plain text with no escape sequences: colour belongs to a
/// separate backend, so this function stays deterministic and easy to assert on.
pub fn render(
  diag : @diagnostic.Diagnostic,
  source_name : String,
  source : String,
  options : RenderOptions,
) -> String {
  let index = @span.LineIndex::from_string(source)
  let lines = split_lines(source)
  let mut out = header_line(diag)
  for i = 0; i < diag.label_count(); i = i + 1 {
    match diag.label_at(i) {
      Some(label) =>
        out = out +
          label_block(index, lines, source_name, label, options.tab_width)
      None => ()
    }
  }
  for i = 0; i < diag.note_count(); i = i + 1 {
    match diag.note_at(i) {
      Some(note) => out = out + "  = note: " + note + "\n"
      None => ()
    }
  }
  out
}
