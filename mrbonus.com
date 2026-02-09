import logging
import asyncio
from aiogram import Bot, Dispatcher, types
from aiogram.utils import executor
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton

# 1. НАЛАШТУВАННЯ
API_TOKEN = '8203507097:AAHrvoAqt11KkF3-I1XS1V6xdzB2RdwgTWo'
ADMIN_ID = 1634779056 
MAIN_VIDEO_ID = 'BAACAgIAAxkBAAEg9dBpihmaGJlULq1741ecly-VDN7aFQAC7IwAAkw7UEgUZMGnHAbyvjoE'

logging.basicConfig(level=logging.INFO)
bot = Bot(token=API_TOKEN)
dp = Dispatcher(bot)
users_db = set()

# Головне меню з 11 казино
def get_main_menu():
    keyboard = InlineKeyboardMarkup(row_width=2)
    keyboard.add(
        InlineKeyboardButton("🎰 SlotCity: 200ГРН", callback_data="slot"),
        InlineKeyboardButton("🚀 FirstCasino: 1300FS", callback_data="first"),
        InlineKeyboardButton("💎 777: 777FS", callback_data="777"),
        InlineKeyboardButton("🔥 TopMatch: 100FS", callback_data="topmatch"),
        InlineKeyboardButton("🃏 Betking: 200FS", callback_data="betking"),
        InlineKeyboardButton("🍀 Parik24: 200FS", callback_data="parik24"),
        InlineKeyboardButton("👑 BETON: 500FS", callback_data="beton"),
        InlineKeyboardButton("⚡️ GG-BET: 100FS", callback_data="gg"),
        InlineKeyboardButton("🎯 GORILLA: 300FS", callback_data="gorilla"),
        InlineKeyboardButton("🌟 VEGAS: 150FS", callback_data="vegas"),
        InlineKeyboardButton("💰 CHAMPION: 1000FS", callback_data="championclub")
    )
    return keyboard

# 2. СТАРТ
@dp.message_handler(commands=['start'])
async def send_welcome(message: types.Message):
    users_db.add(message.from_user.id)
    
    welcome_text = (
        f"Привіт, {message.from_user.first_name} ❤️👋\n\n"
        "🎁 **Бонус 200 грн на Slot City** та ще 10 подарунків прийдуть сюди за 5 секунд.\n\n"
        "👇 Поки чекаєш, [подай запит](https://t.me) у наш канал (там бонуси щодня):"
    )
    
    first_kb = InlineKeyboardMarkup().add(
        InlineKeyboardButton("📢 ПОДАТИ ЗАПИТ", url="https://t.me")
    )
    
    await message.answer(welcome_text, reply_markup=first_kb, parse_mode="Markdown", disable_web_page_preview=True)

    await asyncio.sleep(5)
    
    main_caption = (
        "➖➖➖➖➖➖➖➖➖➖➖\n"
        "⠀ ⠀ ⠀ 🎰 **ГРОШІ НА БАЗІ!** 💰\n"
        "➖➖➖➖➖➖➖➖➖➖➖\n\n"
        "Твій основний бонус чекає тут:\n"
        "🔥 [ SLOT CITY — 200 ГРН ](http://play.mrbonusua.space) 🔥\n\n"
        "👇 Нижче ще 10 ТОП-пропозицій.\n"
        "Обери казино, де ще не грав:"
    )
    
    await bot.send_video(message.from_user.id, video=MAIN_VIDEO_ID, caption=main_caption, reply_markup=get_main_menu(), parse_mode="Markdown")

# 3. ПОВЕРНЕННЯ В МЕНЮ З ВИДАЛЕННЯМ СТАРОГО ПОВІДОМЛЕННЯ
@dp.callback_query_handler(lambda c: c.data == 'back_to_menu')
async def back_to_menu(callback: types.CallbackQuery):
    try:
        await bot.delete_message(callback.from_user.id, callback.message.message_id)
    except:
        pass # Якщо видалити не вдалося (наприклад, повідомлення старе), просто йдемо далі
    
    main_caption = (
        "➖➖➖➖➖➖➖➖➖➖➖\n"
        "⠀ ⠀ ⠀ 🎰 **ГРОШІ НА БАЗІ!** 💰\n"
        "➖➖➖➖➖➖➖➖➖➖➖\n\n"
        "Обери казино та забирай свій бонус:"
    )
    
    await bot.send_video(callback.from_user.id, video=MAIN_VIDEO_ID, caption=main_caption, reply_markup=get_main_menu(), parse_mode="Markdown")
    await callback.answer()

