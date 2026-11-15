///|
fn label_message(d : Diagnostic, index : Int32) -> String? {
  match d.label_at(index) {
    Some(label) => Some(label.message_text())
    None => None
  }
}

///|
fn focused_message(d : Diagnostic) -> String? {
  match d.primary_label() {
    Some(label) => Some(label.message_text())
    None => None
  }
}

///|
test "span length and containment" {
  let span = Span::new(3, 9)
  assert_eq(span.byte_length(), 6)
  assert_eq(span.contains(3), true)
  assert_eq(span.contains(8), true)
  assert_eq(span.contains(9), false)
  assert_eq(Span::new(9, 3).byte_length(), 0)
}

///|
test "error diagnostic keeps severity and headline" {
  let d = Diagnostic::error("unknown type")
  assert_eq(d.severity_rank(), severity_error())
  assert_eq(d.headline(), "unknown type")
  assert_eq(d.code_or_empty(), "")
  assert_eq(d.label_count(), 0)
  assert_eq(d.note_count(), 0)
}

///|
test "severity names are lowercase" {
  assert_eq(severity_name(severity_error()), "error")
  assert_eq(severity_name(severity_warning()), "warning")
  assert_eq(severity_name(severity_note()), "note")
  assert_eq(severity_name(severity_help()), "help")
  assert_eq(severity_name(99), "error")
}

///|
test "labels keep insertion order" {
  let d0 = Diagnostic::error("two labels")
  let d1 = d0.with_label(Label::context(Span::new(0, 2), "first"))
  let d = d1.with_label(Label::focused(Span::new(4, 6), "second"))
  assert_eq(d.label_count(), 2)
  assert_eq(label_message(d, 0), Some("first"))
  assert_eq(label_message(d, 1), Some("second"))
  assert_eq(label_message(d, 2), None)
}

///|
test "focused label is reported" {
  let d = Diagnostic::warning("w").with_label(
    Label::focused(Span::new(1, 4), "here"),
  )
  assert_eq(focused_message(d), Some("here"))
}

///|
test "diagnostic without a focused label reports none" {
  let d = Diagnostic::note("n").with_label(
    Label::context(Span::new(0, 1), "ctx"),
  )
  assert_eq(focused_message(d), None)
}

///|
test "notes accumulate in order" {
  let d0 = Diagnostic::help("h")
  let d1 = d0.with_note("first note")
  let d = d1.with_note("second note")
  assert_eq(d.note_count(), 2)
  assert_eq(d.note_at(0), Some("first note"))
  assert_eq(d.note_at(1), Some("second note"))
  assert_eq(d.note_at(2), None)
}

///|
test "builders leave the source diagnostic untouched" {
  let base = Diagnostic::error("base")
  let extended = base
    .with_label(Label::focused(Span::new(0, 1), "x"))
    .with_code("E0001")
  assert_eq(base.label_count(), 0)
  assert_eq(base.code_or_empty(), "")
  assert_eq(extended.label_count(), 1)
  assert_eq(extended.code_or_empty(), "E0001")
}

///|
test "label exposes its span and role" {
  let focused = Label::focused(Span::new(5, 8), "m")
  let context = Label::context(Span::new(1, 2), "c")
  assert_eq(focused.span_view().byte_length(), 3)
  assert_eq(focused.is_focused(), true)
  assert_eq(context.is_focused(), false)
}
