///|
/// A fix with an optional expected-text anchor.
///
/// `expected` is the text the fix was produced against. When it is `Some(s)`,
/// the range must still contain exactly `s` or the fix is refused as stale. This
/// is what makes a same-length edit detectable: position alone cannot see that
/// `abc` became `abd`, but the anchor can.
pub(all) struct AddressedFix {
  fix : @error-report.Fix
  expected : String?
}

///|
fn bare(fixes : Array[AddressedFix]) -> Array[@error-report.Fix] {
  let out : Array[@error-report.Fix] = []
  for i = 0; i < fixes.length(); i = i + 1 {
    out.push(fixes[i].fix)
  }
  out
}

///|
/// The text currently at a byte range, decoded lossily.
fn slice_of(bytes : Bytes, start : Int32, len : Int32) -> String {
  let out : Array[Byte] = []
  for i = start; i < start + len && i < bytes.length(); i = i + 1 {
    out.push(bytes[i])
  }
  @utf8.decode_lossy(Bytes::from_array(out))
}

///|
/// Check range, boundary and intersection as usual, then check every anchor.
///
/// A fix whose `expected` is `Some(s)` must still find `s` at its span,
/// otherwise the whole set is refused with `Stale(i)`. This is the content
/// check that makes the stale guarantee meaningful for same-length edits.
pub fn check_addressed(text : String, fixes : Array[AddressedFix]) -> Refusal? {
  match check(text, bare(fixes)) {
    Some(reason) => Some(reason)
    None => {
      let bytes = @utf8.encode(text)
      let mut i = 0
      let mut bad : Refusal? = None
      while bad is None && i < fixes.length() {
        let addressed = fixes[i]
        match addressed.expected {
          Some(expected) => {
            let span = addressed.fix.span
            let check_len = if span.len == 0 {
              @utf8.encode(expected).length()
            } else {
              span.len
            }
            let actual = slice_of(bytes, span.start, check_len)
            if actual != expected {
              bad = Some(Refusal::Stale(i))
            } else {
              i = i + 1
            }
          }
          None => i = i + 1
        }
      }
      bad
    }
  }
}

///|
/// Apply a set of addressed fixes after their anchors pass.
pub fn apply_addressed(
  text : String,
  fixes : Array[AddressedFix],
) -> ApplyOutcome {
  match check_addressed(text, fixes) {
    Some(reason) => Refused(reason)
    None => apply(text, bare(fixes))
  }
}
