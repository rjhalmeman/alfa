#!/bin/bash

# Uso: ./getProjeto.sh URL_GIT NOME_BRANCH

URL=$1
BRANCH=$2

if [ -z "$URL" ] || [ -z "$BRANCH" ]; then
    echo "Erro: Faltam argumentos."
    echo "Uso: ./getProjeto.sh https://github.com/usuario/repo nomeDaBranch"
    exit 1
fi

NOME_REPO=$(basename "$URL" .git)

if [ -d "$NOME_REPO" ]; then
    echo "Pasta $NOME_REPO já existe. Atualizando..."
    cd "$NOME_REPO" || exit
    git fetch origin
    git checkout "$BRANCH" || git checkout -b "$BRANCH"
    git pull origin "$BRANCH"
else
    echo "Clonando $NOME_REPO..."
    git clone "$URL"
    cd "$NOME_REPO" || exit
    git checkout -b "$BRANCH"
fi

echo "Pronto! Você está na branch '$BRANCH' dentro da pasta '$NOME_REPO'."
