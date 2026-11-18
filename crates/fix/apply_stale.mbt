///|
/// Apply a set of fixes only when every range still fits the current text.
///
/// A stale set is refused instead of edited at the wrong position. This is the
/// second guarantee of safe application: overlap is refused, stale is refused.
pub fn apply_verified(
  text : String,
  fixes : Array[@error-report.Fix],
) -> ApplyOutcome {
  let bytes = @utf8.encode(text)
  let n = fixes.length()
  let mut stale = -1
  let mut i = 0
  while stale < 0 && i < n {
    let fix = fixes[i]
    let start = fix.span.start
    let len = fix.span.len
    if start < 0 || len < 0 || start + len > bytes.length() {
      stale = i
    } else {
      i = i + 1
    }
  }
  if stale >= 0 {
    return Refused(Stale(stale))
  }
  apply(text, fixes)
}
