///|
/// Severity ranks. Plain integers keep the value usable from any crate
/// without exposing constructors.
pub fn severity_error() -> Int32 {
  0
}

///|
pub fn severity_warning() -> Int32 {
  1
}

///|
pub fn severity_note() -> Int32 {
  2
}

///|
pub fn severity_help() -> Int32 {
  3
}

///|
/// Lowercase name every renderer prints. Unknown ranks fall back to error.
pub fn severity_name(severity : Int32) -> String {
  if severity == severity_warning() {
    "warning"
  } else if severity == severity_note() {
    "note"
  } else if severity == severity_help() {
    "help"
  } else {
    "error"
  }
}

///|
/// A diagnostic ready for a renderer: severity, optional code, headline,
/// labelled spans and footnotes.
///
/// Values are immutable. Every builder copies the array it extends, so a
/// derived diagnostic never mutates the value it came from.
pub struct Diagnostic {
  severity : Int32
  code : String
  message : String
  labels : Array[Label]
  notes : Array[String]
}

///|
fn empty_labels() -> Array[Label] {
  []
}

///|
fn empty_notes() -> Array[String] {
  []
}

///|
fn copy_labels(labels : Array[Label]) -> Array[Label] {
  let out : Array[Label] = []
  for i = 0; i < labels.length(); i = i + 1 {
    out.push(labels[i])
  }
  out
}

///|
fn copy_notes(notes : Array[String]) -> Array[String] {
  let out : Array[String] = []
  for i = 0; i < notes.length(); i = i + 1 {
    out.push(notes[i])
  }
  out
}

///|
fn make(severity : Int32, message : String) -> Diagnostic {
  { severity, code: "", message, labels: empty_labels(), notes: empty_notes(), }
}

///|
pub fn Diagnostic::error(message : String) -> Diagnostic {
  make(severity_error(), message)
}

///|
pub fn Diagnostic::warning(message : String) -> Diagnostic {
  make(severity_warning(), message)
}

///|
pub fn Diagnostic::note(message : String) -> Diagnostic {
  make(severity_note(), message)
}

///|
pub fn Diagnostic::help(message : String) -> Diagnostic {
  make(severity_help(), message)
}

///|
pub fn Diagnostic::with_code(self : Diagnostic, code : String) -> Diagnostic {
  {
    severity: self.severity,
    code,
    message: self.message,
    labels: self.labels,
    notes: self.notes,
  }
}

///|
pub fn Diagnostic::with_label(self : Diagnostic, label : Label) -> Diagnostic {
  let labels = copy_labels(self.labels)
  labels.push(label)
  {
    severity: self.severity,
    code: self.code,
    message: self.message,
    labels,
    notes: self.notes,
  }
}

///|
pub fn Diagnostic::with_note(self : Diagnostic, note : String) -> Diagnostic {
  let notes = copy_notes(self.notes)
  notes.push(note)
  {
    severity: self.severity,
    code: self.code,
    message: self.message,
    labels: self.labels,
    notes,
  }
}

///|
pub fn Diagnostic::severity_rank(self : Diagnostic) -> Int32 {
  self.severity
}

///|
pub fn Diagnostic::code_or_empty(self : Diagnostic) -> String {
  self.code
}

///|
pub fn Diagnostic::headline(self : Diagnostic) -> String {
  self.message
}

///|
pub fn Diagnostic::label_count(self : Diagnostic) -> Int32 {
  self.labels.length()
}

///|
pub fn Diagnostic::note_count(self : Diagnostic) -> Int32 {
  self.notes.length()
}

///|
pub fn Diagnostic::label_at(self : Diagnostic, index : Int32) -> Label? {
  if index < 0 || index >= self.labels.length() {
    return None
  }
  Some(self.labels[index])
}

///|
pub fn Diagnostic::note_at(self : Diagnostic, index : Int32) -> String? {
  if index < 0 || index >= self.notes.length() {
    return None
  }
  Some(self.notes[index])
}

///|
/// First focused label, if the diagnostic carries one.
pub fn Diagnostic::primary_label(self : Diagnostic) -> Label? {
  let mut index = 0
  let mut found : Label? = None
  while index < self.labels.length() {
    let label = self.labels[index]
    if label.is_focused() {
      found = Some(label)
      index = self.labels.length()
    } else {
      index = index + 1
    }
  }
  found
}
