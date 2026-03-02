use serde_json::json;
use std::io::{self, Read};

fn main() {
    if let Err(err) = run() {
        eprintln!("{err}");
        std::process::exit(1);
    }
}

fn run() -> Result<(), String> {
    let mut input = String::new();
    io::stdin()
        .read_to_string(&mut input)
        .map_err(|e| format!("stdin read failed: {e}"))?;

    let _payload: serde_json::Value = if input.trim().is_empty() {
        json!({})
    } else {
        serde_json::from_str(&input).map_err(|e| format!("json parse failed: {e}"))?
    };

    let out = json!({
        "plugin_kind": "__PLUGIN_ID__",
        "status": "ok",
        "message": "Rust plugin executed"
    });
    println!("{}", serde_json::to_string(&out).map_err(|e| format!("serialize failed: {e}"))?);
    Ok(())
}
