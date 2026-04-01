#!/bin/bash

# ==========================================
# Script para Remover Compartilhamento (Samba)
# ==========================================

# 1. Verifica se o usuário passou o parâmetro obrigatório
if [ "$#" -ne 1 ]; then
    echo "❌ Erro: Faltam parâmetros."
    echo ""
    echo "Uso correto:"
    echo "  ./descompartilhe.sh <Caminho_da_Pasta>"
    echo ""
    echo "Exemplo:"
    echo "  ./descompartilhe.sh /home/joao/Publico"
    exit 1
fi

CAMINHO_PASTA="$1"
# O nome do compartilhamento gerado no script anterior foi baseado no nome da pasta
NOME_COMPARTILHAMENTO=$(basename "$CAMINHO_PASTA")
ARQUIVO_CONF="/etc/samba/smb.conf"

echo "===================================================="
echo "Iniciando a remoção do compartilhamento de rede"
echo "Pasta alvo: $CAMINHO_PASTA"
echo "Nome na rede: [$NOME_COMPARTILHAMENTO]"
echo "===================================================="

# 2. Verifica se o Samba está instalado/configurado
if [ ! -f "$ARQUIVO_CONF" ]; then
    echo "❌ Erro: O arquivo do Samba ($ARQUIVO_CONF) não foi encontrado."
    echo "Parece que o Samba não está instalado neste computador."
    exit 1
fi

# 3. Verifica se o compartilhamento realmente existe no arquivo smb.conf
if ! grep -q "^\[$NOME_COMPARTILHAMENTO\]" "$ARQUIVO_CONF"; then
    echo "⚠️  O compartilhamento [$NOME_COMPARTILHAMENTO] não foi encontrado."
    echo "Nenhuma alteração foi feita, ele já não está compartilhado."
    exit 0
fi

echo "⚙️  Removendo o acesso de rede da pasta (pode pedir sua senha root)..."

# 4. Remove com segurança apenas o bloco do compartilhamento específico
# Este comando copia tudo, exceto o bloco do nosso compartilhamento, para um arquivo temporário.
sudo awk -v share="[$NOME_COMPARTILHAMENTO]" '
$0 == share { skip = 1; next }
/^\[.*\]/ && skip { skip = 0 }
!skip { print }
' "$ARQUIVO_CONF" | sudo tee /tmp/smb_clean.conf > /dev/null

# Substitui o arquivo original pelo arquivo limpo
sudo mv /tmp/smb_clean.conf "$ARQUIVO_CONF"

# 5. Reinicia os serviços para aplicar a remoção imediatamente
echo "🔄 Aplicando as mudanças no Samba..."
sudo systemctl restart smbd nmbd

echo ""
echo "===================================================="
echo "✅ Compartilhamento removido com sucesso!"
echo "A pasta '$CAMINHO_PASTA' não está mais acessível pela rede."
echo "Nota: Seus arquivos locais e a pasta continuam intactos no seu PC."
echo "===================================================="
