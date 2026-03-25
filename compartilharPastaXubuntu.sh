#!/bin/bash

# Verifica se você digitou a pasta e o usuário
if [ "$#" -ne 2 ]; then
    echo "❌ Erro: Faltam informações."
    echo "Uso correto: ./compartilhar.sh <caminho_da_pasta> <nome_do_usuario>"
    echo "Exemplo: ./compartilhar.sh ./minhaPasta joao"
    exit 1
fi

PASTA=$1
USUARIO=$2

# Converte caminhos como "./pasta" para o caminho absoluto (ex: "/home/user/pasta")
CAMINHO_ABSOLUTO=$(readlink -f "$PASTA")
NOME_COMPARTILHAMENTO=$(basename "$CAMINHO_ABSOLUTO")

echo "============================================="
echo "⚙️  Iniciando a instalação e configuração..."
echo "📂 Pasta: $CAMINHO_ABSOLUTO"
echo "👤 Usuário: $USUARIO"
echo "============================================="

# 1. Instalar o Samba
echo "[1/6] Atualizando sistema e instalando o Samba..."
sudo apt update
sudo apt install -y samba samba-common-bin

# 2. Criar pasta (se não existir) e dar permissões
echo "[2/6] Verificando a pasta e ajustando permissões do Linux..."
mkdir -p "$CAMINHO_ABSOLUTO"
sudo chown -R "$USUARIO:$USUARIO" "$CAMINHO_ABSOLUTO"
sudo chmod -R 775 "$CAMINHO_ABSOLUTO"

# 3. Adicionar configuração no final do arquivo smb.conf
echo "[3/6] Inserindo a pasta no arquivo do Samba..."
# Fazemos um backup rápido por segurança
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

echo "
[$NOME_COMPARTILHAMENTO]
path = $CAMINHO_ABSOLUTO
valid users = $USUARIO
read only = no
browsable = yes
" | sudo tee -a /etc/samba/smb.conf > /dev/null

# 4. Criar a senha da rede para o usuário
echo "[4/6] Hora da senha da rede!"
echo "⚠️ ATENÇÃO: Crie a senha que você usará no Computador R para acessar esta pasta."
sudo smbpasswd -a "$USUARIO"

# 5. Regra de Firewall
echo "[5/6] Garantindo que o Firewall não vai bloquear a conexão..."
sudo ufw allow samba

# 6. Reiniciar os serviços
echo "[6/6] Reiniciando os motores do Samba..."
sudo systemctl restart smbd nmbd

# Pega o IP atual do computador para mostrar na tela final
MEU_IP=$(hostname -I | awk '{print $1}')

echo "============================================="
echo "✅ TUDO PRONTO!"
echo "Vá para o Computador R (Linux Mint), abra o Thunar, aperte Ctrl+L e digite:"
echo "👉 smb://$MEU_IP/$NOME_COMPARTILHAMENTO"
echo "============================================="
