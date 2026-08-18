#!/bin/bash

DEVICE_NAME="ATML3000:00 03EB:2168 Touchpad"
DEVICE_ID=$(xinput list | grep -i "ATML3000" | grep -oP 'id=\K[0-9]+' | head -1)

case "$1" in
    a)
        if [ -n "$DEVICE_ID" ]; then
            xinput enable "$DEVICE_ID"
        else
            xinput enable "$DEVICE_NAME"
        fi
        echo "✅ Touchpad ativado"
        ;;
    d)
        if [ -n "$DEVICE_ID" ]; then
            xinput disable "$DEVICE_ID"
        else
            xinput disable "$DEVICE_NAME"
        fi
        echo "❌ Touchpad desativado"
        ;;
    *)
        echo "Uso: ./touchpad.sh [a|d]"
        echo "  a - ativar touchpad"
        echo "  d - desativar touchpad"
        ;;
esac