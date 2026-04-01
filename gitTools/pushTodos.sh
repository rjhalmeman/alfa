#!/bin/bash

# Define a mensagem de commit com a data e hora atual
commit_message=$(date "+%Y-%m-%d %H:%M:%S")

# Itera sobre todas as subpastas no diretório atual
for dir in */; do
    # Verifica se a subpasta é um repositório Git
    if [ -d "$dir/.git" ]; then
        echo "Processando repositório em $dir"
        
        # Entra no diretório
        (cd "$dir" && \
            # Adiciona todos os arquivos alterados
            git add . && \
            # Faz o commit com a mensagem de data e hora
            git commit -m "$commit_message" && \
            # Tenta fazer o push, redirecionando o stderr para /dev/null
            # para evitar que a mensagem de "no remote" seja exibida
            git push 2>/dev/null)
        
        # Verifica o status do comando push
        if [ $? -eq 0 ]; then
            echo "Push bem-sucedido em $dir"
        else
            echo "Aviso: Push falhou em $dir. Verifique se o branch local está rastreando um branch remoto."
        fi
    else
        echo "Aviso: $dir não é um repositório Git, ignorando..."
    fi
done

echo "Processo de atualização de repositórios concluído."