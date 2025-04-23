#!/bin/bash

# =========================
# Variablen
# =========================
STEAMCMD_DIR="$HOME/steamcmd"
GARRYSMOD_DIR="$HOME/gmod_server"
APP_ID=4020
WORKSHOP_COLLECTION_ID="123456789" # <-- Ändern!
GSLT="" # <-- Optional: Steam Game Server Login Token

# RAM-Größe für den Server (1 GB = 1024 MB)
RAM_SIZE="1024"  # In MB, hier 1GB RAM

# Proxmox CT-Name und ID
CT_NAME="gmod-server"
CT_ID="100"  # <-- Container-ID (wählbar)

# =========================
# Proxmox Container erstellen (optional)
# =========================
echo "[+] Erstelle Proxmox Container $CT_ID mit $RAM_SIZE MB RAM..."
pct create $CT_ID /var/lib/vz/template/cache/ubuntu-20.04-standard_20.04-1_amd64.tar.gz \
    -hostname $CT_NAME \
    -memory $RAM_SIZE \
    -cores 2 \
    -swap 512 \
    -net0 name=eth0,bridge=vmbr0,ip=dhcp \
    -rootfs local-lvm:8 \
    -password "changeme" \
    -start 1

# =========================
# Abhängigkeiten installieren
# =========================
echo "[+] Installiere Abhängigkeiten..."
sudo apt update
sudo apt install -y lib32gcc-s1 lib32stdc++6 steamcmd screen curl unzip ca-certificates

# =========================
# SteamCMD Setup
# =========================
echo "[+] Installiere SteamCMD..."
mkdir -p "$STEAMCMD_DIR"
cd "$STEAMCMD_DIR"
wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
tar -xvzf steamcmd_linux.tar.gz

# =========================
# Garry's Mod Server installieren
# =========================
echo "[+] Installiere Garry's Mod Server..."
mkdir -p "$GARRYSMOD_DIR"
"$STEAMCMD_DIR/steamcmd.sh" +login anonymous +force_install_dir "$GARRYSMOD_DIR" +app_update $APP_ID validate +quit

# =========================
# ULX & ULib installieren
# =========================
echo "[+] Lade ULX & ULib..."
cd "$GARRYSMOD_DIR/garrysmod/addons"
git clone https://github.com/TeamUlysses/ulib.git
git clone https://github.com/TeamUlysses/ulx.git

# =========================
# server.cfg erstellen
# =========================
echo "[+] Erstelle server.cfg..."
cat <<EOF > "$GARRYSMOD_DIR/garrysmod/cfg/server.cfg"
hostname "Mein GMod Server"
sv_lan 0
rcon_password "changeme123"
sv_region 255
language "german"
host_workshop_collection $WORKSHOP_COLLECTION_ID
sv_workshop_allow_other_maps 1
EOF

# =========================
# Startskript erstellen
# =========================
cat <<EOF > "$GARRYSMOD_DIR/start_gmod.sh"
#!/bin/bash
cd "$(dirname "\$0")"
screen -dmS gmod ./srcds_run -game garrysmod +maxplayers 12 +map gm_flatgrass +gamemode sandbox -authkey "$GSLT"
EOF
chmod +x "$GARRYSMOD_DIR/start_gmod.sh"

# =========================
# Fertigstellung
# =========================
echo "[✓] Garry's Mod Server ist installiert und der Container $CT_ID wurde erstellt!"
echo "Starte den Server mit:"
echo "    $GARRYSMOD_DIR/start_gmod.sh"
echo
echo "[✓] Der Proxmox Container $CT_ID wurde erfolgreich erstellt und konfiguriert!"
echo "[+] Der Container kann über Proxmox gestartet werden: pct start $CT_ID"
