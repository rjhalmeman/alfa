#!/bin/bash

#limpe a tela
clear

# Entrada: primeiro argumento do script ($1)
input="$1"

# Remover a extensão .mp4 do nome do arquivo
filename="${input%.*}"

# Nome do arquivo de saída adicionando "modificado" ao nome
output="${filename} amplificadoSemChiado.mp4"

# Comando ffmpeg
ffmpeg -i "$input" -af "volume=1.8" "$input"1.mp4

#diminuir chiado
ffmpeg -i "$input"1.mp4 -vcodec copy -af "afftdn=nf=-25" "$output".mp4

#excluir temporario
rm "$input"1.mp4

echo "Processamento completo. Arquivo de saída: $output"
