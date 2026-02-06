from fastapi import FastAPI, APIRouter, HTTPException, Request, BackgroundTasks
from dotenv import load_dotenv
from starlette.middleware.cors import CORSMiddleware
from motor.motor_asyncio import AsyncIOMotorClient
import os
import logging
from pathlib import Path
from pydantic import BaseModel, Field, ConfigDict
from typing import List, Optional, Dict, Any
import uuid
from datetime import datetime, timezone
import httpx
from telegram import Update, Bot, InlineKeyboardButton, InlineKeyboardMarkup
from telegram.ext import Application, CommandHandler, MessageHandler, filters, CallbackQueryHandler, ContextTypes
import asyncio

ROOT_DIR = Path(__file__).parent
load_dotenv(ROOT_DIR / '.env')

# MongoDB connection
mongo_url = os.environ['MONGO_URL']
client = AsyncIOMotorClient(mongo_url)
db = client[os.environ['DB_NAME']]

# Telegram Bot Token
TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN')
WHOISFREAKS_API_KEY = os.environ.get('WHOISFREAKS_API_KEY')

# Create the main app without a prefix
app = FastAPI()

# Create a router with the /api prefix
api_router = APIRouter(prefix="/api")

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# User language preferences (in-memory cache)
user_languages: Dict[int, str] = {}

# Messages in both languages
MESSAGES = {
    'fa': {
        'welcome': """🌐 *به ربات Whois خوش آمدید!*

این ربات می‌تونه اطلاعات ثبت دامنه رو برای شما پیدا کنه.

📋 *دستورات:*
• `/whois domain.com` - اطلاعات کامل دامنه
• `/check domain.com` - بررسی وضعیت دامنه
• `/expiry domain.com` - تاریخ انقضا
• `/lang` - تغییر زبان
• `/help` - راهنما

💡 *مثال:* `/whois google.com`""",
        'help': """📚 *راهنمای استفاده*

🔹 `/whois domain.com`
اطلاعات کامل WHOIS شامل:
• نام ثبت‌کننده
• تاریخ ثبت و انقضا
• سرور DNS
• وضعیت دامنه

🔹 `/check domain.com`
بررسی سریع وضعیت دامنه (آزاد یا ثبت شده)

🔹 `/expiry domain.com`
فقط تاریخ انقضای دامنه

🔹 `/lang`
تغییر زبان ربات (فارسی/English)

💬 *نکته:* می‌تونید مستقیم نام دامنه رو بفرستید!""",
        'enter_domain': "⚠️ لطفاً نام دامنه را وارد کنید.\n\n*مثال:* `/whois google.com`",
        'searching': "🔍 در حال جستجوی اطلاعات دامنه *{domain}*...",
        'domain_registered': "✅ دامنه ثبت شده",
        'domain_available': "🟢 دامنه آزاد است!",
        'domain_unknown': "❓ وضعیت نامشخص",
        'registrar': "🏢 ثبت‌کننده",
        'creation_date': "📅 تاریخ ثبت",
        'expiry_date': "⏰ تاریخ انقضا",
        'update_date': "🔄 آخرین بروزرسانی",
        'name_servers': "🌐 سرورهای DNS",
        'status': "📊 وضعیت",
        'registrant': "👤 مالک",
        'error': "❌ خطا در دریافت اطلاعات. لطفاً دوباره تلاش کنید.",
        'invalid_domain': "⚠️ نام دامنه معتبر نیست!",
        'lang_changed': "✅ زبان به فارسی تغییر کرد!",
        'select_lang': "🌐 *زبان مورد نظر را انتخاب کنید:*",
        'days_left': "روز مانده",
        'expired': "منقضی شده!",
        'whois_server': "🖥️ سرور WHOIS",
        'domain_info_title': "📋 *اطلاعات دامنه {domain}*",
        'check_title': "🔎 *بررسی وضعیت دامنه*",
        'expiry_title': "⏳ *تاریخ انقضای دامنه*",
        'domain_name': "🌐 دامنه",
    },
    'en': {
        'welcome': """🌐 *Welcome to Whois Bot!*

This bot can find domain registration information for you.

📋 *Commands:*
• `/whois domain.com` - Full domain info
• `/check domain.com` - Check domain status
• `/expiry domain.com` - Expiry date
• `/lang` - Change language
• `/help` - Help

💡 *Example:* `/whois google.com`""",
        'help': """📚 *Usage Guide*

🔹 `/whois domain.com`
Full WHOIS information including:
• Registrar name
• Registration & expiry dates
• DNS servers
• Domain status

🔹 `/check domain.com`
Quick check if domain is available or registered

🔹 `/expiry domain.com`
Only domain expiry date

🔹 `/lang`
Change bot language (فارسی/English)

💬 *Tip:* You can directly send domain name!""",
        'enter_domain': "⚠️ Please enter a domain name.\n\n*Example:* `/whois google.com`",
        'searching': "🔍 Searching for domain *{domain}*...",
        'domain_registered': "✅ Domain is Registered",
        'domain_available': "🟢 Domain is Available!",
        'domain_unknown': "❓ Status Unknown",
        'registrar': "🏢 Registrar",
        'creation_date': "📅 Creation Date",
        'expiry_date': "⏰ Expiry Date",
        'update_date': "🔄 Last Updated",
        'name_servers': "🌐 Name Servers",
        'status': "📊 Status",
        'registrant': "👤 Registrant",
        'error': "❌ Error fetching information. Please try again.",
        'invalid_domain': "⚠️ Invalid domain name!",
        'lang_changed': "✅ Language changed to English!",
        'select_lang': "🌐 *Select your language:*",
        'days_left': "days left",
        'expired': "Expired!",
        'whois_server': "🖥️ WHOIS Server",
        'domain_info_title': "📋 *Domain Info: {domain}*",
        'check_title': "🔎 *Domain Status Check*",
        'expiry_title': "⏳ *Domain Expiry Date*",
        'domain_name': "🌐 Domain",
    }
}

