#!/bin/bash

# Script para instalar Snap no Linux Mint removendo o bloqueio
# Execute com privilégios de administrador

echo "=========================================="
echo "Instalador Snap para Linux Mint"
echo "Removendo bloqueio e instalando Snap"
echo "=========================================="

# Verificar se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute este script como root ou com sudo:"
    echo "sudo ./instalar_snap.sh"
    exit 1
fi

# Remover o bloqueio do Snap (caso exista)
echo "Verificando e removendo bloqueios do Snap..."

# Remover política que impede instalação do snapd
if [ -f /etc/apt/preferences.d/nosnap.pref ]; then
    echo "Removendo /etc/apt/preferences.d/nosnap.pref"
    rm /etc/apt/preferences.d/nosnap.pref
fi

# Para versões mais recentes do Linux Mint que usam apt preferences
if [ -f /etc/apt/preferences.d/snapd.pref ]; then
    echo "Removendo /etc/apt/preferences.d/snapd.pref"
    rm /etc/apt/preferences.d/snapd.pref
fi

# Remover qualquer configuração que desabilite o snap
if [ -f /etc/apt/apt.conf.d/00snapd ]; then
    echo "Removendo /etc/apt/apt.conf.d/00snapd"
    rm /etc/apt/apt.conf.d/00snapd
fi

# Atualizar lista de pacotes
echo "Atualizando lista de pacotes..."
apt update

# Instalar o Snapd
echo "Instalando o Snapd..."
apt install -y snapd

# Verificar se a instalação foi bem sucedida
if [ $? -eq 0 ]; then
    echo "Snapd instalado com sucesso!"
else
    echo "Erro na instalação do Snapd."
    echo "Tentando método alternativo..."
    # Tentar forçar instalação se houver conflitos
    apt install -y --fix-broken snapd
fi

# Habilitar o serviço do Snap
echo "Habilitando serviço do Snap..."
systemctl enable --now snapd.socket
systemctl start snapd.socket

# Criar link simbólico para compatibilidade
echo "Criando link simbólico para compatibilidade..."
ln -sf /var/lib/snapd/snap /snap

# Adicionar /snap/bin ao PATH (para sessões futuras)
echo "Configurando PATH..."
if ! grep -q "/snap/bin" /etc/environment; then
    echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/snap/bin"' > /etc/environment
fi

# Configurar PATH para a sessão atual
export PATH="$PATH:/snap/bin"

# Instalar o core do Snap
echo "Instalando core do Snap..."
snap install core

# Aguardar um pouco para o sistema reconhecer
echo "Aguardando inicialização do snap..."
sleep 5

# Verificar instalação
echo "Verificando a instalação..."
snap --version

if [ $? -eq 0 ]; then
    echo "=========================================="
    echo "Snap instalado com sucesso!"
    echo "BLOQUEIO REMOVIDO E INSTALAÇÃO CONCLUÍDA"
    echo "=========================================="
    echo "Comandos úteis:"
    echo "  snap find [aplicativo]  - Procurar aplicativos"
    echo "  snap install [nome]     - Instalar aplicativo"
    echo "  snap list               - Listar aplicativos instalados"
    echo "  snap refresh            - Atualizar aplicativos"
    echo ""
    echo "Exemplos de instalação:"
    echo "  sudo snap install code --classic"
    echo "  sudo snap install spotify"
    echo "  sudo snap install firefox"
    echo "=========================================="
    
    # Mostrar snaps disponíveis
    echo ""
    echo "Alguns snaps populares disponíveis:"
    echo "  - code (Visual Studio Code)"
    echo "  - spotify"
    echo "  - firefox"
    echo "  - chromium"
    echo "  - slack"
    echo "  - telegram-desktop"
else
    echo "Houve um problema na instalação do Snap."
    echo "Recomendo reiniciar o sistema e tentar novamente."
    exit 1
fi

# Testar funcionalidade básica
echo "Testando funcionalidade básica..."
snap list

echo "Instalação completa!"
echo "Recomendo reiniciar o sistema para garantir que todas as alterações tenham efeito."