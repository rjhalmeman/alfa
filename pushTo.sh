#!/bin/bash

# Nome padrão do repositório remoto
default_remote="https://github.com/rjhalmeman/alfa"

# Verifica se o git está instalado
if ! command -v git &> /dev/null
then
    echo "O Git não está instalado. Por favor, instale o Git antes de continuar."
    exit 1
fi

# Verifica se o nome da branch foi passado como argumento
if [ -z "$1" ]; then
    echo "Erro: informe o nome da branch como argumento."
    exit 1
fi

branch="$1"

# Adiciona o repositório remoto se ainda não estiver adicionado
if ! git remote get-url origin &> /dev/null; then
    git remote add origin "$default_remote"
fi

# Verifica se a branch já existe localmente ou remotamente
if git show-ref --verify --quiet "refs/heads/$branch" || git ls-remote --exit-code --heads origin "$branch" &> /dev/null; then
    echo "A branch '$branch' já existe."
    read -p "Deseja apenas fazer o push para ela? (s/n): " resposta
    if [[ "$resposta" != "s" && "$resposta" != "S" ]]; then
        echo "Operação cancelada."
        exit 1
    fi
    # Muda para a branch existente
    git checkout "$branch"
else
    # Cria e muda para a nova branch
    git checkout -b "$branch"
fi

# Adiciona todas as alterações ao índice do Git
git add .

# Obtém a data e hora atual e formata para o formato desejado
timestamp=$(date +"%d/%m/%Y - %H:%M:%S")

# Realiza um commit com a mensagem contendo a data e hora
git commit -m "$timestamp"

# Faz push para o repositório remoto
git push -u origin "$branch"