def get_msg(user_id: int, key: str) -> str:
    lang = user_languages.get(user_id, 'fa')
    return MESSAGES[lang].get(key, MESSAGES['en'].get(key, key))

def escape_markdown(text: str) -> str:
    """Escape special characters for Telegram Markdown"""
    if not text:
        return ""
    special_chars = ['_', '*', '[', ']', '(', ')', '~', '`', '>', '#', '+', '-', '=', '|', '{', '}', '.', '!']
    for char in special_chars:
        text = str(text).replace(char, f'\\{char}')
    return text

def is_valid_domain(domain: str) -> bool:
    """Check if domain format is valid"""
    if not domain:
        return False
    domain = domain.lower().strip()
    # Remove http/https prefix
    if domain.startswith('http://'):
        domain = domain[7:]
    if domain.startswith('https://'):
        domain = domain[8:]
    # Remove www prefix
    if domain.startswith('www.'):
        domain = domain[4:]
    # Basic validation
    if '.' not in domain:
        return False
    if len(domain) < 3:
        return False
    return True

def clean_domain(domain: str) -> str:
    """Clean domain name"""
    domain = domain.lower().strip()
    if domain.startswith('http://'):
        domain = domain[7:]
    if domain.startswith('https://'):
        domain = domain[8:]
    if domain.startswith('www.'):
        domain = domain[4:]
    # Remove trailing slash
    if domain.endswith('/'):
        domain = domain[:-1]
    return domain

async def fetch_whois_data(domain: str) -> Optional[Dict[Any, Any]]:
    """Fetch WHOIS data from WhoisFreaks API"""
    try:
        async with httpx.AsyncClient(timeout=30) as client:
            url = f"https://api.whoisfreaks.com/v1.0/whois?apiKey={WHOISFREAKS_API_KEY}&domainName={domain}&whois=live"
            response = await client.get(url)
            if response.status_code == 200:
                return response.json()
            else:
                logger.error(f"WhoisFreaks API error: {response.status_code} - {response.text}")
                return None
    except Exception as e:
        logger.error(f"Error fetching WHOIS data: {e}")
        return None

