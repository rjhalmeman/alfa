#!/bin/bash

# Script completo para atualizar Google Chrome com verificação de necessidade
# Salve este arquivo como update_chrome_complete.sh

echo "=========================================="
echo "Atualizador Avançado do Google Chrome"
echo "=========================================="

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar se é root
check_root() {
    if [ "$EUID" -ne 0 ]; then 
        echo -e "${RED}Este script requer privilégios de superusuário.${NC}"
        echo -e "${YELLOW}Por favor, execute com: sudo ./$(basename "$0")${NC}"
        exit 1
    fi
}

# Função para verificar conexão com a internet
check_internet() {
    echo -e "${YELLOW}Verificando conexão com a internet...${NC}"
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${RED}Sem conexão com a internet!${NC}"
        exit 1
    fi
    echo -e "${GREEN}Conexão OK${NC}"
}

# Função para verificar versão atual
get_current_version() {
    if command -v google-chrome-stable &> /dev/null; then
        current_version=$(google-chrome-stable --version | awk '{print $3}')
        echo "$current_version"
    else
        echo "0"
    fi
}

# Função principal
main() {
    check_root
    check_internet
    
    # Configurações
    CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    DEB_FILE="/tmp/google-chrome-stable_current_amd64.deb"
    BACKUP_DIR="/tmp/chrome_backup_$(date +%Y%m%d_%H%M%S)"
    
    # Versão atual
    echo -e "\n${YELLOW}Verificando versão atual...${NC}"
    current_version=$(get_current_version)
    
    if [ "$current_version" != "0" ]; then
        echo -e "Versão atual: ${GREEN}$current_version${NC}"
    else
        echo -e "${YELLOW}Google Chrome não está instalado. Será instalado pela primeira vez.${NC}"
    fi
    
    # Baixar nova versão
    echo -e "\n${YELLOW}Baixando versão mais recente...${NC}"
    wget -O "$DEB_FILE" "$CHROME_URL" 2>&1 | \
        grep --line-buffered -o "[0-9]*%" | \
        xargs -L1 echo -ne "\rProgresso: "

    if [ $? -ne 0 ]; then
        echo -e "\n${RED}Erro ao baixar o Google Chrome!${NC}"
        exit 1
    fi
    
    echo -e "\n${GREEN}Download concluído!${NC}"
    
    # Obter versão do arquivo baixado
    echo -e "\n${YELLOW}Extraindo informação da versão...${NC}"
    new_version=$(dpkg-deb -f "$DEB_FILE" Version | cut -d'-' -f1)
    echo -e "Nova versão disponível: ${GREEN}$new_version${NC}"
    
    # Verificar se precisa atualizar
    if [ "$current_version" == "$new_version" ]; then
        echo -e "\n${GREEN}Você já tem a versão mais recente!${NC}"
        rm -f "$DEB_FILE"
        exit 0
    fi
    
    # Parar processos Chrome
    echo -e "\n${YELLOW}Parando processos do Chrome...${NC}"
    pkill -f chrome 2>/dev/null && echo -e "Processos Chrome finalizados." || echo -e "Nenhum processo Chrome em execução."
    
    # Instalar
    echo -e "\n${YELLOW}Instalando nova versão...${NC}"
    dpkg -i "$DEB_FILE"
    
    if [ $? -ne 0 ]; then
        echo -e "\n${YELLOW}Corrigindo dependências...${NC}"
        apt update
        apt install -f -y
    fi
    
    # Limpar
    echo -e "\n${YELLOW}Limpando arquivos temporários...${NC}"
    rm -f "$DEB_FILE"
    
    # Resultado
    echo -e "\n${GREEN}==========================================${NC}"
    echo -e "${GREEN}Google Chrome atualizado com sucesso!${NC}"
    echo -e "${GREEN}==========================================${NC}"
    
    echo -e "\n${YELLOW}Resumo da atualização:${NC}"
    echo -e "Versão anterior: ${YELLOW}$current_version${NC}"
    echo -e "Versão atual:    ${GREEN}$(get_current_version)${NC}"
}

# Executar função principal
main "$@"
