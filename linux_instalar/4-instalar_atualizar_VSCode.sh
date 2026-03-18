#!/bin/bash

# Script para instalar/atualizar Visual Studio Code (VS Code)
# Salve como: instalar-atualizarVSCode.sh

echo "=========================================="
echo "Instalador/Atualizador do VS Code"
echo "=========================================="

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função para verificar se é root e exibir instrução de uso
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}Erro: Você precisa de privilégios de administrador.${NC}"
        echo -e "${YELLOW}Como usar:${NC}"
        echo -e "  1. Dê permissão: ${GREEN}chmod +x instalar-atualizarVSCode.sh${NC}"
        echo -e "  2. Execute:      ${GREEN}sudo ./instalar-atualizarVSCode.sh${NC}"
        exit 1
    fi
}

# Verificação de internet mais robusta
check_internet() {
    echo -e "${YELLOW}Verificando conexão...${NC}"
    # Tenta pingar o IP do DNS do Google (mais confiável que DNS de domínios específicos)
    if ! ping -c 1 8.8.8.8 &> /dev/null; then
        echo -e "${RED}O sistema reportou que não há conexão com a internet!${NC}"
        echo -e "Verifique seu cabo/Wi-Fi ou DNS."
        exit 1
    fi
    echo -e "${GREEN}Conexão OK!${NC}"
}

get_current_version() {
    if command -v code &> /dev/null; then
        code --version | head -n 1
    else
        echo "0"
    fi
}

main() {
    check_root
    check_internet

    # 1. Verificar versão atual
    current_version=$(get_current_version)
    if [ "$current_version" != "0" ]; then
        echo -e "Versão instalada: ${GREEN}$current_version${NC}"
    else
        echo -e "${YELLOW}VS Code não detectado. Será instalado do zero.${NC}"
    fi

    # 2. Instalar dependências
    echo -e "\n${YELLOW}Preparando ambiente (apt update)...${NC}"
    apt update && apt install -y wget gpg apt-transport-https

    # 3. Configurar Repositório Microsoft
    echo -e "${YELLOW}Configurando chaves e fontes da Microsoft...${NC}"
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor --yes -o /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > /etc/apt/sources.list.d/vscode.list

    # 4. Atualizar e Instalar
    echo -e "${YELLOW}Buscando versão mais recente...${NC}"
    apt update
    
    new_version=$(apt-cache policy code | grep Candidate | awk '{print $2}' | cut -d'-' -f1)

    if [ "$current_version" == "$new_version" ] && [ "$current_version" != "0" ]; then
        echo -e "\n${GREEN}O VS Code já está na versão mais atual ($new_version).${NC}"
        exit 0
    fi

    echo -e "\n${YELLOW}Baixando e instalando VS Code ($new_version)...${NC}"
    apt install -y code

    # 5. Resultado
    final_version=$(get_current_version)
    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN}Sucesso! VS Code pronto para uso.${NC}"
    echo -e "Versão: ${GREEN}$final_version${NC}"
    echo -e "Comando para abrir: ${CYAN}code${NC}"
    echo -e "${GREEN}==========================================${NC}"
}

main "$@"
