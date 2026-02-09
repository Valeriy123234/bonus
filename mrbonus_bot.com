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
        InlineKeyboardButton("🎰 SlotCity: 200ГРН", url="лінк_1"),
        InlineKeyboardButton("🚀 FirstCasino: 1300FS", url="лінк_2"),
        InlineKeyboardButton("💎 777: 777FS", url="лінк_3"),
        InlineKeyboardButton("🔥 TopMatch: 100FS", url="лінк_4"),
        InlineKeyboardButton("🃏 Betking: 200FS", url="лінк_5"),
        InlineKeyboardButton("🍀 Parik24: 200FS", url="лінк_6"),
        InlineKeyboardButton("👑 BETON: 500FS", url="лінк_7"),
        InlineKeyboardButton("⚡️ GG-BET: 100FS", url="лінк_8"),
        InlineKeyboardButton("🎯 GORILLA: 300FS", url="лінк_9"),
        InlineKeyboardButton("🌟 VEGAS: 150FS", url="лінк_10"),
        InlineKeyboardButton("💰 CHAMPIONCLUB: 1000FS", url="лінк_11")
    )

    
    await bot.send_video(
        chat_id=message.chat.id,
        video=VIDEO_FILE_ID,
        caption=caption_text,
        reply_markup=second_kb,
        parse_mode="Markdown"
    )

# 4. РОЗСИЛКА (ВИКОРИСТОВУЙ КОМАНДУ /send ТЕКСТ)
@dp.message_handler(commands=['send'])
async def broadcast(message: types.Message):
    if message.from_user.id == ADMIN_ID:
        text = message.get_args()
        if not text:
            return await message.answer("⚠️ Напиши текст після команди /send")
        
        count = 0
        for user_id in users_db:
            try:
                await bot.send_message(user_id, text)
                count += 1
            except:
                pass
        await message.answer(f"✅ Розсилка завершена! Отримали: {count} юзерів.")

if __name__ == '__main__':
    executor.start_polling(dp, skip_updates=True)
