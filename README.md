# 🌐 Whois Domain Lookup Telegram Bot

<div align="center">

![Whois Bot](https://img.shields.io/badge/Telegram-Bot-blue?style=for-the-badge&logo=telegram)
![Python](https://img.shields.io/badge/Python-3.11+-green?style=for-the-badge&logo=python)
![React](https://img.shields.io/badge/React-18-blue?style=for-the-badge&logo=react)
![MongoDB](https://img.shields.io/badge/MongoDB-7.0-green?style=for-the-badge&logo=mongodb)

**ربات تلگرام جستجوی اطلاعات دامنه (WHOIS) با داشبورد وب**

[فارسی](#فارسی) | [English](#english)

</div>

---

## فارسی

### ⚡ نصب سریع (یک دستور)

```bash
git clone https://github.com/MamawliV2/Whois-GOD.git && cd Whois-GOD && chmod +x install.sh && ./install.sh
```

### 📋 معرفی

این پروژه یک ربات تلگرام برای جستجوی اطلاعات WHOIS دامنه‌ها است. با استفاده از این ربات می‌توانید:

- ✅ اطلاعات کامل ثبت دامنه را مشاهده کنید
- ✅ وضعیت دامنه (آزاد یا ثبت شده) را بررسی کنید
- ✅ تاریخ انقضای دامنه را ببینید
- ✅ از رابط کاربری دو زبانه (فارسی/انگلیسی) استفاده کنید
- ✅ داشبورد وب با احراز هویت

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
- 🔐 صفحه ورود با رمز عبور
- 📊 نمایش آمار کل جستجوها
- 👥 تعداد کاربران یکتا
- 🔥 دامنه‌های محبوب
- 🕐 جستجوهای اخیر
- 🔍 جستجوی مستقیم WHOIS

### 📦 پیش‌نیازها

- Ubuntu 20.04+ یا Debian 11+
- دسترسی root به سرور
- توکن ربات تلگرام (از [@BotFather](https://t.me/BotFather))
- API Key از [WhoisFreaks](https://whoisfreaks.com)
- دامنه (اختیاری - برای داشبورد وب)

---

## 🔧 عیب‌یابی و حل مشکلات رایج

### ❌ خطای Node.js نسخه قدیمی
```
error @... The engine "node" is incompatible with this module
```

**راه‌حل:**
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18
```

### ❌ خطای MongoDB متصل نیست
```
ServerSelectionTimeoutError: localhost:27017
```

**راه‌حل:**
```bash
# نصب MongoDB
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update && sudo apt-get install -y mongodb-org
sudo systemctl start mongod && sudo systemctl enable mongod
```

### ❌ خطای Conflict در ربات تلگرام
```
telegram.error.Conflict: terminated by other getUpdates request
```

**راه‌حل:** فقط یک instance از ربات باید اجرا باشد:
```bash
pkill -9 -f uvicorn
cd ~/Whois-GOD/backend && nohup uvicorn server:app --host 0.0.0.0 --port 8001 > /tmp/backend.log 2>&1 &
```

### ❌ خطای emergentintegrations
```
No matching distribution found for emergentintegrations
```

**راه‌حل:** این پکیج در requirements.txt نباید باشد. فایل جدید استفاده کنید.

### ❌ Frontend کار نمی‌کند
```
Connection refused on port 3000
```

**راه‌حل:**
```bash
npm install -g serve
cd ~/Whois-GOD/frontend && nohup serve -s build -l 3000 > /tmp/frontend.log 2>&1 &
```

### ❌ تغییرات در پنل اعمال نمی‌شود

**راه‌حل:** کش مرورگر را پاک کنید یا از حالت Incognito استفاده کنید.

---

## 🛠️ دستورات مدیریت

### روشن کردن سرویس‌ها
```bash
# Backend
cd ~/Whois-GOD/backend && nohup uvicorn server:app --host 0.0.0.0 --port 8001 > /tmp/backend.log 2>&1 &

# Frontend
cd ~/Whois-GOD/frontend && nohup serve -s build -l 3000 > /tmp/frontend.log 2>&1 &
```

### خاموش کردن سرویس‌ها
```bash
pkill -f uvicorn
pkill -f serve
```

### مشاهده لاگ‌ها
```bash
tail -f /tmp/backend.log
tail -f /tmp/frontend.log
```

### بررسی وضعیت
```bash
curl http://localhost:8001/api/health
curl http://localhost:3000
```

---

## English

### ⚡ Quick Install (One Command)

```bash
git clone https://github.com/MamawliV2/Whois-GOD.git && cd Whois-GOD && chmod +x install.sh && ./install.sh
```

### 📋 Introduction

A Telegram bot for domain WHOIS lookup with a beautiful web dashboard.

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

#### Web Dashboard
- 🔐 Password-protected login
- 📊 Total queries statistics
- 👥 Unique users count
- 🔥 Popular domains
- 🕐 Recent queries
- 🔍 Direct WHOIS lookup

---

## 🔧 Troubleshooting

### ❌ Node.js Version Error
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
```

### ❌ MongoDB Connection Error
```bash
curl -fsSL https://www.mongodb.org/static/pgp/server-7.0.asc | sudo gpg -o /usr/share/keyrings/mongodb-server-7.0.gpg --dearmor
echo "deb [ signed-by=/usr/share/keyrings/mongodb-server-7.0.gpg ] http://repo.mongodb.org/apt/ubuntu jammy/mongodb-org/7.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-7.0.list
sudo apt-get update && sudo apt-get install -y mongodb-org
sudo systemctl start mongod && sudo systemctl enable mongod
```

### ❌ Telegram Bot Conflict
```bash
pkill -9 -f uvicorn
cd ~/Whois-GOD/backend && nohup uvicorn server:app --host 0.0.0.0 --port 8001 > /tmp/backend.log 2>&1 &
```

---

## 📄 License

MIT License

---

<div align="center">

**Made with ❤️ using WhoisFreaks API**

</div>
