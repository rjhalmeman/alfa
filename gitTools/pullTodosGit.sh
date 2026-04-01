#!/bin/bash

# Verifica se a pasta contém subpastas com repositórios Git
for dir in */; do
    if [ -d "$dir/.git" ]; then
        echo "Atualizando repositório em $dir"
        (cd "$dir" && git pull)
    else
        echo "$dir não é um repositório Git, ignorando..."
    fi
done

echo "Atualização concluída."