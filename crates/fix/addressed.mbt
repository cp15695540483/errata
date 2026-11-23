///|
/// FNV-1a over the bytes, kept non-negative so the hex form is stable.
fn fnv1a(bytes : Bytes, seed : Int32) -> Int32 {
  let mut h = seed
  for i = 0; i < bytes.length(); i = i + 1 {
    h = h ^ bytes[i].to_int()
    h = h * 16777619
    h = h & 0x7FFFFFFF
  }
  h
}

///|
fn hex8(v : Int32) -> String {
  let digits = "0123456789abcdef"
  let ds = digits.to_array()
  let out : Array[Char] = []
  let mut shift = 28
  while shift >= 0 {
    let nib = (v >> shift) & 0xF
    out.push(ds[nib])
    shift = shift - 4
  }
  String::from_array(out)
}

///|
/// A content snapshot of a whole text.
///
/// Two independently seeded hashes are concatenated, so a re-run is recognised
/// by the bytes of the file, not by a position. This is the check that a
/// position anchor cannot make: an insertion whose text equals its anchor would
/// still match the anchor after being applied, but it cannot match the snapshot.
pub fn snapshot_of(text : String) -> String {
  let bytes = @utf8.encode(text)
  hex8(fnv1a(bytes, 0x811c9dc5)) + hex8(fnv1a(bytes, 0x9e3779b9))
}

///|
/// A fix with an optional expected-text anchor and an optional file snapshot.
///
/// `expected` guards the replaced range. `snapshot` guards the whole file: when
/// it is set, the file must still hash to it or the fix is refused as stale.
/// The snapshot is what makes a re-run safe even when the inserted text equals
/// the anchor text.
pub(all) struct AddressedFix {
  fix : @error-report.Fix
  expected : String?
  snapshot : String?
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
fn slice_of(bytes : Bytes, start : Int32, len : Int32) -> String {
  let out : Array[Byte] = []
  for i = start; i < start + len && i < bytes.length(); i = i + 1 {
    out.push(bytes[i])
  }
  @utf8.decode_lossy(Bytes::from_array(out))
}

///|
/// Range, boundary and intersection checks, then the file snapshot, then the
/// range anchor.
///
/// The snapshot runs before the range anchor because it is the stronger claim:
/// it refuses any change to the file at all, while the anchor only refuses a
/// change inside the replaced range.
pub fn check_addressed(text : String, fixes : Array[AddressedFix]) -> Refusal? {
  match check(text, bare(fixes)) {
    Some(reason) => Some(reason)
    None => {
      let bytes = @utf8.encode(text)
      let actual_snapshot = snapshot_of(text)
      let mut i = 0
      let mut bad : Refusal? = None
      while bad is None && i < fixes.length() {
        let addressed = fixes[i]
        let snapshot_ok = match addressed.snapshot {
          Some(want) => want == actual_snapshot
          None => true
        }
        if !snapshot_ok {
          bad = Some(Refusal::Stale(i))
        } else {
          let anchor_ok = match addressed.expected {
            Some(expected) => {
              let span = addressed.fix.span
              let check_len = if span.len == 0 {
                @utf8.encode(expected).length()
              } else {
                span.len
              }
              slice_of(bytes, span.start, check_len) == expected
            }
            None => true
          }
          if !anchor_ok {
            bad = Some(Refusal::Stale(i))
          } else {
            i = i + 1
          }
        }
      }
      bad
    }
  }
}

///|
/// Apply a set of addressed fixes after the snapshot and anchors pass.
pub fn apply_addressed(
  text : String,
  fixes : Array[AddressedFix],
) -> ApplyOutcome {
  match check_addressed(text, fixes) {
    Some(reason) => Refused(reason)
    None => apply(text, bare(fixes))
  }
}
