#!/bin/bash

# Limpe a tela
clear

# Entrada: primeiro argumento do script ($1)
input="$1"

# Remover a extensão .mp4 do nome do arquivo
filename="${input%.*}"

# Nome do arquivo de saída adicionando "ajustado" ao nome
output="${filename} ajustado.mp4"

# Acelera (gera arquivo intermediário 1)
ffmpeg -i "$input" -filter_complex "[0:v]setpts=0.6667*PTS[v];[0:a]atempo=1.5[a]" -map "[v]" -map "[a]" "${filename}_1.mp4"

# Aumenta o volume (gera arquivo intermediário 2)
ffmpeg -i "${filename}_1.mp4" -af "volume=2.0" "${filename}_2.mp4"

# Diminui o chiado e gera o arquivo final
ffmpeg -i "${filename}_2.mp4" -vcodec copy -af "afftdn=nf=-25" "$output"

# Excluir arquivos temporários
rm "${filename}_1.mp4"
rm "${filename}_2.mp4"

echo "Processamento completo. Arquivo de saída: $output"

