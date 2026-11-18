///|
fn plan(
  path : String,
  start : Int32,
  len : Int32,
  replacement : String,
) -> FilePlan {
  let fix : @error-report.Fix = {
    source: @error-report.SourceId(0),
    span: @error-report.Span::{ start, len, },
    replacement,
    description: "",
  }
  { path, fixes: [fix], }
}

///|
test "a valid transaction applies every file" {
  let plans = [plan("a", 0, 1, "A"), plan("b", 0, 1, "B")]
  let texts = ["x", "y"]
  match apply_all(plans, texts) {
    AllApplied(n) => assert_eq(n, 2)
    Refused(p, _) => assert_eq(p, "should not happen")
  }
}

///|
test "a refused transaction reports the failing file" {
  let plans = [plan("a", 0, 1, "A"), plan("b", 5, 1, "B")]
  let texts = ["x", "y"]
  match apply_all(plans, texts) {
    AllApplied(_) => assert_eq(true, false)
    Refused(p, _) => assert_eq(p, "b")
  }
}

///|
test "verify reports the first problem" {
  let plans = [plan("a", 0, 1, "A"), plan("b", 5, 1, "B")]
  let texts = ["x", "y"]
  assert_eq(verify(plans, texts), 1)
}

///|
test "an unchanged file does not count as applied" {
  let plans = [plan("a", 0, 1, "x")]
  let texts = ["x"]
  match apply_all(plans, texts) {
    AllApplied(n) => assert_eq(n, 0)
    Refused(_, _) => assert_eq(true, false)
  }
}
