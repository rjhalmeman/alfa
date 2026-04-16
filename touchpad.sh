#!/bin/bash

DEVICE="ATML3000:00 03EB:2168 Touchpad"

case "$1" in
    a)
        xinput enable "$DEVICE"
        echo "✅ Touchpad ativado"
        ;;
    d)
        xinput disable "$DEVICE"
        echo "❌ Touchpad desativado"
        ;;
    *)
        echo "Uso: ./touchpad.sh [a|d]"
        echo "  a - ativar touchpad"
        echo "  d - desativar touchpad"
        ;;
esac