def format_whois_response(data: Dict, user_id: int) -> str:
    """Format WHOIS data for Telegram"""
    lang = user_languages.get(user_id, 'fa')
    msg = MESSAGES[lang]
    
    domain = data.get('domain_name', 'N/A')
    
    # Build response
    response_parts = []
    response_parts.append(msg['domain_info_title'].format(domain=domain))
    response_parts.append("")
    
    # Domain registration status
    if data.get('domain_registered') == 'yes':
        response_parts.append(f"📌 {msg['domain_registered']}")
    else:
        response_parts.append(f"🟢 {msg['domain_available']}")
    
    response_parts.append("")
    
    # Domain name
    response_parts.append(f"{msg['domain_name']}: `{domain}`")
    
    # Registrar
    registrar = data.get('domain_registrar') or data.get('registrar', {})
    if isinstance(registrar, dict):
        registrar_name = registrar.get('registrar_name') or registrar.get('name', 'N/A')
    else:
        registrar_name = str(registrar) if registrar else 'N/A'
    if registrar_name and registrar_name != 'N/A':
        response_parts.append(f"{msg['registrar']}: {escape_markdown(registrar_name)}")
    
    # Dates
    create_date = data.get('create_date') or data.get('creation_date')
    if create_date:
        response_parts.append(f"{msg['creation_date']}: `{create_date}`")
    
    update_date = data.get('update_date')
    if update_date:
        response_parts.append(f"{msg['update_date']}: `{update_date}`")
    
    expiry_date = data.get('expiry_date')
    if expiry_date:
        response_parts.append(f"{msg['expiry_date']}: `{expiry_date}`")
        # Calculate days left
        try:
            exp = datetime.strptime(expiry_date.split('T')[0], '%Y-%m-%d')
            days_left = (exp - datetime.now()).days
            if days_left > 0:
                response_parts.append(f"   ⏱️ {days_left} {msg['days_left']}")
            else:
                response_parts.append(f"   ⚠️ {msg['expired']}")
        except:
            pass
    
    # WHOIS Server
    whois_server = data.get('whois_server')
    if whois_server:
        response_parts.append(f"{msg['whois_server']}: `{whois_server}`")
    
    # Name Servers
    name_servers = data.get('name_servers') or data.get('nameservers')
    if name_servers and isinstance(name_servers, list):
        ns_list = ', '.join(name_servers[:4])
        response_parts.append(f"{msg['name_servers']}: `{ns_list}`")
    
    # Status
    status = data.get('status') or data.get('domain_status')
    if status:
        if isinstance(status, list):
            status_str = ', '.join(status[:3])
        else:
            status_str = str(status)
        response_parts.append(f"{msg['status']}: `{status_str[:50]}`")
    
    # Registrant info
    registrant = data.get('registrant_contact') or data.get('registrant')
    if registrant and isinstance(registrant, dict):
        registrant_name = registrant.get('name') or registrant.get('organization')
        if registrant_name:
            response_parts.append(f"{msg['registrant']}: {escape_markdown(registrant_name)}")
    
    return '\n'.join(response_parts)

def format_check_response(data: Dict, domain: str, user_id: int) -> str:
    """Format domain check response"""
    lang = user_languages.get(user_id, 'fa')
    msg = MESSAGES[lang]
    
    response_parts = []
    response_parts.append(msg['check_title'])
    response_parts.append("")
    response_parts.append(f"{msg['domain_name']}: `{domain}`")
    response_parts.append("")
    
    if data.get('domain_registered') == 'yes':
        response_parts.append(f"📌 *{msg['domain_registered']}*")
        registrar = data.get('registrar', {})
        if isinstance(registrar, dict):
            registrar_name = registrar.get('registrar_name') or registrar.get('name')
        else:
            registrar_name = str(registrar) if registrar else None
        if registrar_name:
            response_parts.append(f"{msg['registrar']}: {escape_markdown(registrar_name)}")
    else:
        response_parts.append(f"🎉 *{msg['domain_available']}*")
    
    return '\n'.join(response_parts)

