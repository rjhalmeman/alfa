#!/bin/bash

# Script para converter Markdown para PDF com suporte a emojis e Unicode
# Uso: ./md2pdf.sh origem.md destino.pdf

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Função para verificar e instalar dependências
check_and_install_deps() {
    local deps_missing=0
    
    # Verificar se pandoc está instalado
    if ! command -v pandoc &> /dev/null; then
        echo -e "${YELLOW}📦 Pandoc não encontrado. Instalando...${NC}"
        sudo apt update
        sudo apt install -y pandoc texlive-xetex texlive-fonts-recommended
        if [ $? -ne 0 ]; then
            echo -e "${RED}❌ Erro ao instalar Pandoc. Tente manualmente:${NC}"
            echo "   sudo apt install pandoc texlive-xetex texlive-fonts-recommended"
            exit 1
        fi
        echo -e "${GREEN}✅ Pandoc instalado com sucesso!${NC}"
    fi
    
    # Verificar se a fonte DejaVu Sans está disponível
    if ! fc-list | grep -qi "DejaVu Sans"; then
        echo -e "${YELLOW}⚠️  Fonte DejaVu Sans não encontrada. Instalando...${NC}"
        sudo apt install -y fonts-dejavu
        if [ $? -ne 0 ]; then
            echo -e "${YELLOW}⚠️  Não foi possível instalar DejaVu Sans. Usando fonte padrão.${NC}"
            FONT=""
        else
            echo -e "${GREEN}✅ Fonte DejaVu Sans instalada!${NC}"
            FONT="-V mainfont=\"DejaVu Sans\""
        fi
    else
        FONT="-V mainfont=\"DejaVu Sans\""
    fi
}

# Função para mostrar uso correto
show_usage() {
    echo -e "${YELLOW}Uso: $0 <arquivo_origem.md> <arquivo_destino.pdf>${NC}"
    echo ""
    echo "Exemplos:"
    echo "  $0 documento.md documento.pdf"
    echo "  $0 Avaliação-1º-Bimestre.md Avaliacao1BimPI.pdf"
    echo ""
    echo "OBS: O arquivo PDF será salvo na mesma pasta do arquivo Markdown de origem."
}

# Verificar argumentos
if [ $# -ne 2 ]; then
    echo -e "${RED}❌ Erro: Número incorreto de argumentos${NC}"
    show_usage
    exit 1
fi

SOURCE_FILE="$1"
PDF_FILE="$2"

# Verificar se arquivo de origem existe
if [ ! -f "$SOURCE_FILE" ]; then
    echo -e "${RED}❌ Erro: Arquivo de origem '$SOURCE_FILE' não encontrado!${NC}"
    exit 1
fi

# Verificar extensão do arquivo de origem
if [[ ! "$SOURCE_FILE" =~ \.md$ ]]; then
    echo -e "${YELLOW}⚠️  Aviso: O arquivo de origem não tem extensão .md${NC}"
fi

# Verificar extensão do arquivo de destino
if [[ ! "$PDF_FILE" =~ \.pdf$ ]]; then
    echo -e "${RED}❌ Erro: O arquivo de destino deve ter extensão .pdf${NC}"
    echo "   Exemplo: documento.pdf"
    exit 1
fi

# Verificar e instalar dependências
check_and_install_deps

# Extrair o diretório do arquivo de origem
SOURCE_DIR=$(dirname "$SOURCE_FILE")
SOURCE_BASENAME=$(basename "$SOURCE_FILE")

# Se o destino não contiver caminho, usar o mesmo diretório da origem
if [[ "$PDF_FILE" != /* ]] && [[ "$PDF_FILE" != ./* ]] && [[ "$PDF_FILE" != ../* ]]; then
    # É apenas um nome de arquivo, sem caminho
    PDF_FILE="$SOURCE_DIR/$PDF_FILE"
    echo -e "${GREEN}📁 Salvando PDF em: $PDF_FILE${NC}"
fi

# Garantir que o diretório de destino existe
PDF_DIR=$(dirname "$PDF_FILE")
if [ ! -d "$PDF_DIR" ]; then
    echo -e "${YELLOW}📁 Criando diretório: $PDF_DIR${NC}"
    mkdir -p "$PDF_DIR"
fi

# Executar a conversão
echo -e "${GREEN}🔄 Convertendo $SOURCE_FILE para $PDF_FILE...${NC}"
echo -e "${GREEN}🔧 Usando motor XeLaTeX com fonte DejaVu Sans${NC}"

# Construir comando pandoc
PANDOC_CMD="pandoc \"$SOURCE_FILE\" -o \"$PDF_FILE\" --pdf-engine=xelatex $FONT"

# Executar
eval $PANDOC_CMD

# Verificar resultado
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Conversão concluída com sucesso!${NC}"
    echo -e "${GREEN}📄 PDF gerado: $PDF_FILE${NC}"
    
    # Mostrar tamanho do arquivo
    if [ -f "$PDF_FILE" ]; then
        SIZE=$(du -h "$PDF_FILE" | cut -f1)
        echo -e "${GREEN}📊 Tamanho: $SIZE${NC}"
    fi
else
    echo -e "${RED}❌ Erro na conversão. Verifique se:${NC}"
    echo "   1. O arquivo Markdown está bem formatado"
    echo "   2. Não há caracteres especiais problemáticos"
    echo "   3. Você tem espaço em disco suficiente"
    echo ""
    echo -e "${YELLOW}💡 Tente remover emojis problemáticos ou use o comando manual:${NC}"
    echo "   pandoc \"$SOURCE_FILE\" -o \"$PDF_FILE\" --pdf-engine=xelatex -V mainfont=\"FreeSerif\""
    exit 1
fi
