#!/bin/bash

# Verifica se os argumentos foram passados
if [ $# -ne 2 ]; then
    echo "Uso: $0 <arquivo_origem> <arquivo_destino>"
    echo "Exemplo: $0 origem.png destino.png"
    exit 1
fi

ORIGEM="$1"
DESTINO="$2"

# Verifica se o arquivo de origem existe
if [ ! -f "$ORIGEM" ]; then
    echo "Erro: Arquivo '$ORIGEM' não encontrado!"
    exit 1
fi

# Executa a conversão
convert "$ORIGEM" -resize 200% -colorspace Gray -threshold 25% -resize 50% "$DESTINO"

# Verifica se a conversão foi bem sucedida
if [ $? -eq 0 ]; then
    echo "Conversão concluída: $DESTINO"
else
    echo "Erro durante a conversão!"
    exit 1
fi
