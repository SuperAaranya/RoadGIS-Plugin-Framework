#!/usr/bin/env bash
set -euo pipefail

PROJECT_ROOT="${1:?Usage: build_debian.sh /path/to/RoadGISPro_fresh}"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && pwd)"
DIST_DIR="$PROJECT_ROOT/dist/linux"
PKG_ROOT="$DIST_DIR/pkg-root"

mkdir -p "$DIST_DIR" "$PKG_ROOT/usr/local/bin" "$PKG_ROOT/DEBIAN"

python3 -m pip install --upgrade pyinstaller >/dev/null
pyinstaller --noconfirm --clean --name RoadGISPro --onefile "$PROJECT_ROOT/RoadGISPro.py"
cp "$PROJECT_ROOT/dist/RoadGISPro" "$PKG_ROOT/usr/local/bin/roadgispro"
chmod +x "$PKG_ROOT/usr/local/bin/roadgispro"

cat > "$PKG_ROOT/DEBIAN/control" <<EOF
Package: roadgispro
Version: 1.0.0
Section: utils
Priority: optional
Architecture: amd64
Maintainer: RoadGIS <support@example.com>
Description: RoadGIS Pro desktop application
EOF

dpkg-deb --build "$PKG_ROOT" "$DIST_DIR/roadgispro_1.0.0_amd64.deb"

echo "Built Debian package:"
echo "  $DIST_DIR/roadgispro_1.0.0_amd64.deb"
