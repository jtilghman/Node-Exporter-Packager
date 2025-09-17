#!/bin/bash
set -euo pipefail

SERVICE="node_exporter"
PORT=9100

echo "[*] Checking Node Exporter installation..."

# 1. Check binary
if command -v node_exporter >/dev/null 2>&1; then
    echo "[OK] node_exporter binary is in PATH"
else
    echo "[FAIL] node_exporter binary not found in PATH"
    exit 1
fi

# 2. Check user
if id -u node_exporter >/dev/null 2>&1; then
    echo "[OK] node_exporter user exists"
else
    echo "[FAIL] node_exporter user missing"
    exit 1
fi

# 3. Check systemd unit file exists
if [ -f "/lib/systemd/system/${SERVICE}.service" ] || [ -f "/etc/systemd/system/${SERVICE}.service" ]; then
    echo "[OK] Systemd unit file exists"
else
    echo "[FAIL] Systemd unit file missing"
    exit 1
fi

# 4. Check service is active
if systemctl is-active --quiet "$SERVICE"; then
    echo "[OK] ${SERVICE} service is running"
else
    echo "[FAIL] ${SERVICE} service is not running"
    exit 1
fi

# 5. Check metrics endpoint
METRICS=$(curl -s "http://localhost:${PORT}/metrics" || true)
if echo "$METRICS" | grep -q "node_cpu_seconds_total"; then
    echo "[OK] Metrics endpoint is responding on :${PORT}"
else
    echo "[FAIL] Metrics endpoint not responding"
    exit 1
fi

echo "[*] Node Exporter installation and service test completed successfully."

