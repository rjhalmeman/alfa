#!/bin/bash

# Obtém o nome do diretório atual (nome do repositório)
REPO_NAME=$(basename "$PWD")

echo "Clonando repositório $REPO_NAME e todas as branches..."

# Clone o repositório
git clone "https://github.com/rjhalmeman/$REPO_NAME.git" .
if [ $? -ne 0 ]; then
    echo "Erro ao clonar o repositório. Verifique a URL e suas permissões."
    exit 1
fi

# Navegar para o diretório do repositório (já estamos nele devido ao . no clone)
echo "Configurando todas as branches..."

# Buscar todas as referências remotas
git fetch --all

# Criar tracking para todas as branches remotas
for BRANCH in $(git branch -r | grep -v HEAD | sed 's/origin\///'); do
    echo "Configurando branch: $BRANCH"
    git branch --track "$BRANCH" "origin/$BRANCH" 2>/dev/null || true
done

# Verificar a branch main inicialmente
git checkout main 2>/dev/null || git checkout master 2>/dev/null || echo "Não foi possível encontrar main/master"

echo "Processo concluído!"
echo ""
echo "Branches disponíveis:"
git branch -a

echo ""
echo "Para alternar para uma branch específica, use: git checkout nome-da-branch"
