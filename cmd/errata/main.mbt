///|
fn usage() -> String {
  "usage: errata render <json-record> <source-text>"
}

///|
fn main {
  let args = @env.args()
  let n = args.length()
  if n >= 3 && args[n - 3] == "render" {
    match @moonc.render_line(args[n - 2], "input.mbt", args[n - 1], false) {
      Some(text) => println(text)
      None => println("not a diagnostic record")
    }
  } else {
    println(usage())
  }
}

