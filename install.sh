#!/bin/bash

set -e

# === Variablen ===
INSTALL_DIR="/opt/gmod"
STEAMCMD_DIR="/opt/steamcmd"
GMOD_APPID=4020

# === Root Check ===
if [[ $EUID -ne 0 ]]; then
  echo "Bitte als root ausführen!" 1>&2
  exit 1
fi

echo "[INFO] Starte Installation von Garry's Mod Server..."

# === Abhängigkeiten installieren ===
echo "[INFO] Installiere benötigte Pakete..."
apt update && apt install -y \
  lib32gcc-s1 \
  lib32stdc++6 \
  curl \
  wget \
  tar \
  ca-certificates \
  software-properties-common

# === SteamCMD herunterladen ===
echo "[INFO] Installiere SteamCMD..."
mkdir -p "$STEAMCMD_DIR"
cd "$STEAMCMD_DIR"
if [ ! -f steamcmd.sh ]; then
  wget https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
  tar -xvzf steamcmd_linux.tar.gz
  rm steamcmd_linux.tar.gz
fi

# === Garry's Mod installieren ===
echo "[INFO] Installiere Garry's Mod Server in $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"
"$STEAMCMD_DIR/steamcmd.sh" +login anonymous +force_install_dir "$INSTALL_DIR" +app_update "$GMOD_APPID" validate +quit

echo "[SUCCESS] Garry's Mod Server wurde erfolgreich installiert!"
