#!/bin/bash
# vsInstaGZ.sh - Instala o VS Code a partir do arquivo .tar.gz oficial
# Uso: ./vsInstaGZ.sh code-stable-x64-XXXXX.tar.gz

set -e

# ---------- Cores ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ---------- Validação ----------
if [ "$#" -ne 1 ]; then
    echo -e "${RED}Uso: $0 <arquivo.tar.gz>${NC}"
    echo "Exemplo: $0 code-stable-x64-1793945155.tar.gz"
    exit 1
fi

ARQUIVO="$1"

if [ ! -f "$ARQUIVO" ]; then
    echo -e "${RED}Erro: arquivo '$ARQUIVO' não encontrado.${NC}"
    exit 1
fi

if [[ "$ARQUIVO" != *.tar.gz ]]; then
    echo -e "${RED}Erro: o arquivo precisa ter extensão .tar.gz${NC}"
    exit 1
fi

# ---------- Pede senha de root (cache do sudo) ----------
echo -e "${YELLOW}Solicitando privilégios de root...${NC}"
sudo -v || { echo -e "${RED}Falha ao obter sudo.${NC}"; exit 1; }

# Mantém o sudo ativo durante a execução
( while true; do sudo -n true; sleep 60; kill -0 "$$" 2>/dev/null || exit; done ) &
SUDO_KEEPALIVE_PID=$!
trap 'kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT

DESTINO="/usr/share/code"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"; kill $SUDO_KEEPALIVE_PID 2>/dev/null' EXIT

# ---------- Extrai ----------
echo -e "${YELLOW}Extraindo $ARQUIVO ...${NC}"
tar -xzf "$ARQUIVO" -C "$TMP_DIR"

# O tar oficial extrai para uma pasta "VSCode-linux-x64"
PASTA_EXTRAIDA="$(find "$TMP_DIR" -maxdepth 1 -type d -name 'VSCode-linux-x64' | head -n1)"
if [ -z "$PASTA_EXTRAIDA" ]; then
    # fallback: pega o primeiro diretório
    PASTA_EXTRAIDA="$(find "$TMP_DIR" -maxdepth 1 -mindepth 1 -type d | head -n1)"
fi

if [ -z "$PASTA_EXTRAIDA" ] || [ ! -x "$PASTA_EXTRAIDA/code" ]; then
    echo -e "${RED}Erro: estrutura inesperada do pacote (binário 'code' não encontrado).${NC}"
    exit 1
fi

# ---------- Instala ----------
echo -e "${YELLOW}Instalando em $DESTINO ...${NC}"
sudo rm -rf "$DESTINO"
sudo mkdir -p /usr/share
sudo mv "$PASTA_EXTRAIDA" "$DESTINO"
sudo chown -R root:root "$DESTINO"
sudo chmod -R 755 "$DESTINO"

# ---------- Link simbólico ----------
echo -e "${YELLOW}Criando link simbólico em /usr/bin/code ...${NC}"
sudo ln -sf "$DESTINO/code" /usr/bin/code

# ---------- Atalho .desktop ----------
echo -e "${YELLOW}Criando atalho no menu de aplicativos ...${NC}"
sudo tee /usr/share/applications/code.desktop > /dev/null <<'EOF'
[Desktop Entry]
Name=Visual Studio Code
Comment=Code Editing. Redefined.
GenericName=Text Editor
Exec=/usr/share/code/code --unity-launch %F
Icon=/usr/share/code/resources/app/resources/linux/code.png
Type=Application
StartupNotify=false
StartupWMClass=Code
Categories=TextEditor;Development;IDE;
MimeType=text/plain;inode/directory;application/x-code-workspace;
Actions=new-empty-window;
Keywords=vscode;

[Desktop Action new-empty-window]
Name=New Empty Window
Exec=/usr/share/code/code --new-window %F
Icon=/usr/share/code/resources/app/resources/linux/code.png
EOF
sudo chmod 644 /usr/share/applications/code.desktop

# ---------- Verificação ----------
if command -v code >/dev/null 2>&1; then
    VERSAO="$(code --version 2>/dev/null | head -n1 || echo 'desconhecida')"
    echo -e "${GREEN}✔ VS Code instalado com sucesso!${NC}"
    echo -e "  Versão: ${VERSAO}"
    echo -e "  Binário: /usr/bin/code"
    echo -e "  Diretório: ${DESTINO}"
else
    echo -e "${RED}Instalação concluída, mas 'code' não foi encontrado no PATH.${NC}"
    exit 1
fi
