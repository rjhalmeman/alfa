#!/bin/bash

# Script para baixar e instalar a última versão do VS Code

echo "📥 Baixando a última versão do VS Code..."
wget -O vscode_latest.deb https://update.code.visualstudio.com/latest/linux-deb-x64/stable

# Verifica se o download foi bem-sucedido
if [ $? -eq 0 ]; then
    echo "✅ Download concluído com sucesso!"
    
    echo "⚙️ Instalando o VS Code..."
    sudo dpkg -i vscode_latest.deb
    
    # Verifica se a instalação foi bem-sucedida
    if [ $? -eq 0 ]; then
        echo "✅ Instalação concluída com sucesso!"
        
        echo "🗑️ Removendo o arquivo .deb..."
        rm vscode_latest.deb
        
        echo "✅ Arquivo .deb removido. Limpeza concluída!"
        echo "🎉 VS Code atualizado com sucesso!"
    else
        echo "❌ Erro na instalação do VS Code."
        echo "📌 O arquivo .deb não foi removido para debug."
        exit 1
    fi
else
    echo "❌ Falha no download do VS Code."
    echo "📌 Verifique sua conexão com a internet."
    exit 1
fi