# 4. ОБРОБКА КАЗИНО
@dp.callback_query_handler()
async def check_button(callback: types.CallbackQuery):
    data = {
        "slot": ["SlotCity", "http://play.mrbonusua.space", "BAACAgIAAxkBAAEg9hJpiiWDnE_Ew7M7ECFzudEEteFGtgACnY0AAkw7UEiaMjbT0_u6rDoE"],
        "first": ["FirstCasino", "https://твій_pwa_2", "BAACAgIAAxkBAAEg9hhpiiYyP3ISfrh1YYgBJrdBaGNqZwACn40AAkw7UEiYZCT8y8yENToE"],
        "777": ["777", "https://твій_pwa_3", "BAACAgIAAxkBAAEg9iRpiibKY28-6FbyHcPPdtLnS0jBMAACo40AAkw7UEgPSRCY6I4tejoE"],
        "topmatch": ["Topmatch", "https://твій_pwa_4", "BAACAgIAAxkBAAEg9ihpiidOtDTjiyXSKa0ZNFGry2s-XgACpo0AAkw7UEj_G7OcLDT4FzoE"],
        "betking": ["Betking", "https://твій_pwa_5", "BAACAgIAAxkBAAEg9i5piifCqwOlwZg_ttkV0vkS1RTWegACq40AAkw7UEiOPnRSZxL5pDoE"],
        "parik24": ["Parik24", "https://твій_pwa_6", "BAACAgIAAxkBAAEg9jxpiih6kYdqlowvRHxXIuHSMYJSYgACso0AAkw7UEggMxOyT44MWjoE"],
        "beton": ["Beton", "https://твій_pwa_7", "BAACAgIAAxkBAAEg9j5piikLYQ1mvuDxSSVn54cBDMQ2FQACt40AAkw7UEiKPnialKbd6DoE"],
        "gg": ["GG-BET", "https://твій_pwa_8", "BAACAgIAAxkBAAEg9kBpiimz_ugL6IKU3sTgTyLzkk6DfQACvI0AAkw7UEgIdg_MU4wLUjoE"],
        "gorilla": ["Gorilla", "https://твій_pwa_9", "BAACAgIAAxkBAAEg9kJpiioQ0P0_L_7MLXbjJ4b4yhlSMAACwY0AAkw7UEh_IW_pISZSEzoE"],
        "vegas": ["Vegas", "https://твій_pwa_10", "BAACAgIAAxkBAAEg9kZpiiqtNw4sDVfTjr19EfS2h3rIoQACxo0AAkw7UEhGhv2yHGz4PzoE"],
        "championclub": ["Championclub", "https://твій_pwa_11", "BAACAgIAAxkBAAEg9kxpiitWxTlnOJ3YEopf29xJ8l_3AgACzI0AAkw7UEjYBZJCIRwK1ToE"]
    }

    if callback.data in data:
        name, link, vid = data[callback.data]
        
        # Створюємо дві кнопки в ряд
        bonus_kb = InlineKeyboardMarkup(row_width=2)
        bonus_kb.add(
            InlineKeyboardButton("🔥 ЗАБРАТИ БОНУС", url=link),
            InlineKeyboardButton("🔙 МЕНЮ", callback_data="back_to_menu")
        )

        caption = (
            f"🎰 **{name.upper()}**\n"
            f"➖➖➖➖➖➖➖➖➖➖➖\n\n"
            f"👇 Реєструйся, верифікуйся та роби деп від 100 грн!\n\n"
            f"🎁 Твій бонус активовано!"
        )

        try:
            # Видаляємо головне меню перед показом конкретного казино
            await bot.delete_message(callback.from_user.id, callback.message.message_id)
            await bot.send_video(callback.from_user.id, video=vid, caption=caption, reply_markup=bonus_kb, parse_mode="Markdown")
        except:
            await bot.send_video(callback.from_user.id, video=vid, caption=caption, reply_markup=bonus_kb, parse_mode="Markdown")
    
    await callback.answer()

if __name__ == '__main__':
    executor.start_polling(dp, skip_updates=True)

