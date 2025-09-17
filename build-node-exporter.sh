#!/bin/bash
set -euo pipefail

# -------------------------------
# Config
# -------------------------------
URL="${1:-https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz}"
PKGNAME="node-exporter"
WORKDIR="$(pwd)/build-node-exporter"
ARCH="amd64"

# -------------------------------
# Download & extract
# -------------------------------
rm -rf "$WORKDIR"
mkdir -p "$WORKDIR"
cd "$WORKDIR"

echo "[*] Downloading $URL"
wget -q "$URL" -O node_exporter.tar.gz

echo "[*] Extracting tarball"
tar xzf node_exporter.tar.gz
EXTRACTED_DIR="$(tar tzf node_exporter.tar.gz | head -1 | cut -f1 -d"/")"

VERSION="$(echo "$EXTRACTED_DIR" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')"

# -------------------------------
# Debian package root
# -------------------------------
PKGDIR="$WORKDIR/${PKGNAME}_${VERSION}"
rm -rf "$PKGDIR"
mkdir -p "$PKGDIR/DEBIAN"
mkdir -p "$PKGDIR/usr/local/bin"
mkdir -p "$PKGDIR/lib/systemd/system"

# Copy binary into packaging dir
cp "$EXTRACTED_DIR/node_exporter" "$PKGDIR/usr/local/bin/"

# -------------------------------
# Control file
# -------------------------------
cat > "$PKGDIR/DEBIAN/control" <<EOF
Package: $PKGNAME
Version: $VERSION
Section: utils
Priority: optional
Architecture: $ARCH
Depends: adduser
Maintainer: Your Name <you@example.com>
Description: Prometheus Node Exporter
 A Prometheus exporter for machine metrics.
EOF

# -------------------------------
# Maintainer scripts
# -------------------------------
cat > "$PKGDIR/DEBIAN/postinst" <<'EOF'
#!/bin/bash
set -e
if ! id -u node_exporter >/dev/null 2>&1; then
    adduser --system --no-create-home --shell /usr/sbin/nologin \
            --group --disabled-login node_exporter
fi
systemctl daemon-reload || true
systemctl enable node_exporter.service >/dev/null 2>&1 || true
EOF
chmod 755 "$PKGDIR/DEBIAN/postinst"

cat > "$PKGDIR/DEBIAN/prerm" <<'EOF'
#!/bin/bash
set -e
if [ "$1" = "remove" ]; then
    systemctl stop node_exporter.service >/dev/null 2>&1 || true
    systemctl disable node_exporter.service >/dev/null 2>&1 || true
fi
EOF
chmod 755 "$PKGDIR/DEBIAN/prerm"

cat > "$PKGDIR/DEBIAN/postrm" <<'EOF'
#!/bin/bash
set -e
if [ "$1" = "purge" ]; then
    deluser --system node_exporter >/dev/null 2>&1 || true
    delgroup node_exporter >/dev/null 2>&1 || true
fi
EOF
chmod 755 "$PKGDIR/DEBIAN/postrm"

# -------------------------------
# Systemd service
# -------------------------------
cat > "$PKGDIR/lib/systemd/system/node_exporter.service" <<EOF
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOF

# -------------------------------
# Build .deb
# -------------------------------
DEBFILE="${PKGNAME}_${VERSION}_${ARCH}.deb"
dpkg-deb --build "$PKGDIR" "$DEBFILE"

echo "[*] Package built: $WORKDIR/$DEBFILE"

