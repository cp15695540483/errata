///|
/// Decode one UTF-8 code point at `index`.
///
/// Returns `(code point, byte length)`. A malformed or truncated sequence
/// yields `(0xFFFD, 1)`; an index outside the buffer yields `(0xFFFD, 0)`.
pub fn decode_utf8(bytes : Bytes, index : Int32) -> (Int32, Int32) {
  let n = bytes.length()
  if index < 0 || index >= n {
    return (0xFFFD, 0)
  }
  let b0 = bytes[index].to_int()
  if b0 < 0x80 {
    return (b0, 1)
  }
  if index + 1 < n && b0 >= 0xC2 && b0 <= 0xDF {
    let b1 = bytes[index + 1].to_int()
    if b1 >= 0x80 && b1 <= 0xBF {
      return ((b0 - 0xC0) * 64 + (b1 - 0x80), 2)
    }
  }
  if index + 2 < n && b0 >= 0xE0 && b0 <= 0xEF {
    let b1 = bytes[index + 1].to_int()
    let b2 = bytes[index + 2].to_int()
    if b1 >= 0x80 && b1 <= 0xBF && b2 >= 0x80 && b2 <= 0xBF {
      return ((b0 - 0xE0) * 4096 + (b1 - 0x80) * 64 + (b2 - 0x80), 3)
    }
  }
  if index + 3 < n && b0 >= 0xF0 && b0 <= 0xF4 {
    let b1 = bytes[index + 1].to_int()
    let b2 = bytes[index + 2].to_int()
    let b3 = bytes[index + 3].to_int()
    if b1 >= 0x80 &&
      b1 <= 0xBF &&
      b2 >= 0x80 &&
      b2 <= 0xBF &&
      b3 >= 0x80 &&
      b3 <= 0xBF {
      return (
        (b0 - 0xF0) * 262144 +
        (b1 - 0x80) * 4096 +
        (b2 - 0x80) * 64 +
        (b3 - 0x80),
        4,
      )
    }
  }
  (0xFFFD, 1)
}
