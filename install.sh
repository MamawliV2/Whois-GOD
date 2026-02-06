#!/bin/bash

#############################################
#  🌐 Whois Telegram Bot - Installation Script
#############################################

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║   🌐  Whois Domain Lookup Telegram Bot                        ║"
    echo "║       ربات تلگرام جستجوی اطلاعات دامنه                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_msg() { echo -e "${GREEN}[✓]${NC} $1"; }
print_info() { echo -e "${BLUE}[ℹ]${NC} $1"; }
print_warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Variables
TELEGRAM_BOT_TOKEN=""
WHOISFREAKS_API_KEY=""
DOMAIN=""
PANEL_PASSWORD="Amin@9579"

print_banner

echo -e "${CYAN}زبان / Language:${NC}"
echo "  1) فارسی"
echo "  2) English"
read -p "Select [1]: " lang_choice
lang_choice=${lang_choice:-1}

#############################################
# Get User Input
#############################################

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  دریافت اطلاعات / Getting Information${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Telegram Bot Token
echo -e "${CYAN}📱 Telegram Bot Token${NC}"
echo "   Get from @BotFather: https://t.me/BotFather"
while [ -z "$TELEGRAM_BOT_TOKEN" ]; do
    read -p "   Token: " TELEGRAM_BOT_TOKEN
done
print_msg "Token saved"

# WhoisFreaks API Key
echo ""
echo -e "${CYAN}🔑 WhoisFreaks API Key${NC}"
echo "   Get from: https://whoisfreaks.com"
while [ -z "$WHOISFREAKS_API_KEY" ]; do
    read -p "   API Key: " WHOISFREAKS_API_KEY
done
print_msg "API Key saved"

# Domain (Optional)
echo ""
echo -e "${CYAN}🌐 Domain for Web Panel (Optional)${NC}"
echo "   Leave empty to use localhost only"
read -p "   Domain (e.g., example.com): " DOMAIN

# Panel Password
echo ""
echo -e "${CYAN}🔐 Web Panel Password${NC}"
read -p "   Password [Amin@9579]: " input_password
if [ -n "$input_password" ]; then
    PANEL_PASSWORD="$input_password"
fi
print_msg "Password set"

#############################################
# Install Dependencies
#############################################

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  نصب وابستگی‌ها / Installing Dependencies${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Update system
print_info "Updating system..."
sudo apt-get update -y

# Install Python
print_info "Installing Python..."
sudo apt-get install -y python3 python3-pip python3-venv

# Install Node.js 18
print_info "Installing Node.js 18..."
if ! command -v node &> /dev/null || [[ $(node -v | cut -d. -f1 | tr -d 'v') -lt 18 ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    nvm install 18
    nvm use 18
fi
print_msg "Node.js installed: $(node -v)"

# Install MongoDB
print_info "Installing MongoDB..."
if ! command -v mongod &> /dev/null; then
    curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor --yes
    echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
    sudo apt-get update
    sudo apt-get install -y mongodb-org
fi
sudo systemctl start mongod || true
sudo systemctl enable mongod || true
print_msg "MongoDB installed and running"

# Install serve
print_info "Installing serve..."
npm install -g serve
print_msg "serve installed"

#############################################
# Setup Backend
#############################################

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  تنظیم Backend / Setting up Backend${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$SCRIPT_DIR/backend"

# Create .env
cat > .env <<EOF
MONGO_URL=mongodb://localhost:27017
DB_NAME=whois_bot
CORS_ORIGINS=*
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
WHOISFREAKS_API_KEY=$WHOISFREAKS_API_KEY
PANEL_PASSWORD=$PANEL_PASSWORD
EOF

print_msg "Backend .env created"

# Install Python dependencies
print_info "Installing Python dependencies..."
pip3 install -r requirements.txt
print_msg "Python dependencies installed"

#############################################
# Setup Frontend
#############################################

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  تنظیم Frontend / Setting up Frontend${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

cd "$SCRIPT_DIR/frontend"

# Set backend URL
if [ -n "$DOMAIN" ]; then
    BACKEND_URL="https://$DOMAIN"
else
    BACKEND_URL="http://localhost:8001"
fi

cat > .env <<EOF
REACT_APP_BACKEND_URL=$BACKEND_URL
REACT_APP_PANEL_PASSWORD=$PANEL_PASSWORD
EOF

print_msg "Frontend .env created"

# Install and build
print_info "Installing Node dependencies..."
npm install
print_msg "Node dependencies installed"

print_info "Building frontend..."
npm run build
print_msg "Frontend built"

#############################################
# Setup Nginx & SSL (if domain provided)
#############################################

if [ -n "$DOMAIN" ]; then
    echo ""
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${YELLOW}  تنظیم Nginx و SSL / Setting up Nginx & SSL${NC}"
    echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""

    # Install Nginx
    print_info "Installing Nginx..."
    sudo apt-get install -y nginx
    print_msg "Nginx installed"

    # Create Nginx config
    print_info "Configuring Nginx..."
    sudo tee /etc/nginx/sites-available/$DOMAIN > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF

    sudo ln -sf /etc/nginx/sites-available/$DOMAIN /etc/nginx/sites-enabled/
    sudo rm -f /etc/nginx/sites-enabled/default
    sudo nginx -t && sudo systemctl restart nginx
    print_msg "Nginx configured"

    # Install SSL with Certbot
    print_info "Installing SSL certificate..."
    sudo apt-get install -y certbot python3-certbot-nginx
    
    echo ""
    read -p "Enter email for SSL certificate: " SSL_EMAIL
    
    sudo certbot --nginx -d $DOMAIN --non-interactive --agree-tos --email $SSL_EMAIL || {
        print_warn "SSL auto-install failed. Run manually: sudo certbot --nginx -d $DOMAIN"
    }
    print_msg "SSL configured"
fi

#############################################
# Create Systemd Services
#############################################

echo ""
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}  ایجاد سرویس‌ها / Creating Services${NC}"
echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Backend service
sudo tee /etc/systemd/system/whois-backend.service > /dev/null <<EOF
[Unit]
Description=Whois Bot Backend
After=network.target mongod.service

[Service]
Type=simple
User=root
WorkingDirectory=$SCRIPT_DIR/backend
ExecStart=/usr/bin/python3 -m uvicorn server:app --host 0.0.0.0 --port 8001
Restart=always
RestartSec=10
Environment=PATH=/usr/bin:/usr/local/bin

[Install]
WantedBy=multi-user.target
EOF

# Frontend service
sudo tee /etc/systemd/system/whois-frontend.service > /dev/null <<EOF
[Unit]
Description=Whois Bot Frontend
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=$SCRIPT_DIR/frontend
ExecStart=/usr/bin/npx serve -s build -l 3000
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl enable whois-backend whois-frontend
sudo systemctl start whois-backend whois-frontend

print_msg "Services created and started"

#############################################
# Final Output
#############################################

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║   ✅  Installation completed successfully!                    ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}📱 Telegram Bot:${NC} Active - Send /start"
echo ""
echo -e "${CYAN}🖥️  Web Dashboard:${NC}"
if [ -n "$DOMAIN" ]; then
    echo "   https://$DOMAIN"
else
    echo "   http://localhost:3000"
fi
echo ""
echo -e "${CYAN}🔐 Panel Password:${NC} $PANEL_PASSWORD"
echo ""
echo -e "${CYAN}⚙️  Service Commands:${NC}"
echo "   sudo systemctl status whois-backend"
echo "   sudo systemctl status whois-frontend"
echo "   sudo systemctl restart whois-backend"
echo "   sudo systemctl restart whois-frontend"
echo ""
echo -e "${CYAN}📋 Logs:${NC}"
echo "   sudo journalctl -u whois-backend -f"
echo "   sudo journalctl -u whois-frontend -f"
echo ""
echo -e "${GREEN}Thank you for using Whois Bot! 🙏${NC}"
