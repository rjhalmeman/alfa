#!/bin/bash

# Verifica se o parâmetro foi fornecido
if [ $# -eq 0 ]; then
    echo "Erro: Nome do repositório não informado."
    echo "Uso: $0 <nome-do-repositorio>"
    exit 1
fi

REPO_NAME="$1"

# Cria o diretório com o nome do repositório
mkdir -p "$REPO_NAME"
if [ $? -ne 0 ]; then
    echo "Erro ao criar o diretório '$REPO_NAME'. Verifique as permissões ou se o diretório já existe."
    exit 1
fi

# Navega para o diretório criado
cd "$REPO_NAME"

echo "Clonando repositório $REPO_NAME e todas as branches..."

# Clone o repositório
git clone "https://github.com/rjhalmeman/$REPO_NAME.git" .
if [ $? -ne 0 ]; then
    echo "Erro ao clonar o repositório. Verifique a URL e suas permissões."
    exit 1
fi

# Configurar todas as branches
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
git --no-pager branch -a

echo ""
echo "Para alternar para uma branch específica, use: git checkout <nome-da-branch>"
echo ""
echo "Você está no diretório: $(pwd)"