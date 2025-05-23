#!/bin/bash

# Bash script to archive logs and optionally notify a Telegram user
# Usage: ./log-archive.sh <log-directory> <telegram-user-id>

# === Configuration ===
BOT_TOKEN="your_telegram_bot_token_here"
ARCHIVE_DIR="./archives"
LOG_FILE="$ARCHIVE_DIR/archive_log.txt"

# === Input Validation ===
LOG_DIR="$1"
TELEGRAM_USER_ID="$2"

if [ -z "$LOG_DIR" ] || [ -z "$TELEGRAM_USER_ID" ]; then
    echo "Usage: $0 <log-directory> <telegram-user-id>"
    exit 1
fi

if [ ! -d "$LOG_DIR" ]; then
    echo "Error: $LOG_DIR is not a valid directory."
    exit 1
fi

# === Setup ===
mkdir -p "$ARCHIVE_DIR"

# === Create Archive ===
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
ARCHIVE_NAME="logs_archive_${TIMESTAMP}.tar.gz"
ARCHIVE_PATH="$ARCHIVE_DIR/$ARCHIVE_NAME"

tar -czf "$ARCHIVE_PATH" -C "$(dirname "$LOG_DIR")" "$(basename "$LOG_DIR")"

# === Log the Archive ===
echo "[$TIMESTAMP] Archived $LOG_DIR to $ARCHIVE_NAME" >>"$LOG_FILE"

# === Send Telegram Notification ===
MESSAGE="📦 Logs from $LOG_DIR have been archived as $ARCHIVE_NAME on $(hostname) at $TIMESTAMP."

curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d chat_id="$TELEGRAM_USER_ID" \
    -d text="$MESSAGE"

# === Send Archive File to Telegram ===
curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendDocument" \
    -F chat_id="$TELEGRAM_USER_ID" \
    -F document=@"$ARCHIVE_PATH"

# ...existing code...
# === Done ===
echo "✅ Archive created at $ARCHIVE_PATH"
echo "📝 Log updated at $LOG_FILE"
echo "📨 Telegram notification sent to user ID: $TELEGRAM_USER_ID"
