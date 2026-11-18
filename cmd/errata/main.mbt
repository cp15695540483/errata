///|
fn usage() -> String {
  "usage: errata render <json-record> <source-text> | errata fix <manifest> [--write]"
}

///|
fn read_text(path : String) -> String? {
  let bytes = @fs.read_file_to_bytes(path) catch { _ => return None }
  Some(@utf8.decode_lossy(bytes))
}

///|
fn write_text(path : String, text : String) -> Bool {
  let ok = @fs.write_bytes_to_file(path, @utf8.encode(text)) catch { _ => return false }
  ignore(ok)
  true
}

///|
/// Everything after the mode word on the command line.
fn args_after(args : Array[String], mode : String) -> Array[String] {
  let out : Array[String] = []
  let mut seen = false
  for i = 0; i < args.length(); i = i + 1 {
    if seen {
      out.push(args[i])
    } else if args[i] == mode {
      seen = true
    }
  }
  out
}

///|
/// Apply the manifest in dry-run mode, printing a diff per file, or write the
/// result when `--write` is present.
fn run_fix(manifest_path : String, write : Bool) -> Unit {
  let text = match read_text(manifest_path) {
    Some(v) => v
    None => {
      println("cannot read " + manifest_path)
      return
    }
  }
  let plans = @fix.parse_manifest(text)
  if plans.length() == 0 {
    println("no fixes in " + manifest_path)
    return
  }
  let mut applied = 0
  let mut refused = 0
  for i = 0; i < plans.length(); i = i + 1 {
    let plan = plans[i]
    let source = match read_text(plan.path) {
      Some(v) => v
      None => {
        println("cannot read " + plan.path)
        continue
      }
    }
    match @fix.apply(source, plan.fixes) {
      Applied(next) => {
        if next == source {
          println("unchanged " + plan.path)
        } else if write {
          let ok = write_text(plan.path, next)
          if ok {
            println("fixed " + plan.path)
          } else {
            println("cannot write " + plan.path)
          }
        } else {
          applied = applied + 1
          println("--- " + plan.path)
          println(@fix.diff(source, next))
        }
      }
      Refused(reason) => {
        refused = refused + 1
        println("refused " + plan.path + ": " + @fix.describe(reason))
      }
    }
  }
  println("" + applied.to_string() + " applied, " + refused.to_string() + " refused")
}

///|
fn main {
  let args = @env.args()
  let render_args = args_after(args, "render")
  let fix_args = args_after(args, "fix")
  if render_args.length() >= 2 {
    match @moonc.render_line(render_args[0], "input.mbt", render_args[1], false) {
      Some(out) => println(out)
      None => println("not a diagnostic record")
    }
  } else if fix_args.length() >= 1 {
    let mut write = false
    for i = 1; i < fix_args.length(); i = i + 1 {
      if fix_args[i] == "--write" {
        write = true
      }
    }
    run_fix(fix_args[0], write)
  } else {
    println(usage())
  }
}

