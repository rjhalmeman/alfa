#!/bin/bash

echo "Instalando VS Code via Snap..."
sudo snap install code --classic

if [ $? -eq 0 ]; then
    echo "✅ VS Code instalado com sucesso!"
    echo "Execute com: code"
else
    echo "❌ Erro na instalação."
fi