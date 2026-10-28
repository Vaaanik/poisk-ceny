# poisk-ceny
Telegram-бот поиска цен.

## Запуск на сервере 24/7 (Ubuntu 24.04)

Зайдите на сервер (`ssh root@IP`) и выполните:
```bash
curl -fsSL https://raw.githubusercontent.com/vaaanik/poisk-ceny/main/deploy/setup.sh | bash
nano /home/poisk/poisk-ceny/.env        # вписать токен бота
systemctl restart poisk-ceny
journalctl -u poisk-ceny -f             # логи (выход — Ctrl+C)
```
Бот сам перезапускается после падения и после перезагрузки сервера. Если на сервере уже работает другой бот, он не мешает: у каждого свой пользователь и своя служба.

Управление: `systemctl status|restart|stop poisk-ceny`.
Обновление: `sudo -u poisk git -C /home/poisk/poisk-ceny pull && systemctl restart poisk-ceny`.

Точка входа — `bot.py`, зависимости — `requirements.txt`, токен — в `.env` (не коммитится).
