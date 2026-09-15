# Кредиты и ежедневные Telegram-напоминания

## 1. Развернуть функцию

```bash
supabase functions deploy credit-reminders --no-verify-jwt
```

## 2. Секрет для cron

Сгенерируйте локально случайную строку и сохраните её как Supabase Secret `CREDIT_REMINDER_SECRET`. Не отправляйте её в чат.

```bash
python3 -c "import secrets; print(secrets.token_urlsafe(32))"
supabase secrets set CREDIT_REMINDER_SECRET="ВАШ_СГЕНЕРИРОВАННЫЙ_СЕКРЕТ"
```

## 3. Включить Cron

В Supabase Dashboard откройте Integrations → Cron Jobs (или Jobs) и создайте job, который запускает Edge Function `credit-reminders` каждый день. Рекомендуемый интервал — раз в час: функция сама отправит сообщение только когда до платежа осталось 3 дня или меньше.

Для HTTP-вызова используйте:

`POST https://bqlocvjjdulpizdfqotm.supabase.co/functions/v1/credit-reminders`

Header:

`x-credit-reminder-secret: ВАШ_СГЕНЕРИРОВАННЫЙ_СЕКРЕТ`

Также можно использовать SQL + pg_cron/pg_net; Supabase официально поддерживает такой способ запуска Edge Functions по расписанию.

## 4. Автоматический запуск

Файл `supabase/credit-reminders-cron.sql` создаёт job раз в час. Перед запуском SQL:
1. В Supabase Vault создайте secret `credit_reminder_secret`.
2. В качестве значения укажите то же значение, которое вы положили в `CREDIT_REMINDER_SECRET`.
3. Выполните `supabase/credit-reminders-cron.sql` в SQL Editor.

Почему раз в час: функция сама ограничивает отправку до одного уведомления в сутки на каждый кредит, поэтому пользователь не получит 24 одинаковых сообщения.
