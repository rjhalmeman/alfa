#!/bin/bash

# Verifica se os parâmetros foram passados corretamente
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 <arquivo.mkv> <tempo_de_corte (formato hh:mm:ss)>"
    echo "Exemplo: $0 video.mkv 00:25:00"
    exit 1
fi

arquivo="$1"
tempo_corte="$2"

# Remove extensão do arquivo
base_nome="${arquivo%.*}"

# Gera nomes para os arquivos de saída
saida1="${base_nome}_parte1.mkv"
saida2="${base_nome}_parte2.mkv"

echo "Dividindo \"$arquivo\" em:"
echo "  - Parte 1: 0 até $tempo_corte → $saida1"
echo "  - Parte 2: de $tempo_corte até o fim → $saida2"
echo

# Parte 1
ffmpeg -i "$arquivo" -ss 00:00:00 -t "$tempo_corte" -c copy "$saida1"

# Parte 2
ffmpeg -i "$arquivo" -ss "$tempo_corte" -c copy "$saida2"

echo
echo "Divisão concluída."

