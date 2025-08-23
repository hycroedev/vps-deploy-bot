#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

clear
echo -e "${CYAN}"
echo "╔═══════════════════════════════════════╗"
echo "║      VPS Deploy Bot Installer 🚀      ║"
echo "║         Script by HycroeDev           ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"
sleep 2

# Spinner function
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

run_cmd() {
    echo -ne "${YELLOW}[~] $1...${NC}"
    bash -c "$2" >/dev/null 2>&1 &
    spinner $!
    echo -e "${GREEN} [OK]${NC}"
}

# ==============================
# Installation Steps
# ==============================
run_cmd "Updating system" "apt update -y && apt upgrade -y"
run_cmd "Installing dependencies" "apt install -y curl neofetch openssh-server git nano docker.io python3-pip"

run_cmd "Restarting Docker" "systemctl restart docker"
run_cmd "Enabling Docker" "systemctl enable docker"

if [ ! -d "/opt/vps-deploy-bot" ]; then
    run_cmd "Cloning repository" "git clone https://github.com/hycroedev/vps-deploy-bot.git /opt/vps-deploy-bot"
else
    run_cmd "Updating repository" "cd /opt/vps-deploy-bot && git pull"
fi

cd /opt/vps-deploy-bot
run_cmd "Installing Python modules" "pip install --upgrade pip && pip install discord.py docker psutil"

run_cmd "Building Debian Docker image" "docker build -t debian-vps -f Dockerfile.debian ."
run_cmd "Building Ubuntu Docker image" "docker build -t ubuntu-vps -f Dockerfile.ubuntu ."

# ==============================
# User Config
# ==============================
echo -e "${CYAN}\n[?] Enter your Discord Bot Token:${NC}"
read BOT_TOKEN

echo -e "${CYAN}[?] Enter Logs Channel ID:${NC}"
read LOGS_CHANNEL

echo -e "${CYAN}[?] Enter Admin Role ID:${NC}"
read ADMIN_ROLE

# Auto-edit bot.py
run_cmd "Configuring bot.py" \
"sed -i \"s|^TOKEN = .*|TOKEN = '${BOT_TOKEN}'  # BOT TOKEN|\" bot.py && \
 sed -i \"s|^RAM_LIMIT = .*|RAM_LIMIT = '2g'|\" bot.py && \
 sed -i \"s|^SERVER_LIMIT = .*|SERVER_LIMIT = 12|\" bot.py && \
 sed -i \"s|^LOGS_CHANNEL_ID = .*|LOGS_CHANNEL_ID = ${LOGS_CHANNEL}    # LOGS CHANNEL|\" bot.py && \
 sed -i \"s|^ADMIN_ROLE_ID = .*|ADMIN_ROLE_ID = ${ADMIN_ROLE}     # ADMIN ROLE|\" bot.py"

# ==============================
# Service Setup
# ==============================
echo -e "${CYAN}\n[?] Do you want to run the bot as a service (y/n)?${NC}"
read RUN_SERVICE

if [[ "$RUN_SERVICE" == "y" ]]; then
    cat > /etc/systemd/system/vps-bot.service <<SERVICE
[Unit]
Description=VPS Deploy Discord Bot
After=network.target

[Service]
WorkingDirectory=/opt/vps-deploy-bot
ExecStart=/usr/bin/python3 /opt/vps-deploy-bot/bot.py
Restart=always
Environment=PYTHONUNBUFFERED=1

[Install]
WantedBy=multi-user.target
SERVICE

    run_cmd "Enabling bot service" "systemctl daemon-reload && systemctl enable vps-bot && systemctl start vps-bot"
    echo -e "${GREEN}[✓] Bot service created and started!${NC}"
    echo -e "${YELLOW}Check logs with: systemctl status vps-bot${NC}"
else
    echo -e "${YELLOW}[i] To run manually: cd /opt/vps-deploy-bot && python3 bot.py${NC}"
fi

# ==============================
# Done
# ==============================
echo -e "${GREEN}"
echo "╔═══════════════════════════════════════╗"
echo "║  Installation Complete! 🚀            ║"
echo "║  Script made with ❤️ by HycroeDev     ║"
echo "╚═══════════════════════════════════════╝"
echo -e "${NC}"
