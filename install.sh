#!/bin/bash
set -e

GREEN='\033[0;32m'
NC='\033[0m'

echo -e "${GREEN}[+] Starting VPS Deploy Bot installation...${NC}"

# Update system and install required packages
apt update -y && apt upgrade -y
apt install -y curl neofetch openssh-server git nano docker.io python3-pip

# Enable & restart Docker
systemctl restart docker
systemctl enable docker

# Clone repo (if not already cloned)
if [ ! -d "/opt/vps-deploy-bot" ]; then
    git clone https://github.com/hycroedev/vps-deploy-bot.git /opt/vps-deploy-bot
else
    echo "[*] Repo already exists, updating..."
    cd /opt/vps-deploy-bot && git pull
fi

cd /opt/vps-deploy-bot

# Install Python deps
pip install --upgrade pip
pip install discord.py docker psutil

# Build Docker images
docker build -t debian-vps -f Dockerfile.debian .
docker build -t ubuntu-vps -f Dockerfile.ubuntu .

# ==============================
# Ask user for bot configuration
# ==============================
echo -e "${GREEN}[?] Enter your Discord Bot Token:${NC}"
read BOT_TOKEN

echo -e "${GREEN}[?] Enter Logs Channel ID:${NC}"
read LOGS_CHANNEL

echo -e "${GREEN}[?] Enter Admin Channel ID:${NC}"
read ADMIN_CHANNEL

# Save values into a config file
cat > config.json <<EOF
{
  "token": "${BOT_TOKEN}",
  "logs_channel": "${LOGS_CHANNEL}",
  "admin_channel": "${ADMIN_CHANNEL}"
}
EOF

echo -e "${GREEN}[✓] Config saved to config.json${NC}"

# ==============================
# Optional: Auto-create systemd service
# ==============================
echo -e "${GREEN}[?] Do you want to run the bot as a service (y/n)?${NC}"
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

    systemctl daemon-reload
    systemctl enable vps-bot
    systemctl start vps-bot

    echo -e "${GREEN}[✓] Bot service created and started!${NC}"
    echo -e "Use: systemctl status vps-bot   # to check logs"
else
    echo -e "${GREEN}[i] To run manually: python3 bot.py${NC}"
fi

echo -e "${GREEN}[✓] Installation complete!${NC}"
