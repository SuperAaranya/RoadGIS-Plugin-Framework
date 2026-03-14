#!/usr/bin/env python3
import argparse
import hashlib
import json
import os
import zipfile
from datetime import datetime, timezone


def parse_args():
    ap = argparse.ArgumentParser(description="Build docs/plugins.json and pack zips for GitHub Pages")
    ap.add_argument("--framework", default=os.path.abspath(os.path.join(os.path.dirname(__file__), "..")),
                    help="Path to RoadGIS-Plugin-Framework root")
    ap.add_argument("--out", default="docs", help="Output docs directory (default: docs)")
    ap.add_argument("--ids", default="", help="Comma-separated plugin ids (default: all)")
    return ap.parse_args()


def sha256_file(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        while True:
            chunk = f.read(8192)
            if not chunk:
                break
            h.update(chunk)
    return h.hexdigest()


def pack_plugin(root, plugin_id, out_dir):
    plugins_dir = os.path.join(root, "plugins")
    manifests_dir = os.path.join(root, "manifests")
    src_plugin = os.path.join(plugins_dir, plugin_id)
    src_manifest = os.path.join(manifests_dir, f"{plugin_id}.json")
    if not os.path.isdir(src_plugin):
        raise SystemExit(f"Plugin folder missing: {src_plugin}")
    if not os.path.isfile(src_manifest):
        raise SystemExit(f"Manifest missing: {src_manifest}")
    pack_name = f"{plugin_id}.zip"
    pack_path = os.path.join(out_dir, pack_name)
    with zipfile.ZipFile(pack_path, "w", zipfile.ZIP_DEFLATED) as zf:
        for root_dir, _, files in os.walk(src_plugin):
            for name in files:
                full = os.path.join(root_dir, name)
                rel = os.path.relpath(full, root)
                zf.write(full, rel)
        zf.write(src_manifest, os.path.relpath(src_manifest, root))
    return pack_path


def main():
    args = parse_args()
    root = os.path.abspath(args.framework)
    docs_dir = os.path.abspath(os.path.join(root, args.out))
    packs_dir = os.path.join(docs_dir, "packs")
    os.makedirs(packs_dir, exist_ok=True)

    plugins_dir = os.path.join(root, "plugins")
    manifests_dir = os.path.join(root, "manifests")
    if not os.path.isdir(plugins_dir):
        raise SystemExit(f"Missing plugins folder: {plugins_dir}")
    if not os.path.isdir(manifests_dir):
        raise SystemExit(f"Missing manifests folder: {manifests_dir}")

    if args.ids.strip():
        ids = [p.strip() for p in args.ids.split(",") if p.strip()]
    else:
        ids = sorted([p for p in os.listdir(plugins_dir) if os.path.isdir(os.path.join(plugins_dir, p))])

    entries = []
    for pid in ids:
        manifest_path = os.path.join(manifests_dir, f"{pid}.json")
        if not os.path.isfile(manifest_path):
            continue
        with open(manifest_path, "r", encoding="utf-8") as f:
            manifest = json.load(f)
        pack_path = pack_plugin(root, pid, packs_dir)
        compat = manifest.get("compatibility") if isinstance(manifest.get("compatibility"), dict) else {}
        tags = manifest.get("tags", [])
        if not isinstance(tags, list):
            tags = []
        entries.append({
            "id": pid,
            "name": manifest.get("name", pid),
            "description": manifest.get("description", ""),
            "language": str(manifest.get("language", "")).lower(),
            "version": manifest.get("version", "1.0.0"),
            "tags": tags,
            "pack_url": f"packs/{os.path.basename(pack_path)}",
            "homepage": manifest.get("homepage", ""),
            "min_app_version": manifest.get("min_app_version") or compat.get("min_app_version", ""),
            "max_app_version": manifest.get("max_app_version") or compat.get("max_app_version", ""),
            "sha256": sha256_file(pack_path),
            "size_bytes": os.path.getsize(pack_path),
        })

    payload = {
        "schema": 1,
        "library": "RoadGIS Plugin Library",
        "generated_at": datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ"),
        "source": "RoadGIS-Plugin-Framework",
        "plugins": entries,
    }
    out_json = os.path.join(docs_dir, "plugins.json")
    with open(out_json, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2)
    print(f"Wrote {out_json} with {len(entries)} plugins.")


if __name__ == "__main__":
    main()