def format_expiry_response(data: Dict, domain: str, user_id: int) -> str:
    """Format expiry date response"""
    lang = user_languages.get(user_id, 'fa')
    msg = MESSAGES[lang]
    
    response_parts = []
    response_parts.append(msg['expiry_title'])
    response_parts.append("")
    response_parts.append(f"{msg['domain_name']}: `{domain}`")
    response_parts.append("")
    
    expiry_date = data.get('expiry_date')
    if expiry_date:
        response_parts.append(f"📅 *{expiry_date}*")
        # Calculate days left
        try:
            exp = datetime.strptime(expiry_date.split('T')[0], '%Y-%m-%d')
            days_left = (exp - datetime.now()).days
            if days_left > 0:
                response_parts.append(f"⏱️ {days_left} {msg['days_left']}")
            else:
                response_parts.append(f"⚠️ *{msg['expired']}*")
        except:
            pass
    else:
        response_parts.append("❓ N/A")
    
    return '\n'.join(response_parts)

# Telegram Bot Handlers
async def start_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /start command"""
    user_id = update.effective_user.id
    if user_id not in user_languages:
        user_languages[user_id] = 'fa'  # Default to Persian
    
    # Log to database
    await db.bot_logs.insert_one({
        "user_id": user_id,
        "username": update.effective_user.username,
        "command": "start",
        "timestamp": datetime.now(timezone.utc).isoformat()
    })
    
    await update.message.reply_text(
        get_msg(user_id, 'welcome'),
        parse_mode='Markdown'
    )

async def help_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /help command"""
    user_id = update.effective_user.id
    await update.message.reply_text(
        get_msg(user_id, 'help'),
        parse_mode='Markdown'
    )

async def lang_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /lang command"""
    user_id = update.effective_user.id
    
    keyboard = [
        [
            InlineKeyboardButton("🇮🇷 فارسی", callback_data="lang_fa"),
            InlineKeyboardButton("🇺🇸 English", callback_data="lang_en")
        ]
    ]
    reply_markup = InlineKeyboardMarkup(keyboard)
    
    await update.message.reply_text(
        get_msg(user_id, 'select_lang'),
        reply_markup=reply_markup,
        parse_mode='Markdown'
    )

async def lang_callback(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle language selection callback"""
    query = update.callback_query
    await query.answer()
    
    user_id = query.from_user.id
    
    if query.data == "lang_fa":
        user_languages[user_id] = 'fa'
        await query.edit_message_text("✅ زبان به فارسی تغییر کرد!")
    elif query.data == "lang_en":
        user_languages[user_id] = 'en'
        await query.edit_message_text("✅ Language changed to English!")

async def whois_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /whois command"""
    user_id = update.effective_user.id
    
    # Get domain from command
    if context.args and len(context.args) > 0:
        domain = context.args[0]
    else:
        await update.message.reply_text(
            get_msg(user_id, 'enter_domain'),
            parse_mode='Markdown'
        )
        return
    
    # Validate domain
    if not is_valid_domain(domain):
        await update.message.reply_text(get_msg(user_id, 'invalid_domain'))
        return
    
    domain = clean_domain(domain)
    
    # Send searching message
    searching_msg = await update.message.reply_text(
        get_msg(user_id, 'searching').format(domain=domain),
        parse_mode='Markdown'
    )
    
    # Log to database
    await db.whois_queries.insert_one({
        "user_id": user_id,
        "username": update.effective_user.username,
        "domain": domain,
        "command": "whois",
        "timestamp": datetime.now(timezone.utc).isoformat()
    })
    
    # Fetch WHOIS data
    data = await fetch_whois_data(domain)
    
    if data and data.get('status') != False:
        response = format_whois_response(data, user_id)
        await searching_msg.edit_text(response, parse_mode='Markdown')
    else:
        await searching_msg.edit_text(get_msg(user_id, 'error'))

async def check_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /check command"""
    user_id = update.effective_user.id
    
    if context.args and len(context.args) > 0:
        domain = context.args[0]
    else:
        await update.message.reply_text(
            get_msg(user_id, 'enter_domain'),
            parse_mode='Markdown'
        )
        return
    
    if not is_valid_domain(domain):
        await update.message.reply_text(get_msg(user_id, 'invalid_domain'))
        return
    
    domain = clean_domain(domain)
    
    searching_msg = await update.message.reply_text(
        get_msg(user_id, 'searching').format(domain=domain),
        parse_mode='Markdown'
    )
    
    # Log to database
    await db.whois_queries.insert_one({
        "user_id": user_id,
        "username": update.effective_user.username,
        "domain": domain,
        "command": "check",
        "timestamp": datetime.now(timezone.utc).isoformat()
    })
    
    data = await fetch_whois_data(domain)
    
    if data:
        response = format_check_response(data, domain, user_id)
        await searching_msg.edit_text(response, parse_mode='Markdown')
    else:
        await searching_msg.edit_text(get_msg(user_id, 'error'))

