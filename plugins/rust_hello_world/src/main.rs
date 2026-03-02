use serde::Deserialize;
use serde::Serialize;
use std::io::{self, Read};

#[derive(Deserialize)]
struct Payload {
    feature_count: Option<usize>,
}

#[derive(Serialize)]
struct Output<'a> {
    plugin_kind: &'a str,
    message: &'a str,
    features: usize,
}

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
    let payload: Payload = if input.trim().is_empty() {
        Payload { feature_count: Some(0) }
    } else {
        serde_json::from_str(&input).map_err(|e| format!("json parse failed: {e}"))?
    };
    let out = Output {
        plugin_kind: "hello_world",
        message: "Hello from Rust plugin",
        features: payload.feature_count.unwrap_or(0),
    };
    let json = serde_json::to_string(&out).map_err(|e| format!("serialize failed: {e}"))?;
    println!("{json}");
    Ok(())
}
