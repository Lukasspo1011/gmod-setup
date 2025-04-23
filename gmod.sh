#!/bin/bash

# === Konfiguration ===
CTID=120
HOSTNAME="gmod-server"
PASSWORD="gmodpass"
DISK_SIZE="10G"
MEMORY="2048"
CORES="2"
TEMPLATE="debian-12-standard_*.tar.zst"  # oder ubuntu-22.04-standard_*.tar.zst
STORAGE="local-lvm"  # oder dein gewünschter Storage
BRIDGE="vmbr0"
IP="dhcp"  # oder statisch: 192.168.x.x/24,gw=192.168.x.1

# === LXC Container erstellen ===
echo "[INFO] Erstelle LXC Container $CTID ($HOSTNAME)..."
pct create $CTID $(pveam available | grep $TEMPLATE | awk '{print $1}') \
  --hostname $HOSTNAME \
  --storage $STORAGE \
  --rootfs $DISK_SIZE \
  --cores $CORES \
  --memory $MEMORY \
  --net0 name=eth0,bridge=$BRIDGE,ip=$IP \
  --password $PASSWORD \
  --features nesting=1 \
  --unprivileged 1

# === Container starten ===
pct start $CTID
sleep 5

# === Installationsbefehl im Container ausführen ===
echo "[INFO] Installiere Garry's Mod im Container..."
pct exec $CTID -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/dein-user/gmod-lxc/main/install.sh)"

echo "[DONE] Garry's Mod LXC Container wurde erfolgreich eingerichtet!"
