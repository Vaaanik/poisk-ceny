#!/usr/bin/env bash
# Установка бота поиска цен на сервер Ubuntu 22.04/24.04 (рядом с другими ботами не конфликтует).
# Запуск под root:  curl -fsSL https://raw.githubusercontent.com/vaaanik/poisk-ceny/main/deploy/setup.sh | bash
set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/vaaanik/poisk-ceny.git}"
BRANCH="${BRANCH:-main}"
APP_USER=poisk
APP_DIR=/home/$APP_USER/poisk-ceny

apt-get update -q
apt-get install -y -q git python3 python3-venv python3-pip

id -u $APP_USER >/dev/null 2>&1 || useradd -m -s /bin/bash $APP_USER

if [ ! -d "$APP_DIR" ]; then
  sudo -u $APP_USER git clone -b "$BRANCH" "$REPO_URL" "$APP_DIR"
else
  sudo -u $APP_USER git -C "$APP_DIR" pull
fi

sudo -u $APP_USER python3 -m venv "$APP_DIR/.venv"
[ -f "$APP_DIR/requirements.txt" ] && sudo -u $APP_USER "$APP_DIR/.venv/bin/pip" install -q -r "$APP_DIR/requirements.txt"
if [ ! -f "$APP_DIR/.env" ]; then
  if [ -f "$APP_DIR/.env.example" ]; then
    sudo -u $APP_USER cp "$APP_DIR/.env.example" "$APP_DIR/.env"
  else
    echo "TELEGRAM_BOT_TOKEN=" | sudo -u $APP_USER tee "$APP_DIR/.env" >/dev/null
  fi
  chmod 600 "$APP_DIR/.env"
fi

cp "$APP_DIR/deploy/poisk-ceny.service" /etc/systemd/system/poisk-ceny.service
systemctl daemon-reload
systemctl enable poisk-ceny >/dev/null

cat <<EOT

✅ Установлено. Осталось:
  1. nano $APP_DIR/.env      — впишите токен бота
  2. systemctl restart poisk-ceny
  3. journalctl -u poisk-ceny -f   — смотреть логи

Обновить бота после изменений в GitHub:
  sudo -u $APP_USER git -C $APP_DIR pull && systemctl restart poisk-ceny
EOT
