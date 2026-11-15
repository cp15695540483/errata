///|
fn in_ranges(cp : Int32, ranges : Array[Int32]) -> Bool {
  let mut i = 0
  let mut found = false
  while i + 1 < ranges.length() {
    if cp >= ranges[i] && cp <= ranges[i + 1] {
      found = true
      i = ranges.length()
    } else {
      i = i + 2
    }
  }
  found
}

///|
/// Code points that occupy no column: combining marks, variation selectors
/// and zero-width layout characters.
fn zero_width_ranges() -> Array[Int32] {
  [
    0x0300, 0x036F, 0x0483, 0x0489, 0x0591, 0x05BD, 0x0610, 0x061A, 0x064B, 0x065F,
    0x1AB0, 0x1AFF, 0x1DC0, 0x1DFF, 0x20D0, 0x20F0, 0x200B, 0x200F, 0x2060, 0x2064,
    0xFE00, 0xFE0F, 0xFE20, 0xFE2F,
  ]
}

///|
/// Code points that occupy two columns: CJK, kana, hangul, fullwidth forms
/// and emoji presentation ranges.
fn wide_ranges() -> Array[Int32] {
  [
    0x1100, 0x115F, 0x2E80, 0x303E, 0x3041, 0x33FF, 0x3400, 0x4DBF, 0x4E00, 0x9FFF,
    0xA000, 0xA4CF, 0xA960, 0xA97F, 0xAC00, 0xD7A3, 0xF900, 0xFAFF, 0xFE10, 0xFE19,
    0xFE30, 0xFE6F, 0xFF00, 0xFF60, 0xFFE0, 0xFFE6, 0x1F300, 0x1F64F, 0x1F900, 0x1F9FF,
    0x20000, 0x2FFFD, 0x30000, 0x3FFFD,
  ]
}

///|
/// Display columns one code point occupies: 0, 1 or 2.
///
/// Control characters count as zero so a renderer never shifts a caret
/// because of an unprintable byte.
pub fn codepoint_width(cp : Int32) -> Int32 {
  if cp < 0 {
    1
  } else if cp < 0x20 || cp == 0x7F {
    0
  } else if in_ranges(cp, zero_width_ranges()) {
    0
  } else if in_ranges(cp, wide_ranges()) {
    2
  } else {
    1
  }
}

///|
/// Advance a column across `bytes[start..]`.
///
/// A tab jumps to the next multiple of `tab_width`; a line feed or carriage
/// return resets the column; every other code point adds its display width.
pub fn column_after(
  bytes : Bytes,
  start : Int32,
  column : Int32,
  tab_width : Int32,
) -> Int32 {
  let n = bytes.length()
  let mut tab = tab_width
  if tab < 1 {
    tab = 1
  }
  let mut i = start
  let mut col = column
  while i < n {
    let b = bytes[i].to_int()
    if b == 9 {
      let rem = col - col / tab * tab
      col = col + (tab - rem)
      i = i + 1
    } else if b == 10 || b == 13 {
      col = 0
      i = i + 1
    } else {
      let (cp, len) = decode_utf8(bytes, i)
      if len == 0 {
        i = n
      } else {
        col = col + codepoint_width(cp)
        i = i + len
      }
    }
  }
  col
}

///|
/// Display width of a single-line string. Tabs count as one column here;
/// use `column_after` when a tab stop matters.
pub fn text_width(text : String) -> Int32 {
  column_after(@utf8.encode(text), 0, 0, 1)
}
