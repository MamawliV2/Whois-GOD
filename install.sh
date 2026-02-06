#!/bin/bash

#############################################
#  🌐 Whois Telegram Bot - Installation Script
#  نصب‌کننده ربات Whois تلگرام
#############################################

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
print_banner() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                                                               ║"
    echo "║   🌐  Whois Domain Lookup Telegram Bot                        ║"
    echo "║       ربات تلگرام جستجوی اطلاعات دامنه                        ║"
    echo "║                                                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print colored message
print_msg() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[ℹ]${NC} $1"
}

print_warn() {
    echo -e "${YELLOW}[⚠]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_step() {
    echo ""
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${PURPLE}  $1${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Variables
TELEGRAM_BOT_TOKEN=""
WHOISFREAKS_API_KEY=""
MONGO_URL="mongodb://localhost:27017"
DB_NAME="whois_bot"
BACKEND_PORT="8001"
FRONTEND_PORT="3000"
DOMAIN=""
USE_NGINX=""
USE_SSL=""

#############################################
# Main Installation
#############################################

main() {
    print_banner
    
    echo -e "${CYAN}زبان / Language:${NC}"
    echo "  1) فارسی"
    echo "  2) English"
    echo ""
    read -p "انتخاب / Select [1]: " lang_choice
    lang_choice=${lang_choice:-1}
    
    if [ "$lang_choice" == "1" ]; then
        install_persian
    else
        install_english
    fi
}

#############################################
# Persian Installation
#############################################

install_persian() {
    print_step "مرحله 1: بررسی پیش‌نیازها"
    check_requirements_fa
    
    print_step "مرحله 2: دریافت اطلاعات"
    get_user_input_fa
    
    print_step "مرحله 3: نصب وابستگی‌ها"
    install_dependencies
    
    print_step "مرحله 4: تنظیم فایل‌های محیطی"
    setup_env_files
    
    print_step "مرحله 5: تنظیم دامنه (اختیاری)"
    setup_domain_fa
    
    print_step "مرحله 6: راه‌اندازی سرویس‌ها"
    start_services_fa
    
    print_final_fa
}

check_requirements_fa() {
    print_info "در حال بررسی پیش‌نیازها..."
    
    local missing=()
    
    if ! command_exists python3; then
        missing+=("Python 3")
    else
        print_msg "Python 3 نصب شده"
    fi
    
    if ! command_exists node; then
        missing+=("Node.js")
    else
        print_msg "Node.js نصب شده"
    fi
    
    if ! command_exists yarn; then
        if command_exists npm; then
            print_warn "yarn نصب نیست، در حال نصب..."
            npm install -g yarn
        else
            missing+=("Yarn/NPM")
        fi
    else
        print_msg "Yarn نصب شده"
    fi
    
    if ! command_exists mongod && ! command_exists mongo; then
        print_warn "MongoDB نصب نیست - می‌توانید از MongoDB Atlas استفاده کنید"
    else
        print_msg "MongoDB نصب شده"
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_error "موارد زیر نصب نیستند:"
        for item in "${missing[@]}"; do
            echo "  - $item"
        done
        echo ""
        print_info "لطفاً ابتدا این موارد را نصب کنید."
        exit 1
    fi
    
    print_msg "همه پیش‌نیازها موجود هستند!"
}

get_user_input_fa() {
    echo -e "${CYAN}لطفاً اطلاعات زیر را وارد کنید:${NC}"
    echo ""
    
    # Telegram Bot Token
    echo -e "${YELLOW}📱 توکن ربات تلگرام${NC}"
    echo "   از @BotFather در تلگرام دریافت کنید"
    echo "   https://t.me/BotFather"
    echo ""
    while [ -z "$TELEGRAM_BOT_TOKEN" ]; do
        read -p "   توکن ربات: " TELEGRAM_BOT_TOKEN
        if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
            print_error "توکن ربات الزامی است!"
        fi
    done
    print_msg "توکن ربات ذخیره شد"
    echo ""
    
    # WhoisFreaks API Key
    echo -e "${YELLOW}🔑 کلید API از WhoisFreaks${NC}"
    echo "   از https://whoisfreaks.com دریافت کنید"
    echo ""
    while [ -z "$WHOISFREAKS_API_KEY" ]; do
        read -p "   کلید API: " WHOISFREAKS_API_KEY
        if [ -z "$WHOISFREAKS_API_KEY" ]; then
            print_error "کلید API الزامی است!"
        fi
    done
    print_msg "کلید API ذخیره شد"
    echo ""
    
    # MongoDB URL
    echo -e "${YELLOW}🗄️ آدرس MongoDB${NC}"
    echo "   پیش‌فرض: mongodb://localhost:27017"
    echo ""
    read -p "   آدرس MongoDB [Enter برای پیش‌فرض]: " input_mongo
    if [ -n "$input_mongo" ]; then
        MONGO_URL="$input_mongo"
    fi
    print_msg "آدرس MongoDB: $MONGO_URL"
    echo ""
    
    # Database Name
    echo -e "${YELLOW}📁 نام دیتابیس${NC}"
    echo "   پیش‌فرض: whois_bot"
    echo ""
    read -p "   نام دیتابیس [Enter برای پیش‌فرض]: " input_db
    if [ -n "$input_db" ]; then
        DB_NAME="$input_db"
    fi
    print_msg "نام دیتابیس: $DB_NAME"
    echo ""
    
    # Backend Port
    echo -e "${YELLOW}🔌 پورت Backend${NC}"
    echo "   پیش‌فرض: 8001"
    echo ""
    read -p "   پورت Backend [Enter برای پیش‌فرض]: " input_backend_port
    if [ -n "$input_backend_port" ]; then
        BACKEND_PORT="$input_backend_port"
    fi
    print_msg "پورت Backend: $BACKEND_PORT"
    echo ""
    
    # Frontend Port
    echo -e "${YELLOW}🖥️ پورت Frontend${NC}"
    echo "   پیش‌فرض: 3000"
    echo ""
    read -p "   پورت Frontend [Enter برای پیش‌فرض]: " input_frontend_port
    if [ -n "$input_frontend_port" ]; then
        FRONTEND_PORT="$input_frontend_port"
    fi
    print_msg "پورت Frontend: $FRONTEND_PORT"
}

setup_domain_fa() {
    echo -e "${CYAN}آیا می‌خواهید داشبورد روی یک دامنه اجرا شود؟${NC}"
    echo "  1) بله، می‌خواهم دامنه تنظیم کنم"
    echo "  2) خیر، فقط روی localhost اجرا شود"
    echo ""
    read -p "انتخاب [2]: " domain_choice
    domain_choice=${domain_choice:-2}
    
    if [ "$domain_choice" == "1" ]; then
        echo ""
        read -p "نام دامنه (مثال: whois.example.com): " DOMAIN
        
        if [ -n "$DOMAIN" ]; then
            echo ""
            echo -e "${CYAN}آیا می‌خواهید SSL (HTTPS) تنظیم شود؟${NC}"
            echo "  1) بله، با Let's Encrypt"
            echo "  2) خیر، فقط HTTP"
            echo ""
            read -p "انتخاب [1]: " ssl_choice
            ssl_choice=${ssl_choice:-1}
            
            if [ "$ssl_choice" == "1" ]; then
                USE_SSL="yes"
            fi
            
            setup_nginx_fa
        fi
    else
        print_info "داشبورد روی http://localhost:$FRONTEND_PORT در دسترس خواهد بود"
    fi
}

setup_nginx_fa() {
    if ! command_exists nginx; then
        print_warn "Nginx نصب نیست. آیا می‌خواهید نصب شود؟ (y/n)"
        read -p "انتخاب: " install_nginx
        if [ "$install_nginx" == "y" ]; then
            if command_exists apt-get; then
                sudo apt-get update && sudo apt-get install -y nginx
            elif command_exists yum; then
                sudo yum install -y nginx
            else
                print_error "لطفاً Nginx را به صورت دستی نصب کنید"
                return
            fi
        else
            return
        fi
    fi
    
    print_info "در حال تنظیم Nginx..."
    
    # Create Nginx config
    NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
    
    if [ "$USE_SSL" == "yes" ]; then
        # Install certbot if needed
        if ! command_exists certbot; then
            print_info "در حال نصب Certbot..."
            if command_exists apt-get; then
                sudo apt-get install -y certbot python3-certbot-nginx
            elif command_exists yum; then
                sudo yum install -y certbot python3-certbot-nginx
            fi
        fi
        
        # Create basic config first
        sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$FRONTEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:$BACKEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
        
        # Enable site
        sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
        sudo nginx -t && sudo systemctl reload nginx
        
        # Get SSL certificate
        print_info "در حال دریافت گواهی SSL..."
        sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN" || true
        
    else
        sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$FRONTEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:$BACKEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
        
        sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
        sudo nginx -t && sudo systemctl reload nginx
    fi
    
    print_msg "Nginx تنظیم شد!"
}

start_services_fa() {
    print_info "در حال راه‌اندازی سرویس‌ها..."
    
    # Create systemd service for backend
    if command_exists systemctl; then
        print_info "ایجاد سرویس systemd برای Backend..."
        
        sudo tee /etc/systemd/system/whois-bot-backend.service > /dev/null <<EOF
[Unit]
Description=Whois Bot Backend
After=network.target mongodb.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$SCRIPT_DIR/backend
Environment=PATH=$SCRIPT_DIR/backend/venv/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$SCRIPT_DIR/backend/venv/bin/uvicorn server:app --host 0.0.0.0 --port $BACKEND_PORT
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable whois-bot-backend
        sudo systemctl start whois-bot-backend
        
        print_msg "سرویس Backend راه‌اندازی شد"
    else
        print_warn "systemd موجود نیست. لطفاً سرویس‌ها را به صورت دستی اجرا کنید."
    fi
    
    # Build and serve frontend
    print_info "در حال ساخت Frontend..."
    cd "$SCRIPT_DIR/frontend"
    yarn build
    
    if command_exists pm2; then
        pm2 serve build $FRONTEND_PORT --name whois-bot-frontend --spa
        print_msg "Frontend با PM2 راه‌اندازی شد"
    elif command_exists serve; then
        nohup serve -s build -l $FRONTEND_PORT > /dev/null 2>&1 &
        print_msg "Frontend راه‌اندازی شد"
    else
        print_warn "برای اجرای Frontend از دستور زیر استفاده کنید:"
        echo "  cd $SCRIPT_DIR/frontend && yarn start"
    fi
}

print_final_fa() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║   ✅  نصب با موفقیت انجام شد!                                 ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📱 ربات تلگرام:${NC}"
    echo "   ربات شما فعال است. در تلگرام /start را ارسال کنید."
    echo ""
    echo -e "${CYAN}🖥️ داشبورد وب:${NC}"
    if [ -n "$DOMAIN" ]; then
        if [ "$USE_SSL" == "yes" ]; then
            echo "   https://$DOMAIN"
        else
            echo "   http://$DOMAIN"
        fi
    else
        echo "   http://localhost:$FRONTEND_PORT"
    fi
    echo ""
    echo -e "${CYAN}🔌 API:${NC}"
    echo "   http://localhost:$BACKEND_PORT/api"
    echo ""
    echo -e "${CYAN}📁 فایل‌های تنظیمات:${NC}"
    echo "   Backend: $SCRIPT_DIR/backend/.env"
    echo "   Frontend: $SCRIPT_DIR/frontend/.env"
    echo ""
    echo -e "${YELLOW}⚙️ مدیریت سرویس‌ها:${NC}"
    echo "   sudo systemctl status whois-bot-backend"
    echo "   sudo systemctl restart whois-bot-backend"
    echo "   sudo systemctl stop whois-bot-backend"
    echo ""
    echo -e "${GREEN}با تشکر از استفاده شما! 🙏${NC}"
}

#############################################
# English Installation
#############################################

install_english() {
    print_step "Step 1: Checking Requirements"
    check_requirements_en
    
    print_step "Step 2: Collecting Information"
    get_user_input_en
    
    print_step "Step 3: Installing Dependencies"
    install_dependencies
    
    print_step "Step 4: Setting Up Environment"
    setup_env_files
    
    print_step "Step 5: Domain Setup (Optional)"
    setup_domain_en
    
    print_step "Step 6: Starting Services"
    start_services_en
    
    print_final_en
}

check_requirements_en() {
    print_info "Checking requirements..."
    
    local missing=()
    
    if ! command_exists python3; then
        missing+=("Python 3")
    else
        print_msg "Python 3 installed"
    fi
    
    if ! command_exists node; then
        missing+=("Node.js")
    else
        print_msg "Node.js installed"
    fi
    
    if ! command_exists yarn; then
        if command_exists npm; then
            print_warn "yarn not installed, installing..."
            npm install -g yarn
        else
            missing+=("Yarn/NPM")
        fi
    else
        print_msg "Yarn installed"
    fi
    
    if ! command_exists mongod && ! command_exists mongo; then
        print_warn "MongoDB not installed - you can use MongoDB Atlas"
    else
        print_msg "MongoDB installed"
    fi
    
    if [ ${#missing[@]} -gt 0 ]; then
        print_error "The following are not installed:"
        for item in "${missing[@]}"; do
            echo "  - $item"
        done
        echo ""
        print_info "Please install them first."
        exit 1
    fi
    
    print_msg "All requirements satisfied!"
}

get_user_input_en() {
    echo -e "${CYAN}Please enter the following information:${NC}"
    echo ""
    
    # Telegram Bot Token
    echo -e "${YELLOW}📱 Telegram Bot Token${NC}"
    echo "   Get it from @BotFather on Telegram"
    echo "   https://t.me/BotFather"
    echo ""
    while [ -z "$TELEGRAM_BOT_TOKEN" ]; do
        read -p "   Bot Token: " TELEGRAM_BOT_TOKEN
        if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
            print_error "Bot token is required!"
        fi
    done
    print_msg "Bot token saved"
    echo ""
    
    # WhoisFreaks API Key
    echo -e "${YELLOW}🔑 WhoisFreaks API Key${NC}"
    echo "   Get it from https://whoisfreaks.com"
    echo ""
    while [ -z "$WHOISFREAKS_API_KEY" ]; do
        read -p "   API Key: " WHOISFREAKS_API_KEY
        if [ -z "$WHOISFREAKS_API_KEY" ]; then
            print_error "API key is required!"
        fi
    done
    print_msg "API key saved"
    echo ""
    
    # MongoDB URL
    echo -e "${YELLOW}🗄️ MongoDB URL${NC}"
    echo "   Default: mongodb://localhost:27017"
    echo ""
    read -p "   MongoDB URL [Press Enter for default]: " input_mongo
    if [ -n "$input_mongo" ]; then
        MONGO_URL="$input_mongo"
    fi
    print_msg "MongoDB URL: $MONGO_URL"
    echo ""
    
    # Database Name
    echo -e "${YELLOW}📁 Database Name${NC}"
    echo "   Default: whois_bot"
    echo ""
    read -p "   Database Name [Press Enter for default]: " input_db
    if [ -n "$input_db" ]; then
        DB_NAME="$input_db"
    fi
    print_msg "Database Name: $DB_NAME"
    echo ""
    
    # Backend Port
    echo -e "${YELLOW}🔌 Backend Port${NC}"
    echo "   Default: 8001"
    echo ""
    read -p "   Backend Port [Press Enter for default]: " input_backend_port
    if [ -n "$input_backend_port" ]; then
        BACKEND_PORT="$input_backend_port"
    fi
    print_msg "Backend Port: $BACKEND_PORT"
    echo ""
    
    # Frontend Port
    echo -e "${YELLOW}🖥️ Frontend Port${NC}"
    echo "   Default: 3000"
    echo ""
    read -p "   Frontend Port [Press Enter for default]: " input_frontend_port
    if [ -n "$input_frontend_port" ]; then
        FRONTEND_PORT="$input_frontend_port"
    fi
    print_msg "Frontend Port: $FRONTEND_PORT"
}

setup_domain_en() {
    echo -e "${CYAN}Would you like to set up a domain for the dashboard?${NC}"
    echo "  1) Yes, I want to configure a domain"
    echo "  2) No, just run on localhost"
    echo ""
    read -p "Select [2]: " domain_choice
    domain_choice=${domain_choice:-2}
    
    if [ "$domain_choice" == "1" ]; then
        echo ""
        read -p "Domain name (e.g., whois.example.com): " DOMAIN
        
        if [ -n "$DOMAIN" ]; then
            echo ""
            echo -e "${CYAN}Would you like to set up SSL (HTTPS)?${NC}"
            echo "  1) Yes, with Let's Encrypt"
            echo "  2) No, HTTP only"
            echo ""
            read -p "Select [1]: " ssl_choice
            ssl_choice=${ssl_choice:-1}
            
            if [ "$ssl_choice" == "1" ]; then
                USE_SSL="yes"
            fi
            
            setup_nginx_en
        fi
    else
        print_info "Dashboard will be available at http://localhost:$FRONTEND_PORT"
    fi
}

setup_nginx_en() {
    if ! command_exists nginx; then
        print_warn "Nginx is not installed. Would you like to install it? (y/n)"
        read -p "Select: " install_nginx
        if [ "$install_nginx" == "y" ]; then
            if command_exists apt-get; then
                sudo apt-get update && sudo apt-get install -y nginx
            elif command_exists yum; then
                sudo yum install -y nginx
            else
                print_error "Please install Nginx manually"
                return
            fi
        else
            return
        fi
    fi
    
    print_info "Configuring Nginx..."
    
    NGINX_CONF="/etc/nginx/sites-available/$DOMAIN"
    
    if [ "$USE_SSL" == "yes" ]; then
        if ! command_exists certbot; then
            print_info "Installing Certbot..."
            if command_exists apt-get; then
                sudo apt-get install -y certbot python3-certbot-nginx
            elif command_exists yum; then
                sudo yum install -y certbot python3-certbot-nginx
            fi
        fi
        
        sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$FRONTEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:$BACKEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
        
        sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
        sudo nginx -t && sudo systemctl reload nginx
        
        print_info "Obtaining SSL certificate..."
        sudo certbot --nginx -d "$DOMAIN" --non-interactive --agree-tos --email "admin@$DOMAIN" || true
        
    else
        sudo tee "$NGINX_CONF" > /dev/null <<EOF
server {
    listen 80;
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$FRONTEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }

    location /api {
        proxy_pass http://localhost:$BACKEND_PORT;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host \$host;
        proxy_cache_bypass \$http_upgrade;
    }
}
EOF
        
        sudo ln -sf "$NGINX_CONF" /etc/nginx/sites-enabled/
        sudo nginx -t && sudo systemctl reload nginx
    fi
    
    print_msg "Nginx configured!"
}

start_services_en() {
    print_info "Starting services..."
    
    if command_exists systemctl; then
        print_info "Creating systemd service for Backend..."
        
        sudo tee /etc/systemd/system/whois-bot-backend.service > /dev/null <<EOF
[Unit]
Description=Whois Bot Backend
After=network.target mongodb.service

[Service]
Type=simple
User=$USER
WorkingDirectory=$SCRIPT_DIR/backend
Environment=PATH=$SCRIPT_DIR/backend/venv/bin:/usr/local/bin:/usr/bin:/bin
ExecStart=$SCRIPT_DIR/backend/venv/bin/uvicorn server:app --host 0.0.0.0 --port $BACKEND_PORT
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        sudo systemctl daemon-reload
        sudo systemctl enable whois-bot-backend
        sudo systemctl start whois-bot-backend
        
        print_msg "Backend service started"
    else
        print_warn "systemd not available. Please start services manually."
    fi
    
    print_info "Building Frontend..."
    cd "$SCRIPT_DIR/frontend"
    yarn build
    
    if command_exists pm2; then
        pm2 serve build $FRONTEND_PORT --name whois-bot-frontend --spa
        print_msg "Frontend started with PM2"
    elif command_exists serve; then
        nohup serve -s build -l $FRONTEND_PORT > /dev/null 2>&1 &
        print_msg "Frontend started"
    else
        print_warn "To run Frontend, use:"
        echo "  cd $SCRIPT_DIR/frontend && yarn start"
    fi
}

print_final_en() {
    echo ""
    echo -e "${GREEN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}║   ✅  Installation completed successfully!                    ║${NC}"
    echo -e "${GREEN}║                                                               ║${NC}"
    echo -e "${GREEN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${CYAN}📱 Telegram Bot:${NC}"
    echo "   Your bot is active. Send /start in Telegram."
    echo ""
    echo -e "${CYAN}🖥️ Web Dashboard:${NC}"
    if [ -n "$DOMAIN" ]; then
        if [ "$USE_SSL" == "yes" ]; then
            echo "   https://$DOMAIN"
        else
            echo "   http://$DOMAIN"
        fi
    else
        echo "   http://localhost:$FRONTEND_PORT"
    fi
    echo ""
    echo -e "${CYAN}🔌 API:${NC}"
    echo "   http://localhost:$BACKEND_PORT/api"
    echo ""
    echo -e "${CYAN}📁 Config Files:${NC}"
    echo "   Backend: $SCRIPT_DIR/backend/.env"
    echo "   Frontend: $SCRIPT_DIR/frontend/.env"
    echo ""
    echo -e "${YELLOW}⚙️ Service Management:${NC}"
    echo "   sudo systemctl status whois-bot-backend"
    echo "   sudo systemctl restart whois-bot-backend"
    echo "   sudo systemctl stop whois-bot-backend"
    echo ""
    echo -e "${GREEN}Thank you for using Whois Bot! 🙏${NC}"
}

#############################################
# Common Functions
#############################################

install_dependencies() {
    # Backend dependencies
    print_info "Installing Backend dependencies..."
    cd "$SCRIPT_DIR/backend"
    
    if [ ! -d "venv" ]; then
        python3 -m venv venv
    fi
    
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    deactivate
    
    print_msg "Backend dependencies installed"
    
    # Frontend dependencies
    print_info "Installing Frontend dependencies..."
    cd "$SCRIPT_DIR/frontend"
    yarn install
    
    print_msg "Frontend dependencies installed"
}

setup_env_files() {
    print_info "Setting up environment files..."
    
    # Backend .env
    cat > "$SCRIPT_DIR/backend/.env" <<EOF
MONGO_URL="$MONGO_URL"
DB_NAME="$DB_NAME"
CORS_ORIGINS="*"
TELEGRAM_BOT_TOKEN=$TELEGRAM_BOT_TOKEN
WHOISFREAKS_API_KEY=$WHOISFREAKS_API_KEY
EOF
    
    print_msg "Backend .env created"
    
    # Frontend .env
    if [ -n "$DOMAIN" ]; then
        if [ "$USE_SSL" == "yes" ]; then
            BACKEND_URL="https://$DOMAIN"
        else
            BACKEND_URL="http://$DOMAIN"
        fi
    else
        BACKEND_URL="http://localhost:$BACKEND_PORT"
    fi
    
    cat > "$SCRIPT_DIR/frontend/.env" <<EOF
REACT_APP_BACKEND_URL=$BACKEND_URL
EOF
    
    print_msg "Frontend .env created"
}

# Run main function
main "$@"
