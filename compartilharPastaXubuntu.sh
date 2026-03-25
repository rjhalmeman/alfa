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

echo "============================================="
echo "⚙️  Iniciando a configuração..."
echo "============================================="

# 1. Cria a pasta PRIMEIRO (para garantir que o sistema a encontre)
mkdir -p "$PASTA"

# 2. Agora sim, pega o caminho absoluto com segurança
CAMINHO_ABSOLUTO=$(realpath "$PASTA")
NOME_COMPARTILHAMENTO=$(basename "$CAMINHO_ABSOLUTO")

# 3. Trava de segurança: se o nome estiver vazio, cancela tudo!
if [ -z "$NOME_COMPARTILHAMENTO" ]; then
    echo "❌ Erro fatal: O nome do compartilhamento ficou vazio. Cancelando para proteger o Samba."
    exit 1
fi

echo "📂 Caminho resolvido: $CAMINHO_ABSOLUTO"
echo "📛 Nome na rede: $NOME_COMPARTILHAMENTO"
echo "👤 Usuário liberado: $USUARIO"
echo "---------------------------------------------"

# 4. Ajustar permissões do Linux
sudo chown -R "$USUARIO:$USUARIO" "$CAMINHO_ABSOLUTO"
sudo chmod -R 775 "$CAMINHO_ABSOLUTO"

# 5. Backup e inserção no arquivo do Samba
sudo cp /etc/samba/smb.conf /etc/samba/smb.conf.backup

echo "
[$NOME_COMPARTILHAMENTO]
path = $CAMINHO_ABSOLUTO
valid users = $USUARIO
read only = no
browsable = yes
" | sudo tee -a /etc/samba/smb.conf > /dev/null

# 6. Senha da rede para o usuário (pode colocar a mesma de antes)
echo "🔑 Confirme ou crie a senha de rede para o usuário $USUARIO:"
sudo smbpasswd -a "$USUARIO"

# 7. Liberar Firewall e reiniciar Samba
sudo ufw allow samba
sudo systemctl restart smbd nmbd

# Pega o IP atual
MEU_IP=$(hostname -I | awk '{print $1}')

echo "============================================="
echo "✅ TUDO PRONTO COM SUCESSO!"
echo "No Computador R (Mint), abra o Thunar, aperte Ctrl+L e digite:"
echo "👉 smb://$MEU_IP/$NOME_COMPARTILHAMENTO"
echo "============================================="
