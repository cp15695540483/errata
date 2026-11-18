///|
/// Why a set of fixes cannot be applied safely.
pub(all) enum Refusal {
  /// The range starts before the buffer or ends after it.
  OutOfRange(Int32, Int32)
  /// Two ranges intersect. The payloads are their positions in the input.
  Overlap(Int32, Int32)
  /// A range starts or ends inside a multi-byte character.
  NotBoundary(Int32)
  /// The fixes were produced against a different text.
  Stale(Int32)
}

///|
/// Result of applying a set of fixes.
pub(all) enum ApplyOutcome {
  Applied(String)
  Refused(Refusal)
}

///|
/// One edit ready to be applied, with the offset already widened to Int.
priv struct Edit {
  start : Int32
  len : Int32
  replacement : String
}

///|
fn is_continuation(b : Int32) -> Bool {
  b >= 0x80 && b <= 0xBF
}

///|
/// Whether `offset` falls on a character boundary of `bytes`.
///
/// Offset 0 and the end of the buffer are boundaries by definition.
fn on_boundary(bytes : Bytes, offset : Int32) -> Bool {
  if offset <= 0 || offset >= bytes.length() {
    true
  } else {
    !is_continuation(bytes[offset].to_int())
  }
}

///|
/// Collect the fixes into edits, sorted by start offset.
fn to_edits(fixes : Array[@error-report.Fix]) -> Array[Edit] {
  let out : Array[Edit] = []
  for i = 0; i < fixes.length(); i = i + 1 {
    let f = fixes[i]
    out.push({
      start: f.span.start,
      len: f.span.len,
      replacement: f.replacement,
    })
  }
  let n = out.length()
  for i = 1; i < n; i = i + 1 {
    let cur = out[i]
    let mut j = i - 1
    let mut moving = true
    while moving && j >= 0 {
      if out[j].start > cur.start {
        out[j + 1] = out[j]
        j = j - 1
      } else {
        moving = false
      }
    }
    out[j + 1] = cur
  }
  out
}

///|
/// Check a set of fixes against a buffer without touching it.
///
/// The checks run in this order so the reported reason is the first real
/// problem: range, character boundary, then intersection.
pub fn check(text : String, fixes : Array[@error-report.Fix]) -> Refusal? {
  let bytes = @utf8.encode(text)
  let size = bytes.length()
  let edits = to_edits(fixes)
  let n = edits.length()
  let mut i = 0
  let mut bad : Refusal? = None
  while bad is None && i < n {
    let e = edits[i]
    if e.start < 0 || e.len < 0 || e.start + e.len > size {
      bad = Some(Refusal::OutOfRange(e.start, e.len))
    } else if !on_boundary(bytes, e.start) ||
      !on_boundary(bytes, e.start + e.len) {
      bad = Some(Refusal::NotBoundary(i))
    } else {
      i = i + 1
    }
  }
  let mut a = 0
  while bad is None && a + 1 < n {
    let prev = edits[a]
    let next = edits[a + 1]
    if prev.start + prev.len > next.start {
      bad = Some(Refusal::Overlap(a, a + 1))
    } else {
      a = a + 1
    }
  }
  bad
}

///|
/// Apply a set of fixes to `text`.
///
/// `check` runs first, so a refused set leaves the text untouched. Applied
/// fixes are copied in a single pass; adjacent ranges are allowed and an empty
/// range inserts text without deleting anything.
pub fn apply(text : String, fixes : Array[@error-report.Fix]) -> ApplyOutcome {
  match check(text, fixes) {
    Some(reason) => Refused(reason)
    None => {
      let bytes = @utf8.encode(text)
      let edits = to_edits(fixes)
      let out : Array[Byte] = []
      let mut cursor = 0
      for i = 0; i < edits.length(); i = i + 1 {
        let e = edits[i]
        while cursor < e.start {
          out.push(bytes[cursor])
          cursor = cursor + 1
        }
        let repl = @utf8.encode(e.replacement)
        for k = 0; k < repl.length(); k = k + 1 {
          out.push(repl[k])
        }
        cursor = e.start + e.len
      }
      while cursor < bytes.length() {
        out.push(bytes[cursor])
        cursor = cursor + 1
      }
      Applied(@utf8.decode_lossy(Bytes::from_array(out)))
    }
  }
}

///|
/// Number of fixes in a set, for callers that report progress.
pub fn count(fixes : Array[@error-report.Fix]) -> Int32 {
  fixes.length()
}
