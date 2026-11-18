///|
/// The fixes requested for one file.
pub(all) struct FilePlan {
  path : String
  fixes : Array[@error-report.Fix]
}

///|
/// Split one manifest line into its four fields.
fn fields(line : String) -> Array[String] {
  let out : Array[String] = []
  for part in line.split("\t") {
    out.push(part.to_owned())
  }
  out
}

///|
fn to_int(text : String) -> Int? {
  let chars = text.to_array()
  if chars.length() == 0 {
    return None
  }
  let mut i = 0
  let mut value = 0
  let mut neg = false
  if chars[0].to_int() == 45 {
    neg = true
    i = 1
  }
  let mut digits = 0
  while i < chars.length() {
    let v = chars[i].to_int()
    if v < 48 || v > 57 {
      return None
    }
    value = value * 10 + (v - 48)
    digits = digits + 1
    i = i + 1
  }
  if digits == 0 {
    return None
  }
  if neg {
    Some(-value)
  } else {
    Some(value)
  }
}

///|
fn make_fix(start : Int, len : Int, replacement : String) -> @error-report.Fix {
  {
    source: @error-report.SourceId(0),
    span: @error-report.Span::{ start: start, len: len },
    replacement: replacement,
    description: "",
  }
}

///|
/// Parse a fix manifest.
///
/// One fix per line: path, start, length, replacement, separated by tabs.
/// Blank lines and lines starting with a hash are ignored, and a malformed line
/// is skipped instead of aborting the manifest.
pub fn parse_manifest(text : String) -> Array[FilePlan] {
  let paths : Array[String] = []
  let groups : Array[Array[@error-report.Fix]] = []
  for raw in text.split("\n") {
    let line = raw.trim().to_owned()
    let skip = line == "" || line.has_prefix("#")
    if !skip {
      let parts = fields(line)
      if parts.length() >= 4 {
        match to_int(parts[1]) {
          Some(start) =>
            match to_int(parts[2]) {
              Some(len) => {
                let fix = make_fix(start, len, parts[3])
                let mut found = -1
                for k = 0; k < paths.length(); k = k + 1 {
                  if found < 0 && paths[k] == parts[0] {
                    found = k
                  }
                }
                if found < 0 {
                  let g : Array[@error-report.Fix] = [fix]
                  paths.push(parts[0])
                  groups.push(g)
                } else {
                  groups[found].push(fix)
                }
              }
              None => ()
            }
          None => ()
        }
      }
    }
  }
  let plans : Array[FilePlan] = []
  for i = 0; i < paths.length(); i = i + 1 {
    plans.push({ path: paths[i], fixes: groups[i] })
  }
  plans
}

