#!/bin/bash

# Verifica se foram passados exatamente dois argumentos
if [ "$#" -ne 2 ]; then
  echo "Uso: $0 nome_do_arquivo segundos_a_remover"
  exit 1
fi

ARQUIVO="$1"
REMOVER="$2"
ARQUIVO_SAIDA="${ARQUIVO%.*} cortado.${ARQUIVO##*.}"

# Obtém a duração do vídeo com ffprobe
DURACAO=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$ARQUIVO")

# Calcula a nova duração
NOVO_TEMPO=$(echo "$DURACAO - $REMOVER" | bc)

# Garante que o tempo não seja negativo
if (( $(echo "$NOVO_TEMPO <= 0" | bc -l) )); then
  echo "Erro: o tempo a remover é maior ou igual à duração do vídeo."
  exit 1
fi

# Executa o corte com ffmpeg
ffmpeg -i "$ARQUIVO" -t "$NOVO_TEMPO" -c copy "$ARQUIVO_SAIDA"

