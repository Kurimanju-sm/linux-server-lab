#!/bin/bash

echo "=== Linux Log Check ==="

echo
echo "[1] Log directory"
du -sh /var/log

echo
echo "[2] Recent system logs"
journalctl -n 5 --no-pager

echo
echo "[3] SSH service logs"
journalctl -u ssh -n 5 --no-pager

echo
echo "[4] Recent error logs"
journalctl -p err -n 5 --no-pager

echo
echo "=== Check Complete ==="
