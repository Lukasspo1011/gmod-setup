#!/bin/bash

# Garry's Mod Installer für Proxmox CT/VM
# Erstellt von ChatGPT für dich ;)

# =========================
# Variablen
# =========================
STEAMCMD_DIR="$HOME/steamcmd"
GARRYSMOD_DIR="$HOME/gmod_server"
APP_ID=4020
WORKSHOP_COLLECTION_ID="123456789" # <-- Ändern!
GSLT="" # <-- Optional: Steam Game Server Login Token

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
# Startskript
# =========================
cat <<EOF > "$GARRYSMOD_DIR/start_gmod.sh"
#!/bin/bash
cd "$(dirname "\$0")"
screen -dmS gmod ./srcds_run -game garrysmod +maxplayers 12 +map gm_flatgrass +gamemode sandbox -authkey "$GSLT"
EOF
chmod +x "$GARRYSMOD_DIR/start_gmod.sh"

echo "[✓] Garry's Mod Server ist installiert!"
echo "Starte ihn mit:"
echo "    $GARRYSMOD_DIR/start_gmod.sh"
