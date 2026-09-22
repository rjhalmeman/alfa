#!/bin/bash

# Verifica se o Git está instalado
if ! command -v git &> /dev/null
then
    echo "O Git não está instalado. Por favor, instale o Git antes de continuar."
    exit 1
fi

# ============================================================
# Configuração do usuário Git
# ============================================================

git_name=$(git config --global user.name)
git_email=$(git config --global user.email)

if [ -z "$git_name" ]; then
    echo ""
    echo "O nome do usuário Git não está configurado."
    read -p "Digite seu nome: " git_name

    if [ -z "$git_name" ]; then
        echo "Nome não informado. Operação cancelada."
        exit 1
    fi

    git config --global user.name "$git_name"
    echo "Nome configurado: $git_name"
fi

if [ -z "$git_email" ]; then
    echo ""
    echo "O e-mail do usuário Git não está configurado."
    read -p "Digite seu e-mail: " git_email

    if [ -z "$git_email" ]; then
        echo "E-mail não informado. Operação cancelada."
        exit 1
    fi

    git config --global user.email "$git_email"
    echo "E-mail configurado: $git_email"
fi

# ============================================================
# Configurações do projeto
# ============================================================

# Obtém o nome da pasta atual
current_folder=$(basename "$PWD")

# Nome do remote
remote_name="origin"

# Nome do branch
branch_name="main"

clear

git status

echo ""
echo "Usuário Git: $git_name <$git_email>"
echo "Remote: $remote_name"
echo "Branch: $branch_name"
echo

# ============================================================
# Configuração do remote
# ============================================================

if ! git remote get-url "$remote_name" &> /dev/null; then
    default_remote="https://github.com/rjhalmeman/$current_folder"

    echo "Adicionando remote: $remote_name -> $default_remote"

    git remote add "$remote_name" "$default_remote"
fi

# ============================================================
# Adiciona todas as alterações
# ============================================================

git add .

# ============================================================
# Cria a mensagem do commit
# ============================================================

timestamp=$(date +"%d/%m/%Y - %H:%M:%S")

if [ $# -eq 0 ]; then
    commit_message="$timestamp"
else
    commit_message="$timestamp - $*"
fi

# ============================================================
# Commit
# ============================================================

git commit -m "$commit_message"

# ============================================================
# Push
# ============================================================

git push "$remote_name" "$branch_name"

