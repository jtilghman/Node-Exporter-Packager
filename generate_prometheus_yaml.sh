#!/bin/bash

# Script: generate_prometheus_yaml.sh
# Purpose: Collect Linux host info and produce YAML for Prometheus static_configs

# Exit on error
set -e

# Get hostname
HOSTNAME=$(hostname)

# Get primary IP address (IPv4)
IP_ADDR=$(hostname -I | awk '{print $1}')

# Get OS info
OS_NAME=$(grep '^NAME=' /etc/os-release | cut -d= -f2 | tr -d '"')
OS_VERSION=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')

# Get kernel version
KERNEL=$(uname -r)

# Default Prometheus scrape port for node_exporter
PORT=9100

# Output YAML
cat <<EOF
# Prometheus target entry for host: $HOSTNAME
- job_name: 'node_exporter_$HOSTNAME'
  static_configs:
    - targets: ['$IP_ADDR:$PORT']
      labels:
        hostname: '$HOSTNAME'
        os: '$OS_NAME'
        os_version: '$OS_VERSION'
        kernel: '$KERNEL'
EOF

