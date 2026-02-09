import logging
import asyncio
from aiogram import Bot, Dispatcher, types
from aiogram.utils import executor
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton

# 1. НАЛАШТУВАННЯ
# Встав свій токен від @BotFather нижче:
API_TOKEN = '8203507097:AAHrvoAqt11KkF3-I1XS1V6xdzB2RdwgTWo'
ADMIN_ID = 1634779056  # Твій ID вже вписано
VIDEO_FILE_ID = 'BAACAgIAAxkBAAEg9dBpihmaGJlULq1741ecly-VDN7aFQAC7IwAAkw7UEgUZMGnHAbyvjoE'

bot = Bot(token=API_TOKEN)
dp = Dispatcher(bot)
users_db = set()

# 2. ПЕРШЕ ПОВІДОМЛЕННЯ (START)
@dp.message_handler(commands=['start'])
async def send_welcome(message: types.Message):
    user_name = message.from_user.first_name
    users_db.add(message.from_user.id)
    
    welcome_text = (
        f"Привіт, {user_name} ❤️👋\n\n"
        "🎁 **Бонус 200 грн на Slot City** та ще 10 подарунків прийдуть сюди за 5 секунд.\n\n"
        "👇 Поки чекаєш, [подай запит](https://t.me/+c33timlTVpYyOGQ6) у наш канал (там бонуси щодня):"
    )
    
    first_kb = InlineKeyboardMarkup(row_width=1)
    # ЗАМІНИ ПОСИЛАННЯ НИЖЧЕ НА СВОЄ (https://t.me+)
    first_kb.add(InlineKeyboardButton("📢 ПОДАТИ ЗАПИТ", url="https://t.me/+c33timlTVpYyOGQ6"))
    
    await message.answer(welcome_text, reply_markup=first_kb, parse_mode="Markdown")

    # 3. ЗАРИМКА 5 СЕКУНД ТА ВІДЕО-ОФЕР
    await asyncio.sleep(5)
    
    caption_text = (
        "➖➖➖➖➖➖➖➖➖➖➖\n"
        "⠀ ⠀ ⠀ 🎰 **ГРОШІ НА БАЗІ!** 💰\n"
        "➖➖➖➖➖➖➖➖➖➖➖\n\n"
        "Твій основний бонус чекає тут:\n"
        "🔥 [ SLOT CITY — 200 ГРН ](http://play.mrbonusua.space/bonus2.html) 🔥\n\n"
        "👇 Нижче ще 10 ТОП-пропозицій.\n"
        "Обери казино, де ще не грав:"
    )
    
        second_kb = InlineKeyboardMarkup(row_width=2) # Ставимо 2 кнопки в ряд
    second_kb.add(
        InlineKeyboardButton("🎰 SlotCity: 200ГРН", callback_data="slot"),
        InlineKeyboardButton("🚀 FirstCasino: 1300FS", callback_data="first"),
        InlineKeyboardButton("💎 777: 777FS", callback_data="777"),
        InlineKeyboardButton("🔥 TopMatch: 100FS", callback_data="topmatch""),
        InlineKeyboardButton("🃏 Betking: 200FS", callback_data="betking""),
        InlineKeyboardButton("🍀 Parik24: 200FS", callback_data="parik24"),
        InlineKeyboardButton("👑 BETON: 500FS", callback_data="beton"),
        InlineKeyboardButton("⚡️ GG-BET: 100FS", callback_data="gg"),
        InlineKeyboardButton("🎯 GORILLA: 300FS", callback_data="gorilla"),
        InlineKeyboardButton("🌟 VEGAS: 150FS", callback_data="vegas"),
        InlineKeyboardButton("💰 CHAMPIONCLUB: 1000FS", callback_data="championclub")
    )

    
       await message.answer("📺 **Обери казино, подивись відео та забирай бонус:**", reply_markup=casino_kb)

# 3. ЩО РОБИТИ, КОЛИ НАТИСНУЛИ НА КАЗИНО
@dp.callback_query_handler()
async def check_button(callback: types.CallbackQuery):
    
    # Якщо натиснули SlotCity (мітка "slot")
    if callback.data == "slot":
        video_id = "BAACAgIAAxkBAAEg9hJpiiWDnE_Ew7M7ECFzudEEteFGtgACnY0AAkw7UEiaMjbT0_u6rDoE"
        link = "https://твій_pwa_1"
        name = "SlotCity"
    
    # Якщо натиснули Vulcan (мітка "vulc")
    elif callback.data == "first":
        video_id = "BAACAgIAAxkBAAEg9hhpiiYyP3ISfrh1YYgBJrdBaGNqZwACn40AAkw7UEiYZCT8y8yENToE"
        link = "https://твій_pwa_2"
        name = "FirstCasino"
        
    # Спільний текст для всіх
    caption = (
        f"🎰 **{name}**\n\n"
        f"1️⃣ Реєструйся\n2️⃣ Депни від 100 грн\n\n"
        f"🔥 [ ЗАБРАТИ БОНУС ]({link}) 🔥"
    )

    await bot.send_video(callback.from_user.id, video=video_id, caption=caption, parse_mode="Markdown")
    await bot.answer_callback_query(callback.id) # Прибирає годинничок з кнопки

if __name__ == '__main__':
    executor.start_polling(dp, skip_updates=True)
