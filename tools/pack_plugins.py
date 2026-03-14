#!/usr/bin/env python3
import argparse
import os
import zipfile


def parse_args():
    ap = argparse.ArgumentParser(description="Pack plugins + manifests into a single zip")
    ap.add_argument("--framework", default=os.path.abspath(os.path.join(os.path.dirname(__file__), "..")),
                    help="Path to RoadGIS-Plugin-Framework root")
    ap.add_argument("--out", required=True, help="Output zip path")
    ap.add_argument("--ids", default="", help="Comma-separated plugin ids (default: all)")
    return ap.parse_args()


def main():
    args = parse_args()
    root = os.path.abspath(args.framework)
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

    with zipfile.ZipFile(args.out, "w", zipfile.ZIP_DEFLATED) as zf:
        for pid in ids:
            src_plugin = os.path.join(plugins_dir, pid)
            src_manifest = os.path.join(manifests_dir, f"{pid}.json")
            if not os.path.isdir(src_plugin):
                raise SystemExit(f"Plugin folder missing: {src_plugin}")
            if not os.path.isfile(src_manifest):
                raise SystemExit(f"Manifest missing: {src_manifest}")
            for root_dir, _, files in os.walk(src_plugin):
                for name in files:
                    full = os.path.join(root_dir, name)
                    rel = os.path.relpath(full, root)
                    zf.write(full, rel)
            zf.write(src_manifest, os.path.relpath(src_manifest, root))

    print(f"Packed {len(ids)} plugin(s) -> {args.out}")


if __name__ == "__main__":
    main()
