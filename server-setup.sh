#!/bin/bash

CONFIG_FILE="config/settings.conf"
LOGFILE="logs/server_setup.log"

source "$CONFIG_FILE"

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

log() {
    echo -e "$1"
    echo "$(date) : $1" >> "$LOGFILE"
}

error_exit(){
    log "${RED}[ERROR] $1 ${NC}"
    exit 1
}
if [ "$EUID" -ne 0 ];
 then error_exit "run this script as root!"
fi
log "${GREEN}Starting provisining...${NC}"
apt update -y || error_exit "update failed"
apt upgrade -y || error_exit "upgrade failed"
if id "$USERNAME" &>/dev/null; then
log "User already exists"
else
     useradd -m "$USERNAME" || error_exit "user creation failed"
      echo "$USERNAME:password123" | chpasswd
      usermod -aG sudo "$USERNAME"
      log "User created"
fi
apt install nginx -y || error_exit "nginx install failed"
systemctl enable nginx
systemctl start nginx
log "Nginx Installed"

apt install ufw -y
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw --force enable
log "firewall configured"

log "${GREEN}provisioning completed Successfully${NC}"
exit 0
