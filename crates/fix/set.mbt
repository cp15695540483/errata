///|
/// Whether two fixes are the same edit.
///
/// Two fixes are equal when they share a source, a span and a replacement; the
/// description is treated as presentation, not identity.
fn same_fix(a : @error-report.Fix, b : @error-report.Fix) -> Bool {
  a.source == b.source &&
  a.span.start == b.span.start &&
  a.span.len == b.span.len &&
  a.replacement == b.replacement
}

///|
fn before(a : @error-report.Fix, b : @error-report.Fix) -> Bool {
  a.span.start < b.span.start ||
  (a.span.start == b.span.start && a.span.len < b.span.len)
}

///|
/// Sort a fix set by start offset, then by length.
///
/// This makes application order independent of the order a tool emitted the
/// fixes, which is the property the applier relies on.
pub fn sorted(fixes : Array[@error-report.Fix]) -> Array[@error-report.Fix] {
  let out : Array[@error-report.Fix] = []
  for i = 0; i < fixes.length(); i = i + 1 {
    out.push(fixes[i])
  }
  let n = out.length()
  for i = 1; i < n; i = i + 1 {
    let cur = out[i]
    let mut j = i - 1
    let mut moving = true
    while moving && j >= 0 {
      if before(cur, out[j]) {
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
/// Drop exact duplicates, keeping the first occurrence.
///
/// The result is in sorted order, so deduplication is stable and reproducible.
pub fn dedup(fixes : Array[@error-report.Fix]) -> Array[@error-report.Fix] {
  let ordered = sorted(fixes)
  let out : Array[@error-report.Fix] = []
  let n = ordered.length()
  let mut i = 0
  while i < n {
    let dup = i > 0 && same_fix(ordered[i], ordered[i - 1])
    if !dup {
      out.push(ordered[i])
    }
    i = i + 1
  }
  out
}

///|
/// Number of fixes after deduplication.
pub fn unique_count(fixes : Array[@error-report.Fix]) -> Int {
  dedup(fixes).length()
}

///|
/// The fixes that belong to one source, with the source id.
pub(all) struct Group {
  source : @error-report.SourceId
  fixes : Array[@error-report.Fix]
}

///|
/// Group deduplicated fixes by source id, in first-seen order.
pub fn group(fixes : Array[@error-report.Fix]) -> Array[Group] {
  let ordered = dedup(fixes)
  let ids : Array[@error-report.SourceId] = []
  let groups : Array[Array[@error-report.Fix]] = []
  for i = 0; i < ordered.length(); i = i + 1 {
    let fix = ordered[i]
    let mut found = -1
    for k = 0; k < ids.length(); k = k + 1 {
      if found < 0 && ids[k] == fix.source {
        found = k
      }
    }
    if found < 0 {
      ids.push(fix.source)
      let g : Array[@error-report.Fix] = [fix]
      groups.push(g)
    } else {
      groups[found].push(fix)
    }
  }
  let out : Array[Group] = []
  for i = 0; i < ids.length(); i = i + 1 {
    out.push({ source: ids[i], fixes: groups[i] })
  }
  out
}

///|
/// A summary of what a set contains.
pub(all) struct Summary {
  files : Int
  fixes : Int
}

///|
/// Count groups and the deduplicated fixes across them.
pub fn summary(fixes : Array[@error-report.Fix]) -> Summary {
  let groups = group(fixes)
  let mut total = 0
  for i = 0; i < groups.length(); i = i + 1 {
    total = total + groups[i].fixes.length()
  }
  { files: groups.length(), fixes: total }
}


