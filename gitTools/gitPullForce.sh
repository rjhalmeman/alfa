#!/bin/bash

# Script para SOBRESCREVER o repositório local com o remoto
# Uso: ./gitPullForce.sh [nome-da-branch]

# Define a branch a ser usada
if [ -z "$1" ]; then
    BRANCH="main"
    echo "Nenhuma branch especificada. Usando branch padrão: main"
else
    BRANCH="$1"
    echo "Branch especificada: $BRANCH"
fi

# Exibe aviso instrutivo
echo ""
echo "=========================================="
echo "AVISO: Este script irá SOBRESCREVER completamente"
echo "seu repositório LOCAL com o conteúdo do REMOTO."
echo ""
echo "Isso irá:"
echo "  - Descartar TODAS as alterações locais não commitadas"
echo "  - Remover commits locais que não estejam no remoto"
echo "  - Substituir todos os arquivos locais pela versão do GitHub"
echo ""
echo "Branch alvo: $BRANCH"
echo "Origem: origin/$BRANCH"
echo "=========================================="
echo ""

# Solicita confirmação
read -p "Tem certeza que deseja continuar? (s/N): " CONFIRMACAO

# Verifica confirmação (aceita s, S, sim, SIM, etc)
if [[ "$CONFIRMACAO" =~ ^[Ss]([im])?$ ]]; then
    echo ""
    echo "Executando: git fetch --all && git reset --hard origin/$BRANCH"
    echo ""
    
    # Executa os comandos git
    git fetch --all && git reset --hard "origin/$BRANCH"
    
    # Verifica se a operação foi bem sucedida
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Operação concluída com sucesso!"
        echo "Seu repositório local agora está idêntico a origin/$BRANCH"
    else
        echo ""
        echo "❌ Erro durante a operação. Verifique se a branch '$BRANCH' existe no repositório remoto."
        exit 1
    fi
else
    echo ""
    echo "❌ Operação cancelada pelo usuário."
    echo "Nenhuma alteração foi feita."
    exit 0
fi
