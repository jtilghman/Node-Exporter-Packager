#!/bin/bash
set -euo pipefail

NODE_EXPORTER_VERSION="0.18.1"
ARCH="linux-amd64"
TARBALL="node_exporter.tar.gz"
EXTRACTED_DIR="node_exporter-${NODE_EXPORTER_VERSION}.${ARCH}"

echo "[*] Installing Node Exporter ${NODE_EXPORTER_VERSION}..."

# Extract tarball if directory doesn’t exist
if [ ! -d "$EXTRACTED_DIR" ]; then
    echo "[*] Extracting ${TARBALL}..."
    tar -xzf "$TARBALL"
fi

# Install binary
echo "[*] Copying binary to /usr/local/bin..."
sudo cp "${EXTRACTED_DIR}/node_exporter" /usr/local/bin/
sudo chown root:root /usr/local/bin/node_exporter
sudo chmod 0755 /usr/local/bin/node_exporter

# Create node_exporter user if it doesn't exist
if ! id -u node_exporter >/dev/null 2>&1; then
    echo "[*] Creating node_exporter user..."
    sudo useradd --no-create-home --shell /usr/sbin/nologin node_exporter
fi

# Systemd unit file
SERVICE_FILE="/etc/systemd/system/node_exporter.service"
if [ ! -f "$SERVICE_FILE" ]; then
    echo "[*] Creating systemd service file..."
    cat <<EOF | sudo tee "$SERVICE_FILE" > /dev/null
[Unit]
Description=Node Exporter
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
fi

# Reload and enable service
echo "[*] Reloading systemd..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now node_exporter

echo "[OK] Node Exporter installed and running"

