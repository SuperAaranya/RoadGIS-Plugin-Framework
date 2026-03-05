#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:?Usage: build_macos.sh /path/to/RoadGISPro_fresh}"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
DIST_DIR="$PROJECT_ROOT/dist/macos"
mkdir -p "$DIST_DIR"

python3 -m pip install --upgrade pyinstaller >/dev/null
pyinstaller --noconfirm --clean --windowed --name RoadGISPro "$PROJECT_ROOT/RoadGISPro.py"

APP_BUNDLE="$PROJECT_ROOT/dist/RoadGISPro.app"
cp -R "$APP_BUNDLE" "$DIST_DIR/RoadGISPro.app"

PKG_DIR="$DIST_DIR/pkgroot/Applications"
mkdir -p "$PKG_DIR"
cp -R "$APP_BUNDLE" "$PKG_DIR/RoadGISPro.app"

pkgbuild --root "$DIST_DIR/pkgroot" --identifier com.roadgis.pro --version 1.0.0 "$DIST_DIR/RoadGISPro.pkg"

echo "Built macOS artifacts:"
echo "  App: $DIST_DIR/RoadGISPro.app"
echo "  Pkg: $DIST_DIR/RoadGISPro.pkg"
echo "For Sonoma/Sequoia/Tahoe distribution, add codesign and notarization."
