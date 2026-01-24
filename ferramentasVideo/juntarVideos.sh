#!/bin/bash

# Verifica se foram passados pelo menos dois arquivos
if [ "$#" -lt 2 ]; then
  echo "Uso: $0 video1.mp4 video2.mp4 [video3.mp4 ...]"
  exit 1
fi

# Monta o nome do arquivo de saída com underline entre os nomes (sem a extensão)
saida=""
for video in "$@"; do
  nome=$(basename "$video" .mp4)
  if [ -z "$saida" ]; then
    saida="$nome"
  else
    saida="${saida}_${nome}"
  fi
done
saida="${saida}.mp4"

# Cria o arquivo lista.txt
> lista.txt
for video in "$@"; do
  echo "file '$PWD/$video'" >> lista.txt
done

# Executa o ffmpeg para juntar os vídeos
ffmpeg -f concat -safe 0 -i lista.txt -c copy "$saida"

# Limpa o lista.txt
rm lista.txt

echo "Vídeos unidos em: $saida"

