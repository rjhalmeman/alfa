#!/bin/bash

# Exibe instruções de uso se não houver argumentos suficientes
if [ "$#" -ne 2 ]; then
  echo "================================================================================"
  echo "CORTADOR DE VÍDEO - Corta vídeo até o tempo especificado"
  echo "================================================================================"
  echo "Uso: $0 <arquivo_de_entrada> <tempo_final_hh:mm:ss>"
  echo ""
  echo "EXEMPLOS:"
  echo "  1. Corta um vídeo até 1 minuto e 30 segundos:"
  echo "     $0 video.mp4 01:30"
  echo "     → Saída: 'video cortado.mp4' com vídeo até 1min30s"
  echo ""
  echo "  2. Corta um vídeo até 5 minutos, 45 segundos e 500 milissegundos:"
  echo "     $0 filme.mov 05:45.500"
  echo "     → Saída: 'filme cortado.mov' com vídeo até 5min45.5s"
  echo ""
  echo "  3. Corta um vídeo até 2 horas, 15 minutos e 30 segundos:"
  echo "     $0 documentario.avi 02:15:30"
  echo "     → Saída: 'documentario cortado.avi' com vídeo até 2h15min30s"
  echo ""
  echo "OBSERVAÇÕES:"
  echo "  - O script mantém a mesma qualidade do vídeo original (cópia direta)"
  echo "  - Preserva o formato original do arquivo (MP4, AVI, MOV, etc.)"
  echo "  - O tempo deve estar no formato: hh:mm:ss ou mm:ss"
  echo "  - Milissegundos podem ser adicionados após os segundos (ex: 01:30.500)"
  echo "================================================================================"
  exit 1
fi

ARQUIVO="$1"
TEMPO_FINAL="$2"
ARQUIVO_SAIDA="${ARQUIVO%.*} cortado.${ARQUIVO##*.}"

echo "Processando: $ARQUIVO"
echo "Cortando vídeo até: $TEMPO_FINAL"

# Converte o tempo no formato hh:mm:ss para segundos
converter_para_segundos() {
  local tempo="$1"
  local horas=0
  local minutos=0
  local segundos=0
  
  # Conta quantos separadores ':' existem
  local num_pontos=$(echo "$tempo" | tr -cd ':' | wc -c)
  
  if [ "$num_pontos" -eq 2 ]; then
    # Formato hh:mm:ss
    horas=$(echo "$tempo" | cut -d: -f1 | sed 's/^0*//')
    horas=${horas:-0}
    minutos=$(echo "$tempo" | cut -d: -f2 | sed 's/^0*//')
    minutos=${minutos:-0}
    segundos=$(echo "$tempo" | cut -d: -f3 | sed 's/^0*//')
    segundos=${segundos:-0}
  elif [ "$num_pontos" -eq 1 ]; then
    # Formato mm:ss
    minutos=$(echo "$tempo" | cut -d: -f1 | sed 's/^0*//')
    minutos=${minutos:-0}
    segundos=$(echo "$tempo" | cut -d: -f2 | sed 's/^0*//')
    segundos=${segundos:-0}
  else
    # Formato ss
    segundos=$(echo "$tempo" | sed 's/^0*//')
    segundos=${segundos:-0}
  fi
  
  # Calcula segundos totais
  echo "$horas * 3600 + $minutos * 60 + $segundos" | bc
}

# Converte o tempo final para segundos
NOVO_TEMPO=$(converter_para_segundos "$TEMPO_FINAL")

# Obtém a duração do vídeo com ffprobe
DURACAO=$(ffprobe -v error -select_streams v:0 -show_entries format=duration -of csv=p=0 "$ARQUIVO")

# Formata a duração para hh:mm:ss
formatar_tempo() {
  local total_segundos="$1"
  local horas=$(echo "$total_segundos / 3600" | bc)
  local minutos=$(echo "($total_segundos % 3600) / 60" | bc)
  local segundos=$(echo "$total_segundos % 60" | bc)
  
  printf "%02d:%02d:%05.2f" "$horas" "$minutos" "$segundos"
}

DURACAO_FORMATADA=$(formatar_tempo "$DURACAO")

echo "Duração original: $DURACAO_FORMATADA (${DURACAO} segundos)"

# Verifica se o tempo final é válido
if (( $(echo "$NOVO_TEMPO <= 0" | bc -l) )); then
  echo "Erro: o tempo final deve ser maior que zero."
  exit 1
fi

if (( $(echo "$NOVO_TEMPO > $DURACAO" | bc -l) )); then
  echo "Erro: o tempo final ($TEMPO_FINAL) é maior que a duração do vídeo ($DURACAO_FORMATADA)."
  exit 1
fi

NOVO_TEMPO_FORMATADO=$(formatar_tempo "$NOVO_TEMPO")
echo "Novo tempo final: $NOVO_TEMPO_FORMATADO (${NOVO_TEMPO} segundos)"

# Executa o corte com ffmpeg
echo "Cortando vídeo... Aguarde."
ffmpeg -i "$ARQUIVO" -t "$NOVO_TEMPO" -c copy "$ARQUIVO_SAIDA" 2>/dev/null

if [ $? -eq 0 ]; then
  echo "================================================================================"
  echo "SUCESSO! Vídeo cortado salvo como: $ARQUIVO_SAIDA"
  echo "Tempo final: $NOVO_TEMPO_FORMATADO"
  echo "================================================================================"
else
  echo "Erro: Falha ao processar o vídeo. Verifique se o arquivo existe e é um vídeo válido."
  exit 1
fi
