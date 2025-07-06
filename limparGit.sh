#!/bin/bash

# Verifica se foi passado o nome da branch
if [ -z "$1" ]; then
    echo "Uso: ./inicializa_branch.sh <nome-da-branch>"
    exit 1
fi

branch="$1"
remote_url="https://github.com/rjhalmeman/alfa.git"

# Remove pasta .git antiga (se existir)
if [ -d ".git" ]; then
    echo "Removendo .git antigo..."
    rm -rf .git
fi

# Inicializa novo repositório Git
git init

# Adiciona repositório remoto
git remote add origin "$remote_url"

# Cria e muda para a nova branch
git checkout -b "$branch"

# Adiciona todos os arquivos
git add .

# Commit inicial com timestamp
timestamp=$(date +"%d/%m/%Y - %H:%M:%S")
git commit -m "Início do $branch - $timestamp"

# Envia para o GitHub
git push -u origin "$branch" --force

echo "Branch '$branch' criada e enviada com sucesso!"

