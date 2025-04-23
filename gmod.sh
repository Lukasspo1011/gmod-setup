#!/bin/bash

# --- KONFIGURATION ---
CTID=121                     # Neue Container-ID
VMID=121                     # VM-ID für die Containererstellung
TEMPLATE="debian-12-standard_12.7-1_amd64.tar.zst"   # Das Template, das du verwendest
DISK_SIZE="10G"              # Die Festplattengröße für den Container
RAM="1024"                   # RAM-Größe in MB (angepasst auf 1024 MB)
CPUS="2"                     # Anzahl der CPUs
NET="bridge=vmbr0,ip=dhcp"   # Netzwerkeinstellungen

# --- LXC CONTAINER ERSTELLEN ---
echo "[INFO] Erstelle LXC Container $CTID (gmod-server)..."
pct create $CTID /var/lib/vz/template/cache/$TEMPLATE \
  -disk $DISK_SIZE \
  -memory $RAM \
  -cores $CPUS \
  -net $NET \
  -hostname gmod-server \
  -password yourpassword123 \
  -rootfs local-lvm:10 \
  -swap 512

# --- CONTAINER STARTEN ---
echo "[INFO] Starte Container $CTID..."
pct start $CTID

# --- INSTALLATION VON GARRY'S MOD ---
echo "[INFO] Installiere Garry's Mod im Container..."

# Container anfragen
pct exec $CTID -- apt update && apt upgrade -y
pct exec $CTID -- apt install -y wget tmux lib32gcc-s1 lib32stdc++6

# Garry's Mod Installation
pct exec $CTID -- bash -c "cd /opt && wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz && tar -xvzf steamcmd_linux.tar.gz"
pct exec $CTID -- bash -c "/opt/steamcmd/steamcmd.sh +login anonymous +force_install_dir /opt/gmod +app_update 4020 validate +quit"

# --- FERTIGSTELLUNG ---
echo "[INFO] Garry's Mod LXC Container wurde erfolgreich eingerichtet!"
