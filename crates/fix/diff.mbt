///|
/// Split into lines without keeping the terminators.
fn lines_of(text : String) -> Array[String] {
  let out : Array[String] = []
  for part in text.split("\n") {
    out.push(part.to_owned())
  }
  out
}

///|
fn same_lines(a : Array[String], b : Array[String]) -> Bool {
  if a.length() != b.length() {
    return false
  }
  let mut i = 0
  let mut eq = true
  while eq && i < a.length() {
    if a[i] != b[i] {
      eq = false
    } else {
      i = i + 1
    }
  }
  eq
}

///|
/// Unified-style difference of two texts.
///
/// The common prefix and suffix are dropped first, so a change reads as one
/// hunk with two lines of context. Identical texts produce an empty string.
pub fn diff(old_text : String, new_text : String) -> String {
  if old_text == new_text {
    return ""
  }
  let a = lines_of(old_text)
  let b = lines_of(new_text)
  if same_lines(a, b) {
    return ""
  }
  let mut pre = 0
  while pre < a.length() && pre < b.length() && a[pre] == b[pre] {
    pre = pre + 1
  }
  let mut suf = 0
  while suf < a.length() - pre && suf < b.length() - pre && a[a.length() - 1 - suf] == b[b.length() - 1 - suf] {
    suf = suf + 1
  }
  let ctx = 2
  let from = if pre > ctx { pre - ctx } else { 0 }
  let old_end = a.length() - suf
  let new_end = b.length() - suf
  let mut out = "@@ -"
  out = out + (from + 1).to_string() + "," + (old_end - from).to_string()
  out = out + " +" + (from + 1).to_string() + "," + (new_end - from).to_string() + " @@"
  out = out + "\n"
  for i = from; i < pre; i = i + 1 {
    out = out + " " + a[i] + "\n"
  }
  for i = pre; i < old_end; i = i + 1 {
    out = out + "-" + a[i] + "\n"
  }
  for i = pre; i < new_end; i = i + 1 {
    out = out + "+" + b[i] + "\n"
  }
  let tail_stop = if old_end + ctx < a.length() { old_end + ctx } else { a.length() }
  for i = old_end; i < tail_stop; i = i + 1 {
    out = out + " " + a[i] + "\n"
  }
  out
}

