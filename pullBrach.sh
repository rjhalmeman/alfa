#!/bin/bash

# Verifica se o repositório Git está inicializado
if [ ! -d ".git" ]; then
    echo "❌ Este não parece ser um repositório Git. Saindo..."
    exit 1
fi

# Busca todas as branches remotas
echo "🔄 Buscando todas as branches remotas..."
git fetch --all

# Lista as branches remotas disponíveis
echo "📋 Branches remotas disponíveis:"
git branch -r

# Pede para o usuário digitar o nome da branch desejada
echo "Digite o nome da branch remota que deseja criar localmente: "
read NOME_BRANCH

# Verifica se o nome da branch foi digitado
if [ -z "$NOME_BRANCH" ]; then
    echo "❌ Nenhuma branch foi informada. Saindo..."
    exit 1
fi

# Verifica se a branch remota existe
if ! git branch -r | grep -q "origin/$NOME_BRANCH"; then
    echo "❌ Branch '$NOME_BRANCH' não encontrada nas branches remotas. Saindo..."
    exit 1
fi

# Cria a branch local com base na remota e faz o checkout
echo "🌱 Criando branch local '$NOME_BRANCH' a partir de 'origin/$NOME_BRANCH'..."
git checkout -b "$NOME_BRANCH" "origin/$NOME_BRANCH"

echo "✅ Branch '$NOME_BRANCH' criada e ativada com sucesso!"
