///|
/// Text shown when the positional arguments are missing.
fn usage() -> String {
  "usage: errata <json-record> <source-text>"
}

///|
/// Render one compiler diagnostic record against the source text it refers to.
///
/// Both inputs are positional: first the record the toolchain prints, then the
/// source text. The rendered snippet is written to standard output.
fn main {
  let args = @env.args()
  let n = args.length()
  if n < 2 {
    println(usage())
  } else {
    let record = args[n - 2]
    let source = args[n - 1]
    match @cli.render_json(record, source, @render_ansi.RenderOptions::new(4)) {
      Some(text) => println(text)
      None => println("not a diagnostic record")
    }
  }
}
