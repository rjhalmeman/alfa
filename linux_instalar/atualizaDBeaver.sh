#!/bin/bash

# Script para baixar e instalar a versão mais recente do DBeaver CE
# Salve este arquivo como update_dbeaver_auto.sh

echo "====================================="
echo "Atualizador Automático do DBeaver CE"
echo "====================================="

# Verificar se o script está sendo executado como root/sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Este script requer privilégios de superusuário."
    echo "Por favor, execute com: sudo ./update_dbeaver_auto.sh"
    exit 1
fi

# URL de download do DBeaver CE (ajustar conforme versão mais recente)
# Verifique a versão atual em: https://dbeaver.io/download/
DBeAVER_URL="https://dbeaver.io/files/dbeaver-ce_latest_amd64.deb"
DEB_FILE="dbeaver-ce_latest_amd64.deb"

echo "Baixando a versão mais recente do DBeaver CE..."
wget -O "$DEB_FILE" "$DBeAVER_URL"

if [ $? -ne 0 ]; then
    echo "Erro ao baixar o DBeaver. Verifique sua conexão com a internet."
    exit 1
fi

echo "Instalando o pacote..."
dpkg -i "$DEB_FILE"

echo "Corrigindo dependências..."
apt install -f -y

# Limpar arquivo baixado
echo "Limpando arquivo temporário..."
rm -f "$DEB_FILE"

echo "====================================="
echo "DBeaver atualizado com sucesso!"
echo "====================================="
