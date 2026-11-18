///|
/// A planned edit for one file.
pub(all) struct Transaction {
  path : String
  fixes : Array[@error-report.Fix]
}

///|
/// The result of trying to land a transaction.
pub(all) enum TransactionOutcome {
  AllApplied(Int32)
  Refused(String, Refusal)
}

///|
/// Dry-check every plan in the transaction without writing anything.
///
/// The purpose of a transaction is "all or nothing": if any file would refuse,
/// nothing is written. This function computes the verdict first.
pub fn verify(plans : Array[FilePlan], texts : Array[String]) -> Int32 {
  let mut i = 0
  let mut bad = -1
  while bad < 0 && i < plans.length() && i < texts.length() {
    let refusal = check(texts[i], plans[i].fixes)
    match refusal {
      Some(_) => bad = i
      None => i = i + 1
    }
  }
  bad
}

///|
/// Apply every plan and count the files changed, or refuse the whole thing.
///
/// Because the caller supplies the already-read texts and writes them back only
/// when this returns `AllApplied`, a refused transaction leaves every file
/// untouched. The IO is outside this pure function by design.
pub fn apply_all(
  plans : Array[FilePlan],
  texts : Array[String],
) -> TransactionOutcome {
  let bad_index = verify(plans, texts)
  if bad_index >= 0 {
    let reason = check(texts[bad_index], plans[bad_index].fixes).unwrap()
    return Refused(plans[bad_index].path, reason)
  }
  let changed : Array[String] = []
  let mut applied = 0
  let mut i = 0
  while i < plans.length() && i < texts.length() {
    match apply(texts[i], plans[i].fixes) {
      Applied(next) => {
        changed.push(next)
        if next != texts[i] {
          applied = applied + 1
        }
      }
      Refused(reason) => return Refused(plans[i].path, reason)
    }
    i = i + 1
  }
  ignore(changed)
  AllApplied(applied)
}
