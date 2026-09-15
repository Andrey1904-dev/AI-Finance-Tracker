# FinTrack AI

Modern browser-based personal finance tracker with Supabase cloud storage and email authentication.

## Features

- 🔐 Email registration and login
- 🔑 Password reset
- ☁️ Supabase-only data storage — no localStorage fallback
- 💸 Income and expense tracking
- 📊 Dashboard and analytics
- 🎯 Financial goals
- 📋 Category budgets
- 🔁 Recurring payments
- 💳 Accounts and wallets
- ✈️ Telegram AI demo interface
- 📤 JSON / CSV export and import
- 📱 Responsive layout for desktop and iPhone
- 🛡️ Supabase Row Level Security: each account sees only its own data

## Deploy

The project is static and requires no Node.js build step.

1. Run `supabase-schema.sql` in Supabase SQL Editor.
2. Enable the Email authentication provider.
3. Configure the GitHub Pages URL in Supabase Authentication → URL Configuration.
4. Upload `index.html` and the static assets to GitHub Pages.

Detailed instructions are in `SUPABASE-SETUP.md`.


## Новое: кредиты, категории и Telegram-напоминания
- Несколько кредитов на одного пользователя.
- Банк, назначение, сумма, ставка, срок, дата оформления и ближайший платёж.
- Ориентировочный расчёт ежемесячного платежа и остатка основного долга.
- Кредиты отображаются в календаре.
- Telegram-напоминания за 3 дня, за 2 дня, за 1 день, в день платежа и после просрочки — до отметки оплаты.
- Удаление отдельных расходов и доходов.
- Пользовательские категории расходов и доходов с переименованием/удалением/добавлением.
- Telegram `/categories` использует категории конкретного пользователя.
- Telegram `/credits` показывает кредиты пользователя.
