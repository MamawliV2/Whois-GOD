# 🌐 Whois Domain Lookup Telegram Bot

<div align="center">

![Whois Bot](https://img.shields.io/badge/Telegram-Bot-blue?style=for-the-badge&logo=telegram)
![Python](https://img.shields.io/badge/Python-3.11+-green?style=for-the-badge&logo=python)
![FastAPI](https://img.shields.io/badge/FastAPI-0.110+-teal?style=for-the-badge&logo=fastapi)
![React](https://img.shields.io/badge/React-19-blue?style=for-the-badge&logo=react)
![MongoDB](https://img.shields.io/badge/MongoDB-7.0-green?style=for-the-badge&logo=mongodb)

**ربات تلگرام جستجوی اطلاعات دامنه (WHOIS) با داشبورد وب**

[فارسی](#فارسی) | [English](#english)

</div>

---

## فارسی

### 📋 معرفی

این پروژه یک ربات تلگرام برای جستجوی اطلاعات WHOIS دامنه‌ها است. با استفاده از این ربات می‌توانید:

- ✅ اطلاعات کامل ثبت دامنه را مشاهده کنید
- ✅ وضعیت دامنه (آزاد یا ثبت شده) را بررسی کنید
- ✅ تاریخ انقضای دامنه را ببینید
- ✅ از رابط کاربری دو زبانه (فارسی/انگلیسی) استفاده کنید

### 🚀 ویژگی‌ها

#### ربات تلگرام
| دستور | توضیحات |
|--------|----------|
| `/start` | شروع کار با ربات |
| `/whois domain.com` | اطلاعات کامل WHOIS |
| `/check domain.com` | بررسی وضعیت دامنه |
| `/expiry domain.com` | تاریخ انقضا |
| `/lang` | تغییر زبان |
| `/help` | راهنما |

💡 **نکته:** می‌توانید مستقیماً نام دامنه را بفرستید!

#### داشبورد وب
- 📊 نمایش آمار کل جستجوها
- 👥 تعداد کاربران یکتا
- 🔥 دامنه‌های محبوب
- 🕐 جستجوهای اخیر
- 🔍 جستجوی مستقیم WHOIS

### 📦 پیش‌نیازها

- Python 3.11+
- Node.js 18+
- MongoDB 6.0+
- توکن ربات تلگرام (از [@BotFather](https://t.me/BotFather))
- API Key از [WhoisFreaks](https://whoisfreaks.com)

### ⚡ نصب سریع

```bash
# کلون پروژه
git clone https://github.com/your-username/whois-telegram-bot.git
cd whois-telegram-bot

# اجرای اسکریپت نصب
chmod +x install.sh
./install.sh
```

### 🔧 نصب دستی

#### 1. تنظیم Backend

```bash
cd backend

# ایجاد محیط مجازی
python -m venv venv
source venv/bin/activate  # Linux/Mac
# یا
.\venv\Scripts\activate  # Windows

# نصب وابستگی‌ها
pip install -r requirements.txt

# تنظیم متغیرهای محیطی
cp .env.example .env
nano .env  # ویرایش فایل
```

#### 2. تنظیم Frontend

```bash
cd frontend

# نصب وابستگی‌ها
yarn install

# تنظیم متغیرهای محیطی
cp .env.example .env
nano .env  # ویرایش فایل
```

#### 3. اجرا

```bash
# Backend
cd backend
uvicorn server:app --host 0.0.0.0 --port 8001 --reload

# Frontend (در ترمینال جدید)
cd frontend
yarn start
```

### 🔐 متغیرهای محیطی

#### Backend (`backend/.env`)
```env
MONGO_URL=mongodb://localhost:27017
DB_NAME=whois_bot
TELEGRAM_BOT_TOKEN=your_telegram_bot_token
WHOISFREAKS_API_KEY=your_whoisfreaks_api_key
CORS_ORIGINS=*
```

#### Frontend (`frontend/.env`)
```env
REACT_APP_BACKEND_URL=http://localhost:8001
```

### 🐳 اجرا با Docker

```bash
docker-compose up -d
```

### 📁 ساختار پروژه

```
whois-telegram-bot/
├── backend/
│   ├── server.py          # سرور FastAPI و ربات تلگرام
│   ├── requirements.txt   # وابستگی‌های Python
│   └── .env              # متغیرهای محیطی
├── frontend/
│   ├── src/
│   │   ├── App.js        # کامپوننت اصلی React
│   │   └── App.css       # استایل‌ها
│   ├── package.json      # وابستگی‌های Node.js
│   └── .env             # متغیرهای محیطی
├── install.sh           # اسکریپت نصب
├── docker-compose.yml   # تنظیمات Docker
└── README.md           # این فایل
```

---

## English

### 📋 Introduction

A Telegram bot for domain WHOIS lookup with a beautiful web dashboard. Features:

- ✅ Complete domain registration information
- ✅ Check domain availability
- ✅ View domain expiry dates
- ✅ Bilingual interface (Persian/English)

### 🚀 Features

#### Telegram Bot Commands
| Command | Description |
|---------|-------------|
| `/start` | Start the bot |
| `/whois domain.com` | Full WHOIS info |
| `/check domain.com` | Check domain status |
| `/expiry domain.com` | Expiry date |
| `/lang` | Change language |
| `/help` | Help |

💡 **Tip:** You can directly send a domain name!

#### Web Dashboard
- 📊 Total queries statistics
- 👥 Unique users count
- 🔥 Popular domains
- 🕐 Recent queries
- 🔍 Direct WHOIS lookup

### 📦 Requirements

- Python 3.11+
- Node.js 18+
- MongoDB 6.0+
- Telegram Bot Token (from [@BotFather](https://t.me/BotFather))
- API Key from [WhoisFreaks](https://whoisfreaks.com)

### ⚡ Quick Install

```bash
git clone https://github.com/your-username/whois-telegram-bot.git
cd whois-telegram-bot
chmod +x install.sh
./install.sh
```

### 🌐 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/api/health` | GET | Health check |
| `/api/stats` | GET | Bot statistics |
| `/api/whois/{domain}` | GET | WHOIS lookup |

### 📄 License

MIT License - See [LICENSE](LICENSE) file

### 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

<div align="center">

**Made with ❤️ using WhoisFreaks API**

</div>
