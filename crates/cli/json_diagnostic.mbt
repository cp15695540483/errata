///|
/// Whether the character is one of the ten ASCII digits.
fn is_digit(c : Char) -> Bool {
  let v = c.to_int()
  v >= 48 && v <= 57
}

///|
/// Character holding a line feed, taken from a string so no code point has to
/// be converted into a character.
fn newline_char() -> Char {
  "\n".to_array()[0]
}

///|
/// Byte length of a code point encoded as UTF-8.
fn utf8_len(cp : Int32) -> Int32 {
  if cp < 0x80 {
    1
  } else if cp < 0x800 {
    2
  } else if cp < 0x10000 {
    3
  } else {
    4
  }
}

///|
/// Index of the quoted key in a flat JSON object, or -1.
///
/// Code points are compared as integers: 34 is the double quote and 58 the
/// colon, so the scanner never spells a character literal.
fn find_key(chars : Array[Char], key : String) -> Int32 {
  let kc = key.to_array()
  let n = chars.length()
  let m = kc.length()
  let mut i = 0
  let mut hit = -1
  while hit < 0 && i + m + 3 <= n {
    let quoted = chars[i].to_int() == 34
    let closes = quoted && chars[i + m + 1].to_int() == 34
    if closes && chars[i + m + 2].to_int() == 58 {
      let mut j = 0
      let mut same = true
      while same && j < m {
        if chars[i + 1 + j] != kc[j] {
          same = false
        } else {
          j = j + 1
        }
      }
      if same {
        hit = i
      } else {
        i = i + 1
      }
    } else {
      i = i + 1
    }
  }
  hit
}

///|
/// Read a JSON string body starting just after its opening quote.
///
/// The one-character escapes are decoded; any other escaped character is kept
/// as written, so nothing is silently dropped.
fn read_string(chars : Array[Char], start : Int32) -> String? {
  let n = chars.length()
  let out : Array[Char] = []
  let mut i = start
  let mut closed = false
  while !closed && i < n {
    let v = chars[i].to_int()
    if v == 34 {
      closed = true
      i = i + 1
    } else if v == 92 && i + 1 < n {
      let e = chars[i + 1].to_int()
      if e == 110 {
        out.push(newline_char())
      } else if e == 116 {
        out.push("\t".to_array()[0])
      } else if e == 114 {
        out.push("\r".to_array()[0])
      } else {
        out.push(chars[i + 1])
      }
      i = i + 2
    } else {
      out.push(chars[i])
      i = i + 1
    }
  }
  if closed {
    Some(String::from_array(out))
  } else {
    None
  }
}

///|
/// Read the digits of a number field, keeping them as text.
fn read_number(chars : Array[Char], start : Int32) -> String? {
  let n = chars.length()
  let out : Array[Char] = []
  let mut i = start
  while i < n && is_digit(chars[i]) {
    out.push(chars[i])
    i = i + 1
  }
  if out.length() == 0 {
    None
  } else {
    Some(String::from_array(out))
  }
}

///|
/// Read one field of a flat JSON object.
///
/// The compiler prints one flat object per line, so a linear search for the
/// quoted key is enough. A string value is decoded, escapes included; a number
/// is returned in decimal form.
pub fn field(json : String, key : String) -> String? {
  let chars = json.to_array()
  let kc = key.to_array()
  let hit = find_key(chars, key)
  if hit < 0 {
    return None
  }
  let n = chars.length()
  let mut i = hit + kc.length() + 3
  while i < n && chars[i].to_int() == 32 {
    i = i + 1
  }
  if i >= n {
    return None
  }
  if chars[i].to_int() == 34 {
    read_string(chars, i + 1)
  } else {
    read_number(chars, i)
  }
}

///|
/// Keep only the file name of a path.
///
/// A rendered snippet therefore never repeats a machine-specific directory.
pub fn display_path(path : String) -> String {
  let chars = path.to_array()
  let n = chars.length()
  let mut cut = 0
  for i = 0; i < n; i = i + 1 {
    let v = chars[i].to_int()
    if v == 47 || v == 92 {
      cut = i + 1
    }
  }
  let out : Array[Char] = []
  for i = cut; i < n; i = i + 1 {
    out.push(chars[i])
  }
  String::from_array(out)
}

