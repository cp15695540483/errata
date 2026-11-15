///|
/// Walk `bytes[start..end]`, advancing a display column.
///
/// A tab jumps to the next multiple of `tab_width`; a line feed or carriage
/// return resets the column; a code point adds its display width.
fn advance(
  bytes : Bytes,
  start : Int32,
  end : Int32,
  column : Int32,
  tab_width : Int32,
) -> Int32 {
  let n = bytes.length()
  let mut tab = tab_width
  if tab < 1 {
    tab = 1
  }
  let mut limit = end
  if limit > n {
    limit = n
  }
  let mut i = start
  let mut col = column
  while i < limit {
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
        i = limit
      } else {
        col = col + codepoint_width(cp)
        i = i + len
      }
    }
  }
  col
}

///|
/// Display column reached after the first `end` bytes of `text`.
///
/// `end` is clamped to the buffer, so a caret never lands past the text.
pub fn prefix_width(text : String, end : Int32, tab_width : Int32) -> Int32 {
  advance(@utf8.encode(text), 0, end, 0, tab_width)
}

///|
/// Replace every tab with the spaces that reach the next tab stop.
///
/// The result has one code point per displayed cell, so a renderer can line
/// carets up by counting characters.
pub fn expand_tabs(text : String, tab_width : Int32) -> String {
  let mut tab = tab_width
  if tab < 1 {
    tab = 1
  }
  let mut out = ""
  let mut col = 0
  let mut first = true
  for part in text.split("\t") {
    if first {
      first = false
    } else {
      let rem = col - col / tab * tab
      let pad = tab - rem
      for k = 0; k < pad; k = k + 1 {
        out = out + " "
      }
      col = col + pad
    }
    let seg = part.to_owned()
    out = out + seg
    col = col + text_width(seg)
  }
  out
}
