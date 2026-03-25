#!/bin/bash

# ==========================================
# Script de Compartilhamento de Pasta (Samba)
# ==========================================

# 1. Verifica se o usuário passou os dois parâmetros obrigatórios
if [ "$#" -ne 2 ]; then
    echo "❌ Erro: Faltam parâmetros."
    echo ""
    echo "Uso correto:"
    echo "  ./compartilhe.sh <Caminho_da_Pasta> <Nome_do_Usuario>"
    echo ""
    echo "Exemplo:"
    echo "  ./compartilhe.sh /home/joao/Publico joao"
    exit 1
fi

CAMINHO_PASTA="$1"
USUARIO_SAMBA="$2"
NOME_COMPARTILHAMENTO=$(basename "$CAMINHO_PASTA")

echo "===================================================="
echo "Iniciando configuração de compartilhamento de rede"
echo "Pasta: $CAMINHO_PASTA"
echo "Usuário: $USUARIO_SAMBA"
echo "===================================================="

# 2. Verifica e instala as dependências (Samba)
echo "📦 Verificando se o Samba está instalado (pode pedir sua senha root)..."
sudo apt-get update
sudo apt-get install -y samba samba-common-bin

# 3. Verifica se o usuário do sistema existe
if ! id "$USUARIO_SAMBA" &>/dev/null; then
    echo "⚠️  O usuário '$USUARIO_SAMBA' não existe no Linux."
    echo "Criando usuário '$USUARIO_SAMBA' apenas para acesso de rede..."
    sudo useradd -M -s /usr/sbin/nologin "$USUARIO_SAMBA"
fi

# 4. Verifica se a pasta existe. Se não, cria a pasta.
if [ ! -d "$CAMINHO_PASTA" ]; then
    echo "📁 A pasta não existe. Criando diretório $CAMINHO_PASTA..."
    sudo mkdir -p "$CAMINHO_PASTA"
fi

# 5. Ajusta as permissões da pasta para garantir leitura e escrita
echo "🔑 Ajustando permissões de leitura e escrita na pasta..."
sudo chown -R "$USUARIO_SAMBA":"$USUARIO_SAMBA" "$CAMINHO_PASTA"
sudo chmod -R 0777 "$CAMINHO_PASTA"

# 6. Configura o arquivo do Samba (smb.conf)
ARQUIVO_CONF="/etc/samba/smb.conf"

# Verifica se o compartilhamento já existe no arquivo para não duplicar
if grep -q "\[$NOME_COMPARTILHAMENTO\]" "$ARQUIVO_CONF"; then
    echo "⚠️  Atenção: Um compartilhamento chamado [$NOME_COMPARTILHAMENTO] já existe no smb.conf."
else
    echo "⚙️  Adicionando configuração no Samba..."
    # Uso do 'tee -a' resolve o bug das aspas e injeta o texto com segurança
    cat <<EOF | sudo tee -a "$ARQUIVO_CONF" > /dev/null

[$NOME_COMPARTILHAMENTO]
   path = $CAMINHO_PASTA
   valid users = $USUARIO_SAMBA
   read only = no
   browseable = yes
   create mask = 0777
   directory mask = 0777
   force user = $USUARIO_SAMBA
EOF
fi

# 7. Configura a senha de rede (Samba) para o usuário
echo ""
echo "🔐 Atenção: Você precisa definir uma senha de REDE para o usuário '$USUARIO_SAMBA'."
echo "Essa é a senha que será pedida no Windows/Linux ao acessar a pasta."
sudo smbpasswd -a "$USUARIO_SAMBA"
sudo smbpasswd -e "$USUARIO_SAMBA" # Garante que o usuário está ativado

# 8. Libera o Samba no Firewall do Linux Mint (UFW)
echo "🛡️  Configurando o Firewall (UFW) para permitir o Samba..."
sudo ufw allow samba > /dev/null 2>&1

# 9. Reinicia os serviços para aplicar as mudanças
echo "🔄 Reiniciando serviços do Samba..."
sudo systemctl restart smbd nmbd

echo ""
echo "===================================================="
echo "✅ Compartilhamento criado com sucesso!"
echo "Sua pasta '$CAMINHO_PASTA' agora está acessível na rede."
echo ""
echo "Para acessar de outro PC (Windows):"
echo "\\\\$(hostname -I | awk '{print $1}')\\$NOME_COMPARTILHAMENTO"
echo ""
echo "Para acessar de outro PC (Linux):"
echo "smb://$(hostname -I | awk '{print $1}')/$NOME_COMPARTILHAMENTO"
echo "===================================================="