///|
/// Read a digit run, returning the value and the index after it.
///
/// A missing digit run reports -1 as the value and the input index as the end.
fn parse_uint(chars : Array[Char], start : Int32) -> (Int32, Int32) {
  let n = chars.length()
  let mut i = start
  let mut value = 0
  let mut digits = 0
  while i < n && is_digit(chars[i]) {
    value = value * 10 + (chars[i].to_int() - 48)
    digits = digits + 1
    i = i + 1
  }
  if digits == 0 {
    (-1, start)
  } else {
    (value, i)
  }
}

///|
/// Byte offset of a 1-based (line, column) pair, or -1 when unreachable.
fn byte_offset_of(chars : Array[Char], line : Int32, column : Int32) -> Int32 {
  let n = chars.length()
  let mut cur_line = 1
  let mut cur_col = 1
  let mut offset = 0
  let mut found = -1
  let mut i = 0
  while found < 0 && i < n {
    if cur_line == line && cur_col == column {
      found = offset
    } else {
      let v = chars[i].to_int()
      if v == 10 {
        cur_line = cur_line + 1
        cur_col = 1
      } else {
        cur_col = cur_col + 1
      }
      offset = offset + utf8_len(v)
      i = i + 1
    }
  }
  if found < 0 && cur_line == line && cur_col == column {
    found = offset
  }
  found
}

///|
/// Convert a compiler `loc` value such as `3:3-3:15` into a byte span.
///
/// A single position (`3:3`) becomes a one-byte span so a caret still has a
/// cell to sit on; a line or column outside the source yields `None`.
pub fn span_from_loc(source : String, loc : String) -> @diagnostic.Span? {
  let lc = loc.to_array()
  let first = parse_uint(lc, 0)
  let line_a = first.0
  if line_a < 1 {
    return None
  }
  let i1 = first.1
  if i1 >= lc.length() || lc[i1].to_int() != 58 {
    return None
  }
  let second = parse_uint(lc, i1 + 1)
  let col_a = second.0
  if col_a < 1 {
    return None
  }
  let i2 = second.1
  let mut line_b = line_a
  let mut col_b = col_a
  if i2 < lc.length() && lc[i2].to_int() == 45 {
    let third = parse_uint(lc, i2 + 1)
    if third.0 >= 1 {
      line_b = third.0
      if third.1 < lc.length() && lc[third.1].to_int() == 58 {
        let fourth = parse_uint(lc, third.1 + 1)
        if fourth.0 >= 1 {
          col_b = fourth.0
        }
      }
    }
  }
  let chars = source.to_array()
  let start = byte_offset_of(chars, line_a, col_a)
  if start < 0 {
    return None
  }
  let fin = byte_offset_of(chars, line_b, col_b)
  if fin > start {
    Some(@diagnostic.Span::new(start, fin))
  } else {
    Some(@diagnostic.Span::new(start, start + 1))
  }
}

///|
/// Build a diagnostic whose severity comes from the compiler level name.
fn diagnostic_of(level : String, message : String) -> @diagnostic.Diagnostic {
  if level == "warning" {
    @diagnostic.Diagnostic::warning(message)
  } else if level == "note" {
    @diagnostic.Diagnostic::note(message)
  } else if level == "help" {
    @diagnostic.Diagnostic::help(message)
  } else {
    @diagnostic.Diagnostic::error(message)
  }
}

///|
/// Turn one compiler JSON diagnostic line into a rendered snippet.
///
/// A line without a message yields `None`, so a caller can skip the other
/// records the toolchain prints on the same stream.
pub fn render_json(
  json_line : String,
  source : String,
  options : @render_ansi.RenderOptions,
) -> String? {
  let mut message = ""
  let mut has_message = false
  match field(json_line, "message") {
    Some(v) => {
      message = v
      has_message = true
    }
    None => ()
  }
  if !has_message {
    return None
  }
  let mut level = "error"
  match field(json_line, "level") {
    Some(v) => level = v
    None => ()
  }
  let mut diag = diagnostic_of(level, message)
  match field(json_line, "error_code") {
    Some(code) => diag = diag.with_code(code)
    None => ()
  }
  match field(json_line, "loc") {
    Some(loc) =>
      match span_from_loc(source, loc) {
        Some(span) =>
          diag = diag.with_label(@diagnostic.Label::focused(span, message))
        None => ()
      }
    None => ()
  }
  let mut source_name = "<source>"
  match field(json_line, "path") {
    Some(path) => source_name = display_path(path)
    None => ()
  }
  Some(@render_ansi.render(diag, source_name, source, options))
}
