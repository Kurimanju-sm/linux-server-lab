#!/bin/bash

echo "=== SSH Server Check ==="

echo
echo "[1] SSH service"

if systemctl is-active --quiet ssh; then
    echo "[OK] ssh.service is active"
else
    echo "[WARNING] ssh.service is inactive"
fi

echo
echo "[2] SSH socket"

if systemctl is-active --quiet ssh.socket; then
    echo "[OK] ssh.socket is active"
else
    echo "[WARNING] ssh.socket is inactive"
fi

echo
echo "[3] Port 22"

if ss -tln | grep -q ':22'; then
    echo "[OK] TCP 22 is listening"
else
    echo "[ERROR] TCP 22 is not listening"
fi

echo
echo "=== Check Complete ==="
