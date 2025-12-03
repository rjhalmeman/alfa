#!/bin/bash

# Entrada: primeiro argumento do script ($1)
input="$1"

# Remover a extensão .mp4 do nome do arquivo
filename="${input%.*}"

# Nome do arquivo de saída adicionando "modificado" ao nome
output="${filename}Modificado.mp4"

# Comando ffmpeg
ffmpeg -i "$input" -filter_complex "[0:v]setpts=0.6667*PTS[v];[0:a]atempo=1.5[a]" -map "[v]" -map "[a]" "$output"

echo "Processamento completo. Arquivo de saída: $output"
