#!/bin/bash

CTID=120
TEMPLATE="local:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
HOSTNAME="gmod-server"

pct create $CTID $TEMPLATE \
  --hostname $HOSTNAME \
  --cores 2 \
  --memory 2048 \
  --rootfs local-lvm:10 \
  --net0 name=eth0,bridge=vmbr0,ip=dhcp \
  --password gmodpass \
  --unprivileged 1 \
  --features nesting=1

pct start $CTID

sleep 5

pct exec $CTID -- apt update
pct exec $CTID -- apt install -y curl wget ca-certificates

pct exec $CTID -- bash -c "$(curl -fsSL https://raw.githubusercontent.com/lukasspo1011/gmod-setup/main/install.sh)"

echo "[DONE] Container wurde erstellt und GMod installiert."
