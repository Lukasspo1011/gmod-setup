#!/bin/bash

# === Konfiguration ===
CTID=120
HOSTNAME="gmod-server"
PASSWORD="gmodpass"
DISK_SIZE="10"  # in GB (ohne G)
MEMORY="2048"
CORES="2"
TEMPLATE="local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
STORAGE="local-lvm"
BRIDGE="vmbr0"
IP="dhcp"

echo "[INFO] Erstelle LXC Container $CTID ($HOSTNAME)..."

pct create $CTID $TEMPLATE \
  --hostname $HOSTNAME \
  --rootfs ${STORAGE}:${DISK_SIZE} \
  --cores $CORES \
  --memory $MEMORY \
  --net0 name=eth0,bridge=$BRIDGE,ip=$IP \
  --password $PASSWORD \
  --features nesting=1 \
  --unprivileged 1

echo "[INFO] Starte Container..."
pct start $CTID
sleep 5

echo "[INFO] Installiere benötigte Pakete im Container..."
pct exec $CTID -- apt update
pct exec $CTID -- apt install -y curl wget ca-certificates

echo "[INFO] Führe Installationsskript für Garry's Mod aus..."
pct exec $CTID -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/Lukasspo1011/gmod-setup/main/install.sh)"

echo "[DONE] Garry's Mod LXC Container wurde erfolgreich eingerichtet!"
