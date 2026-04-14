#!/bin/bash

# Nome exato do touchpad
DEVICE="ATML3000:00 03EB:2168 Touchpad"

# Função para mostrar como usar o script
function mostrar_ajuda {
    echo "Uso: ./touchpad.sh [ativado|desativado|status]"
    echo ""
    echo "Exemplos:"
    echo "  ./touchpad.sh desativado  # Desliga o touchpad"
    echo "  ./touchpad.sh ativado     # Liga o touchpad"
    echo "  ./touchpad.sh status      # Mostra o status atual"
}

# Verifica se foi passado um argumento
if [ $# -eq 0 ]; then
    mostrar_ajuda
    exit 1
fi

# Processa o comando
case "$1" in
    ativado)
        xinput enable "$DEVICE"
        echo "✅ Touchpad ATIVADO"
        ;;
    desativado)
        xinput disable "$DEVICE"
        echo "❌ Touchpad DESATIVADO"
        ;;
    status)
        if xinput list-props "$DEVICE" | grep "Device Enabled" | grep "1" > /dev/null; then
            echo "🟢 Touchpad está ATIVADO"
        else
            echo "🔴 Touchpad está DESATIVADO"
        fi
        ;;
    *)
        echo "❌ Comando inválido: $1"
        echo ""
        mostrar_ajuda
        exit 1
        ;;
esac