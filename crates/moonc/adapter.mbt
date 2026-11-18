///|
/// A compiler record reduced to the fields this adapter needs.
pub(all) struct Record {
  level : String
  code : String
  message : String
  loc : String
}

///|
fn is_digit(c : Char) -> Bool {
  c.to_int() >= 48 && c.to_int() <= 57
}

///|
fn find_key(chars : Array[Char], key : String) -> Int32 {
  let kc = key.to_array()
  let n = chars.length()
  let m = kc.length()
  let mut i = 0
  let mut hit = -1
  while hit < 0 && i + m + 3 <= n {
    if chars[i].to_int() == 34 &&
      chars[i + m + 1].to_int() == 34 &&
      chars[i + m + 2].to_int() == 58 {
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
  if i >= n || chars[i].to_int() != 34 {
    return None
  }
  let out : Array[Char] = []
  let mut k = i + 1
  let mut closed = false
  while !closed && k < n {
    let v = chars[k].to_int()
    if v == 34 {
      closed = true
      k = k + 1
    } else if v == 92 && k + 1 < n {
      let e = chars[k + 1].to_int()
      if e == 110 {
        out.push("\n".to_array()[0])
      } else if e == 116 {
        out.push("\t".to_array()[0])
      } else {
        out.push(chars[k + 1])
      }
      k = k + 2
    } else {
      out.push(chars[k])
      k = k + 1
    }
  }
  if closed {
    Some(String::from_array(out))
  } else {
    None
  }
}

///|
/// Reduce one compiler JSON line to a `Record`, or `None` when it is not a
/// diagnostic.
pub fn parse(line : String) -> Record? {
  let message = match field(line, "message") {
    Some(v) => v
    None => return None
  }
  let level = match field(line, "level") {
    Some(v) => v
    None => "error"
  }
  let code = match field(line, "error_code") {
    Some(v) => v
    None => ""
  }
  let loc = match field(line, "loc") {
    Some(v) => v
    None => ""
  }
  Some({ level, code, message, loc, })
}

///|
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
/// Byte offset of a 1-based (line, column) pair, or -1.
fn byte_of(chars : Array[Char], line : Int32, column : Int32) -> Int32 {
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
fn read_uint(chars : Array[Char], start : Int32) -> (Int32, Int32) {
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
/// Turn a compiler `loc` such as `3:3-3:15` into a byte range of `source`.
///
/// A single position becomes an empty range so a caret still has a cell.
pub fn range_of_loc(source : String, loc : String) -> (Int32, Int32)? {
  let lc = loc.to_array()
  let first = read_uint(lc, 0)
  if first.0 < 1 || first.1 >= lc.length() || lc[first.1].to_int() != 58 {
    return None
  }
  let second = read_uint(lc, first.1 + 1)
  if second.0 < 1 {
    return None
  }
  let mut line_b = first.0
  let mut col_b = second.0
  if second.1 < lc.length() && lc[second.1].to_int() == 45 {
    let third = read_uint(lc, second.1 + 1)
    if third.0 >= 1 {
      line_b = third.0
      if third.1 < lc.length() && lc[third.1].to_int() == 58 {
        let fourth = read_uint(lc, third.1 + 1)
        if fourth.0 >= 1 {
          col_b = fourth.0
        }
      }
    }
  }
  let chars = source.to_array()
  let start = byte_of(chars, first.0, second.0)
  if start < 0 {
    return None
  }
  let stop = byte_of(chars, line_b, col_b)
  if stop > start {
    Some((start, stop))
  } else {
    Some((start, start))
  }
}

///|
fn severity_of(level : String) -> @error-report.Severity {
  if level == "warning" {
    @error-report.Severity::Warning
  } else if level == "note" || level == "help" {
    @error-report.Severity::Advice
  } else {
    @error-report.Severity::Error
  }
}

///|
/// Render one compiler JSON line against its source through the shared
/// renderer, so this project adds no second snippet layout.
pub fn render_line(
  line : String,
  source_name : String,
  source_text : String,
  is_tty : Bool,
) -> String? {
  let record = match parse(line) {
    Some(v) => v
    None => return None
  }
  let sources = @error-report.Sources::new()
  let sid = sources.add(source_name, source_text)
  let mut report = @error-report.Report::new(
    severity_of(record.level),
    record.message,
  )
  if record.code != "" {
    report = report.with_code(record.code)
  }
  match range_of_loc(source_text, record.loc) {
    Some(pair) => {
      let (start, stop) = pair
      let span = @error-report.Span::of_range(start, stop)
      report = report.with_label(
        @error-report.Label::primary(sid, span, message=record.message),
      )
    }
    None => ()
  }
  Some(@render.render_string(report, sources, @render.default_config, is_tty~))
}
