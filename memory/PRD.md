# Whois Domain Lookup Telegram Bot - PRD

## Original Problem Statement
ساخت ربات تلگرام Whois دامنه با استفاده از API از WhoisFreaks.com
- قابلیت‌ها: همه موارد (جستجوی Whois، بررسی وضعیت، تاریخ انقضا)
- زبان: دو زبانه (فارسی/انگلیسی)
- نوع پاسخ: با فرمت زیبا و ایموجی

## User Personas
1. **کاربر عادی**: می‌خواهد اطلاعات دامنه‌ها را بررسی کند
2. **مدیر سیستم**: می‌خواهد وضعیت دامنه‌های خود را مانیتور کند
3. **توسعه‌دهنده**: می‌خواهد قبل از ثبت دامنه، در دسترس بودن آن را بررسی کند

## Core Requirements (Static)
- [x] جستجوی WHOIS دامنه
- [x] بررسی وضعیت دامنه (آزاد/ثبت شده)
- [x] نمایش تاریخ انقضا
- [x] پشتیبانی دو زبانه (FA/EN)
- [x] رابط کاربری زیبا با ایموجی
- [x] داشبورد وب برای مدیریت

## What's Been Implemented
**Date: 2026-02-06**

### Telegram Bot Features:
- `/start` - شروع کار با ربات
- `/whois domain.com` - اطلاعات کامل WHOIS
- `/check domain.com` - بررسی سریع وضعیت
- `/expiry domain.com` - تاریخ انقضا
- `/lang` - تغییر زبان (FA/EN)
- `/help` - راهنما
- پشتیبانی از ارسال مستقیم نام دامنه

### Web Dashboard:
- نمایش آمار کل جستجوها
- نمایش کاربران یکتا
- وضعیت ربات (فعال/غیرفعال)
- دامنه‌های محبوب
- جستجوهای اخیر
- جستجوی مستقیم WHOIS از داشبورد
- رابط کاربری RTL فارسی

### Backend APIs:
- `GET /api/health` - بررسی سلامت
- `GET /api/stats` - آمار ربات
- `GET /api/whois/{domain}` - جستجوی WHOIS

## Architecture
- **Backend**: FastAPI + python-telegram-bot
- **Frontend**: React + TailwindCSS
- **Database**: MongoDB
- **External API**: WhoisFreaks API

## Prioritized Backlog

### P0 (Critical) - ✅ Completed
- [x] Telegram bot integration
- [x] WHOIS lookup functionality
- [x] Bilingual support

### P1 (High Priority)
- [ ] Domain monitoring/alerts for expiry
- [ ] User authentication for dashboard
- [ ] Export query history

### P2 (Medium Priority)
- [ ] Historical WHOIS data
- [ ] Reverse WHOIS lookup
- [ ] Bulk domain check

## Next Tasks
1. Add domain expiry notification system
2. Implement user authentication
3. Add more detailed WHOIS parsing
