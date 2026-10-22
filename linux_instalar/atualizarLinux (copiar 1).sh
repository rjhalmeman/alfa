#!/bin/bash

# ===============================================
# Script de Manutenção e Limpeza do Linux Mint
# ===============================================

echo "Iniciando a manutenção do sistema..."

# 1. ATUALIZAR LISTA DE PACOTES
echo -e "\n---> 1. Atualizando a lista de pacotes (apt update)..."
sudo apt update

# Verifica o código de saída do comando anterior. Se for 0, continua.
if [ $? -eq 0 ]; then
    # 2. ATUALIZAR PACOTES E INSTALAR NOVAS DEPENDÊNCIAS
    echo -e "\n---> 2. Verificando e instalando atualizações (apt upgrade)..."
    sudo apt upgrade -y

    # 3. ATUALIZAÇÃO COMPLETA DO SISTEMA (full-upgrade)
    echo -e "\n---> 3. Atualização completa do sistema (apt full-upgrade)..."
    sudo apt full-upgrade -y

    # 4. ATUALIZAR SNAPS (se estiverem instalados)
    if command -v snap &> /dev/null; then
        echo -e "\n---> 4. Atualizando pacotes Snap..."
        sudo snap refresh
    fi

    # 5. ATUALIZAR FLATPAKS (se estiverem instalados)
    if command -v flatpak &> /dev/null; then
        echo -e "\n---> 5. Atualizando pacotes Flatpak..."
        flatpak update -y
    fi

    # 6. ATUALIZAR FIRMWARE DO SISTEMA
    echo -e "\n---> 6. Verificando atualizações de firmware..."
    if command -v fwupdmgr &> /dev/null; then
        sudo fwupdmgr refresh --force
        sudo fwupdmgr update
    fi

    # 7. REMOVER PACOTES E DEPENDÊNCIAS DESNECESSÁRIAS
    echo -e "\n---> 7. Removendo pacotes e dependências desnecessárias (autoremove)..."
    sudo apt autoremove -y --purge

    # 8. LIMPAR CACHE DE PACOTES
    echo -e "\n---> 8. Limpando o cache local de pacotes..."
    sudo apt autoclean
    sudo apt clean

    # 9. LIMPAR CACHE DE ARQUIVOS TEMPORÁRIOS
    echo -e "\n---> 9. Limpando arquivos temporários..."
    sudo rm -rf /tmp/*
    sudo rm -rf /var/tmp/*

    # 10. LIMPAR LOGS ANTIGOS
    echo -e "\n---> 10. Limpando logs antigos..."
    sudo journalctl --vacuum-time=7d

    # 11. VERIFICAR E CORRIGIR PACOTES QUEBRADOS
    echo -e "\n---> 11. Verificando e corrigindo pacotes quebrados..."
    sudo apt --fix-broken install -y
    sudo dpkg --configure -a

    # 12. LIMPAR CACHE DO SISTEMA
    echo -e "\n---> 12. Limpando cache do sistema..."
    sudo sync
    echo 3 | sudo tee /proc/sys/vm/drop_caches > /dev/null

    echo -e "\n✅ Manutenção concluída com sucesso!"
    echo -e "\n📊 Resumo das operações realizadas:"
    echo "   ✓ Atualização de repositórios"
    echo "   ✓ Upgrade de pacotes APT"
    echo "   ✓ Upgrade completo do sistema"
    echo "   ✓ Atualização de Snaps (se aplicável)"
    echo "   ✓ Atualização de Flatpaks (se aplicável)"
    echo "   ✓ Atualização de firmware (se aplicável)"
    echo "   ✓ Remoção de pacotes desnecessários"
    echo "   ✓ Limpeza de cache de pacotes"
    echo "   ✓ Limpeza de arquivos temporários"
    echo "   ✓ Limpeza de logs antigos"
    echo "   ✓ Correção de pacotes quebrados"
    echo "   ✓ Limpeza de cache do sistema"
    
else
    echo -e "\n❌ Erro ao executar 'apt update'. A manutenção foi interrompida."
    exit 1
fi

# Limpa o terminal para uma saída limpa
echo -e "\n"
