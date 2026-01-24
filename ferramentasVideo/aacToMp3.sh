#!/bin/bash

# Verifica se o FFmpeg está instalado
if ! command -v ffmpeg &> /dev/null; then
    echo "Erro: FFmpeg não está instalado. Por favor, instale-o primeiro."
    exit 1
fi

# Verifica se um arquivo foi passado como parâmetro
if [ -z "$1" ]; then
    echo "Uso: $0 <arquivo.aac>"
    echo "Exemplo: $0 cbm.aac"
    exit 1
fi

# Pega o nome do arquivo de entrada (sem extensão)
input_file="$1"
output_file="${input_file%.aac}.mp3"

# Verifica se o arquivo de entrada existe
if [ ! -f "$input_file" ]; then
    echo "Erro: Arquivo '$input_file' não encontrado."
    exit 1
fi

# Executa a conversão
echo "Convertendo '$input_file' para '$output_file'..."
ffmpeg -i "$input_file" -c:a libmp3lame -q:a 2 "$output_file"

# Verifica se a conversão foi bem-sucedida
if [ $? -eq 0 ]; then
    echo "Conversão concluída com sucesso!"
else
    echo "Erro: Falha na conversão."
    exit 1
fi
