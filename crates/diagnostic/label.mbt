///|
/// One annotation attached to a span.
///
/// A diagnostic may carry several labels; the focused one drives the caret
/// line, the context ones only decorate the snippet.
pub struct Label {
  span : Span
  message : String
  focused : Bool
}

///|
pub fn Label::focused(span : Span, message : String) -> Label {
  { span, message, focused: true, }
}

///|
pub fn Label::context(span : Span, message : String) -> Label {
  { span, message, focused: false, }
}

///|
pub fn Label::span_view(self : Label) -> Span {
  self.span
}

///|
pub fn Label::message_text(self : Label) -> String {
  self.message
}

///|
pub fn Label::is_focused(self : Label) -> Bool {
  self.focused
}
