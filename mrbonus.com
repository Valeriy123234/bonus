import logging
import asyncio
from aiogram import Bot, Dispatcher, types
from aiogram.utils import executor
from aiogram.types import InlineKeyboardMarkup, InlineKeyboardButton

# 1. НАЛАШТУВАННЯ
API_TOKEN = '8203507097:AAHrvoAqt11KkF3-I1XS1V6xdzB2RdwgTWo'
ADMIN_ID = 1634779056 
# Головне відео, що йде разом з 11 кнопками
MAIN_VIDEO_ID = 'BAACAgIAAxkBAAEg9dBpihmaGJlULq1741ecly-VDN7aFQAC7IwAAkw7UEgUZMGnHAbyvjoE'

logging.basicConfig(level=logging.INFO)
bot = Bot(token=API_TOKEN)
dp = Dispatcher(bot)

# БАЗА КАЗИНО: [Назва, Бонус, Посилання, Video_ID]
CASINO_DATA = {
    "slot": ["SlotCity", "200 ГРН", "http://play.mrbonusua.space", "BAACAgIAAxkBAAEg9hJpiiWDnE_Ew7M7ECFzudEEteFGtgACnY0AAkw7UEiaMjbT0_u6rDoE"],
    "first": ["FirstCasino", "1300 FS", "https://t.me", "BAACAgIAAxkBAAEg9hhpiiYyP3ISfrh1YYgBJrdBaGNqZwACn40AAkw7UEiYZCT8y8yENToE"],
    "777": ["777", "777 FS", "https://t.me", "BAACAgIAAxkBAAEg9iRpiibKY28-6FbyHcPPdtLnS0jBMAACo40AAkw7UEgPSRCY6I4tejoE"],
    "topmatch": ["TopMatch", "100 FS", "https://t.me", "BAACAgIAAxkBAAEg9ihpiidOtDTjiyXSKa0ZNFGry2s-XgACpo0AAkw7UEj_G7OcLDT4FzoE"],
    "betking": ["Betking", "200 FS", "https://t.me", "BAACAgIAAxkBAAEg9i5piifCqwOlwZg_ttkV0vkS1RTWegACq40AAkw7UEiOPnRSZxL5pDoE"],
    "parik24": ["Parik24", "200 FS", "https://t.me", "BAACAgIAAxkBAAEg9jxpiih6kYdqlowvRHxXIuHSMYJSYgACso0AAkw7UEggMxOyT44MWjoE"],
    "beton": ["Beton", "500 FS", "https://t.me", "BAACAgIAAxkBAAEg9j5piikLYQ1mvuDxSSVn54cBDMQ2FQACt40AAkw7UEiKPnialKbd6DoE"],
    "gg": ["GG-BET", "100 FS", "https://t.me", "BAACAgIAAxkBAAEg9kBpiimz_ugL6IKU3sTgTyLzkk6DfQACvI0AAkw7UEgIdg_MU4wLUjoE"],
    "gorilla": ["Gorilla", "300 FS", "https://t.me", "BAACAgIAAxkBAAEg9kJpiioQ0P0_L_7MLXbjJ4b4yhlSMAACwY0AAkw7UEh_IW_pISZSEzoE"],
    "vegas": ["Vegas", "150 FS", "https://t.me", "BAACAgIAAxkBAAEg9kZpiiqtNw4sDVfTjr19EfS2h3rIoQACxo0AAkw7UEhGhv2yHGz4PzoE"],
    "championclub": ["Champion", "1000 FS", "https://t.me", "BAACAgIAAxkBAAEg9kxpiitWxTlnOJ3YEopf29xJ8l_3AgACzI0AAkw7UEjYBZJCIRwK1ToE"]
}

# Функція генерації головного меню
def get_main_menu():
    keyboard = InlineKeyboardMarkup(row_width=2)
    buttons = []
    for k, v in CASINO_DATA.items():
        buttons.append(InlineKeyboardButton(text=f"🎰 {v[0]}: {v[1]}", callback_data=k))
    keyboard.add(*buttons)
    return keyboard

# 2. ПРИВІТАННЯ ТА ТАЙМЕР
@dp.message_handler(commands=['start'])
async def send_welcome(message: types.Message):
    welcome_text = (
        f"Привіт, {message.from_user.first_name} ❤️👋\n\n"
        "🎁 **Бонус 200 грн на Slot City** та ще 10 подарунків прийдуть за 5 секунд.\n\n"
        "👇 Поки чекаєш, [подай запит](https://t.me) у наш канал:"
    )
    first_kb = InlineKeyboardMarkup().add(InlineKeyboardButton("📢 ПОДАТИ ЗАПИТ", url="https://t.me"))
    await message.answer(welcome_text, reply_markup=first_kb, parse_mode="Markdown", disable_web_page_preview=True)
    
    await asyncio.sleep(5)
    
    main_caption = (
        "➖➖➖➖➖➖➖➖➖➖➖\n"
        "⠀ ⠀ ⠀ 🎰 **ГРОШІ НА БАЗІ!** 💰\n"
        "➖➖➖➖➖➖➖➖➖➖➖\n\n"
        "Твій бонус чекає тут:\n"
        "🔥 [ SLOT CITY — 200 ГРН ](http://play.mrbonusua.space) 🔥\n\n"
        "👇 Оберіть казино, де ще не грали:"
    )
    await bot.send_video(message.from_user.id, video=MAIN_VIDEO_ID, caption=main_caption, reply_markup=get_main_menu(), parse_mode="Markdown")

# 3. ПОВЕРНЕННЯ В МЕНЮ
@dp.callback_query_handler(lambda c: c.data == 'back_to_menu')
async def back_to_menu(callback: types.CallbackQuery):
    try:
        await bot.delete_message(callback.from_user.id, callback.message.message_id)
    except:
        pass
    
    await bot.send_video(
        callback.from_user.id, 
        video=MAIN_VIDEO_ID, 
        caption="🎰 **Оберіть казино та забирайте бонус:**", 
        reply_markup=get_main_menu(), 
        parse_mode="Markdown"
    )
    await callback.answer()

# 4. ОБРОБКА КНОПОК КАЗИНО
@dp.callback_query_handler()
async def check_button(callback: types.CallbackQuery):
    if callback.data in CASINO_DATA:
        name, bonus, link, vid = CASINO_DATA[callback.data]
        
        caption = (
            f"🎰 **{name.upper()} — {bonus}**\n"
            f"➖➖➖➖➖➖➖➖➖➖➖\n\n"
            f"👇 Реєструйся, верифікуйся та роби деп від 100 грн!\n\n"
            f"🎁 Твій бонус активовано!"
        )
        
        kb = InlineKeyboardMarkup(row_width=2).add(
            InlineKeyboardButton("🔥 ЗАБРАТИ БОНУС", url=link), 
            InlineKeyboardButton("🔙 МЕНЮ", callback_data="back_to_menu")
        )
        
        try:
            await bot.delete_message(callback.from_user.id, callback.message.message_id)
        except:
            pass
            
        await bot.send_video(callback.from_user.id, video=vid, caption=caption, reply_markup=kb, parse_mode="Markdown")
    
    await callback.answer()

if __name__ == '__main__':
    executor.start_polling(dp, skip_updates=True)
