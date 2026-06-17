#!/bin/bash

# Uso: ./postProjeto.sh ./nomePastaRepositorio

PASTA=$1

if [ -z "$PASTA" ]; then
    echo "Erro: Informe a pasta do repositório."
    exit 1
fi

cd "$PASTA" || exit

echo "Preparando o commit..."
git add .

# Pergunta uma mensagem de commit se não for fornecida
read -p "Digite a mensagem do commit: " MSG
git commit -m "$MSG"

echo "Enviando alterações para o servidor..."
BRANCH_ATUAL=$(git branch --show-current)
git push origin "$BRANCH_ATUAL"

# Verifica se o GH está instalado
if command -v gh &> /dev/null; then
    echo "Criando Pull Request via GitHub CLI..."
    gh pr create --fill
else
    echo "------------------------------------------------------------"
    echo "ATENÇÃO: GitHub CLI (gh) não encontrado."
    echo "Instale com: sudo apt install gh"
    echo "Ou crie seu Pull Request manualmente em:"
    git remote get-url origin | sed 's/git@github.com:/https:\/\/github.com\//' | sed 's/.git$//' | awk '{print $1 "/pull/new/'$BRANCH_ATUAL'"}'
    echo "------------------------------------------------------------"
fi