async def expiry_command(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle /expiry command"""
    user_id = update.effective_user.id
    
    if context.args and len(context.args) > 0:
        domain = context.args[0]
    else:
        await update.message.reply_text(
            get_msg(user_id, 'enter_domain'),
            parse_mode='Markdown'
        )
        return
    
    if not is_valid_domain(domain):
        await update.message.reply_text(get_msg(user_id, 'invalid_domain'))
        return
    
    domain = clean_domain(domain)
    
    searching_msg = await update.message.reply_text(
        get_msg(user_id, 'searching').format(domain=domain),
        parse_mode='Markdown'
    )
    
    # Log to database
    await db.whois_queries.insert_one({
        "user_id": user_id,
        "username": update.effective_user.username,
        "domain": domain,
        "command": "expiry",
        "timestamp": datetime.now(timezone.utc).isoformat()
    })
    
    data = await fetch_whois_data(domain)
    
    if data:
        response = format_expiry_response(data, domain, user_id)
        await searching_msg.edit_text(response, parse_mode='Markdown')
    else:
        await searching_msg.edit_text(get_msg(user_id, 'error'))

async def handle_text_message(update: Update, context: ContextTypes.DEFAULT_TYPE):
    """Handle direct domain input"""
    user_id = update.effective_user.id
    text = update.message.text.strip()
    
    # Check if it looks like a domain
    if is_valid_domain(text):
        domain = clean_domain(text)
        
        searching_msg = await update.message.reply_text(
            get_msg(user_id, 'searching').format(domain=domain),
            parse_mode='Markdown'
        )
        
        # Log to database
        await db.whois_queries.insert_one({
            "user_id": user_id,
            "username": update.effective_user.username,
            "domain": domain,
            "command": "direct",
            "timestamp": datetime.now(timezone.utc).isoformat()
        })
        
        data = await fetch_whois_data(domain)
        
        if data and data.get('status') != False:
            response = format_whois_response(data, user_id)
            await searching_msg.edit_text(response, parse_mode='Markdown')
        else:
            await searching_msg.edit_text(get_msg(user_id, 'error'))
    else:
        await update.message.reply_text(
            get_msg(user_id, 'enter_domain'),
            parse_mode='Markdown'
        )

# Initialize Telegram Bot Application
telegram_app = None

async def setup_telegram_bot():
    """Setup and start Telegram bot"""
    global telegram_app
    
    if not TELEGRAM_BOT_TOKEN:
        logger.error("TELEGRAM_BOT_TOKEN not set!")
        return
    
    telegram_app = Application.builder().token(TELEGRAM_BOT_TOKEN).build()
    
    # Add handlers
    telegram_app.add_handler(CommandHandler("start", start_command))
    telegram_app.add_handler(CommandHandler("help", help_command))
    telegram_app.add_handler(CommandHandler("lang", lang_command))
    telegram_app.add_handler(CommandHandler("whois", whois_command))
    telegram_app.add_handler(CommandHandler("check", check_command))
    telegram_app.add_handler(CommandHandler("expiry", expiry_command))
    telegram_app.add_handler(CallbackQueryHandler(lang_callback, pattern="^lang_"))
    telegram_app.add_handler(MessageHandler(filters.TEXT & ~filters.COMMAND, handle_text_message))
    
    # Start polling
    await telegram_app.initialize()
    await telegram_app.start()
    await telegram_app.updater.start_polling(drop_pending_updates=True)
    
    logger.info("Telegram bot started successfully!")

# Pydantic Models
class StatusCheck(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    client_name: str
    timestamp: datetime = Field(default_factory=lambda: datetime.now(timezone.utc))

class StatusCheckCreate(BaseModel):
    client_name: str

class WhoisQuery(BaseModel):
    model_config = ConfigDict(extra="ignore")
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    user_id: int
    username: Optional[str] = None
    domain: str
    command: str
    timestamp: str

class BotStats(BaseModel):
    total_queries: int
    unique_users: int
    popular_domains: List[Dict[str, Any]]
    recent_queries: List[Dict[str, Any]]

# API Routes
@api_router.get("/")
async def root():
    return {"message": "Whois Bot API is running!"}

@api_router.get("/health")
async def health_check():
    return {"status": "healthy", "bot_running": telegram_app is not None}

@api_router.get("/stats", response_model=BotStats)
async def get_stats():
    """Get bot statistics"""
    # Total queries
    total_queries = await db.whois_queries.count_documents({})
    
    # Unique users
    unique_users = len(await db.whois_queries.distinct("user_id"))
    
    # Popular domains (aggregation)
    pipeline = [
        {"$group": {"_id": "$domain", "count": {"$sum": 1}}},
        {"$sort": {"count": -1}},
        {"$limit": 10}
    ]
    popular_cursor = db.whois_queries.aggregate(pipeline)
    popular_domains = []
    async for doc in popular_cursor:
        popular_domains.append({"domain": doc["_id"], "count": doc["count"]})
    
    # Recent queries
    recent_cursor = db.whois_queries.find({}, {"_id": 0}).sort("timestamp", -1).limit(20)
    recent_queries = await recent_cursor.to_list(20)
    
    return BotStats(
        total_queries=total_queries,
        unique_users=unique_users,
        popular_domains=popular_domains,
        recent_queries=recent_queries
    )

@api_router.get("/whois/{domain}")
async def api_whois(domain: str):
    """Direct WHOIS lookup via API"""
    if not is_valid_domain(domain):
        raise HTTPException(status_code=400, detail="Invalid domain name")
    
    domain = clean_domain(domain)
    data = await fetch_whois_data(domain)
    
    if data:
        return data
    else:
        raise HTTPException(status_code=500, detail="Failed to fetch WHOIS data")

@api_router.post("/status", response_model=StatusCheck)
async def create_status_check(input: StatusCheckCreate):
    status_dict = input.model_dump()
    status_obj = StatusCheck(**status_dict)
    doc = status_obj.model_dump()
    doc['timestamp'] = doc['timestamp'].isoformat()
    _ = await db.status_checks.insert_one(doc)
    return status_obj

@api_router.get("/status", response_model=List[StatusCheck])
async def get_status_checks():
    status_checks = await db.status_checks.find({}, {"_id": 0}).to_list(1000)
    for check in status_checks:
        if isinstance(check['timestamp'], str):
            check['timestamp'] = datetime.fromisoformat(check['timestamp'])
    return status_checks

# Include the router in the main app
app.include_router(api_router)

app.add_middleware(
    CORSMiddleware,
    allow_credentials=True,
    allow_origins=os.environ.get('CORS_ORIGINS', '*').split(','),
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.on_event("startup")
async def startup_event():
    """Start Telegram bot on app startup"""
    asyncio.create_task(setup_telegram_bot())

@app.on_event("shutdown")
async def shutdown_event():
    """Cleanup on shutdown"""
    global telegram_app
    if telegram_app:
        await telegram_app.updater.stop()
        await telegram_app.stop()
        await telegram_app.shutdown()
    client.close()
