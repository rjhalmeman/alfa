#!/bin/bash

# Exibe instruções de uso se não houver argumentos suficientes
if [ "$#" -ne 2 ]; then
  echo "================================================================================"
  echo "CORTADOR DE VÍDEO - Remove segundos do final do vídeo"
  echo "================================================================================"
  echo "Uso: $0 <arquivo_de_entrada> <segundos_a_remover_do_final>"
  echo ""
  echo "EXEMPLOS:"
  echo "  1. Remove 10 segundos do final de um vídeo MP4:"
  echo "     $0 video.mp4 10"
  echo "     → Saída: 'video cortado.mp4' com 10s a menos no final"
  echo ""
  echo "  2. Remove 2.5 segundos do final de um vídeo MOV:"
  echo "     $0 filme.mov 2.5"
  echo "     → Saída: 'filme cortado.mov' com 2.5s a menos no final"
  echo ""
  echo "OBSERVAÇÕES:"
  echo "  - O script mantém a mesma qualidade do vídeo original (cópia direta)"
  echo "  - Preserva o formato original do arquivo (MP4, AVI, MOV, etc.)"
  echo "  - O tempo pode ser especificado com casas decimais (ex: 1.5, 0.75)"
  echo "================================================================================"
  exit 1
fi

ARQUIVO="$1"
REMOVER="$2"
ARQUIVO_SAIDA="${ARQUIVO%.*} cortado.${ARQUIVO##*.}"

echo "Processando: $ARQUIVO"
echo "Removendo $REMOVER segundos do final do vídeo..."

# Obtém a duração do vídeo com ffprobe
DURACAO=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$ARQUIVO")

echo "Duração original: $(echo "$DURACAO" | bc) segundos"

# Calcula a nova duração
NOVO_TEMPO=$(echo "$DURACAO - $REMOVER" | bc)

# Garante que o tempo não seja negativo
if (( $(echo "$NOVO_TEMPO <= 0" | bc -l) )); then
  echo "Erro: o tempo a remover ($REMOVER s) é maior ou igual à duração do vídeo ($DURACAO s)."
  exit 1
fi

echo "Nova duração: $NOVO_TEMPO segundos"

# Executa o corte com ffmpeg
echo "Cortando vídeo... Aguarde."
ffmpeg -i "$ARQUIVO" -t "$NOVO_TEMPO" -c copy "$ARQUIVO_SAIDA" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "================================================================================"
  echo "SUCESSO! Vídeo cortado salvo como: $ARQUIVO_SAIDA"
  echo "================================================================================"
else
  echo "Erro: Falha ao processar o vídeo. Verifique se o arquivo existe e é um vídeo válido."
  exit 1
fi


