#!/bin/bash
set -e

echo "========================================"
echo "          SYSTEM CLEANUP START           "
echo "========================================"
echo

echo "[1/8] SMART USER CACHE CLEAN"
KEEP_CACHE=(
    ".mozilla/firefox"
    ".cache/google-chrome"
    ".cache/chromium"
)

for item in ~/.cache/*; do
    skip=false
    for keep in "${KEEP_CACHE[@]}"; do
        if [[ "$item" == "$HOME/$keep"* ]]; then
            skip=true
            break
        fi
    done

    if [ "$skip" = false ]; then
        rm -rf "$item" 2>/dev/null
        echo "Deleted: $item"
    else
        echo "Kept: $item"
    fi
done

rm -rf ~/.local/share/Trash/* 2>/dev/null
rm -rf ~/.thumbnails/* 2>/dev/null
echo

echo "[2/8] APT CLEANUP"
sudo apt clean
sudo apt autoclean
sudo apt autoremove -y
echo

echo "[3/8] SYSTEM LOG CLEANUP"
sudo journalctl --vacuum-time=3d
sudo find /var/log -type f -name "*.log*" -exec sudo rm -f {} \; 2>/dev/null
echo

if command -v snap >/dev/null 2>&1; then
    echo "[4/8] SNAP CLEANUP"
    sudo snap set system refresh.retain=2
    for snap_ver in $(snap list --all | awk '/disabled/{print $1, $2}' | awk '{print $1":"$2}'); do
        sudo snap remove --purge "${snap_ver%%:*}" 2>/dev/null || true
    done
    echo
fi

echo "[5/8] TEMP FILES"
sudo rm -rf /tmp/* 2>/dev/null
echo

echo "[6/8] SSD TRIM"
sync
sudo fstrim -av
echo

echo "[7/8] UPDATE FILE INDEX"
sudo updatedb
echo

echo "[8/8] DISK USAGE"
df -h /
echo

echo "========================================"
echo "          CLEANUP COMPLETE               "
echo "========================================"
