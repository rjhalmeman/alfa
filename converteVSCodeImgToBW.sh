#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Uso: $0 <origem> <destino>"
    echo "Exemplo: $0 foto.png resultado.png"
    exit 1
fi

if [ ! -f "$1" ]; then
    echo "Erro: Arquivo '$1' não encontrado!"
    exit 1
fi

# Converte garantindo fundo BRANCO e texto PRETO
convert "$1" \
    -colorspace Gray \
    -threshold 50% \
    -negate \
    -sharpen 0x1 \
    "$2"

echo "✓ Convertido: $2 (fundo branco, texto preto)"