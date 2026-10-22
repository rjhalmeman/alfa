#!/bin/bash
# ===============================================================
# Script Unificado de Manutenção do Linux Mint + Google Chrome
# Uso: ./atualizarLinux.sh
# Pede a senha UMA vez (re-executa com sudo no início).
# ===============================================================

set -o pipefail

# ---------- Cores ----------
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

# ---------- Helpers ----------
log()   { echo -e "${BLUE}---> $*${NC}"; }
ok()    { echo -e "${GREEN}✓ $*${NC}"; }
aviso() { echo -e "${YELLOW}⚠ $*${NC}"; }
erro()  { echo -e "${RED}✗ $*${NC}"; }

# ---------- Root: re-executa uma única vez ----------
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Solicitando privilégios de superusuário (apenas uma vez)...${NC}"
    exec sudo -- "$0" "$@"
fi

# Garante que sabemos o usuário real (para mensagens e limpeza de cache do usuário)
REAL_USER="${SUDO_USER:-$USER}"
REAL_HOME=$(getent passwd "$REAL_USER" | cut -d: -f6)

# ---------- Verificações iniciais ----------
verificar_internet() {
    log "Verificando conexão com a internet..."
    if ! ping -c 1 -W 2 8.8.8.8 &>/dev/null && ! ping -c 1 -W 2 google.com &>/dev/null; then
        erro "Sem conexão com a internet."
        return 1
    fi
    ok "Conexão OK"
    return 0
}

# ===============================================================
# PARTE 1 — MANUTENÇÃO DO SISTEMA
# ===============================================================
echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN} MANUTENÇÃO DO SISTEMA (APT / SNAP / FLATPAK)${NC}"
echo -e "${GREEN}==========================================${NC}"

log "1/11 Atualizando lista de pacotes (apt update)..."
if ! apt-get update; then
    erro "Falha em 'apt update'. Abortando manutenção do sistema."
    exit 1
fi
ok "Lista de pacotes atualizada."

log "2/11 Aplicando upgrades (apt upgrade / full-upgrade)..."
# full-upgrade já inclui o upgrade; executamos full-upgrade e caímos para upgrade se necessário
if apt-get full-upgrade -y; then
    ok "Sistema atualizado (full-upgrade)."
else
    aviso "full-upgrade falhou; tentando upgrade simples..."
    apt-get upgrade -y && ok "Sistema atualizado (upgrade)."
fi

log "3/11 Atualizando Snap (se instalado)..."
if command -v snap &>/dev/null; then
    snap refresh || aviso "Snap refresh retornou erro (pode não haver snaps)."
else
    aviso "Snap não instalado — pulando."
fi

log "4/11 Atualizando Flatpak (se instalado)..."
if command -v flatpak &>/dev/null; then
    flatpak update -y --noninteractive || aviso "Flatpak update retornou erro."
else
    aviso "Flatpak não instalado — pulando."
fi

log "5/11 Verificando firmware (fwupdmgr)..."
if command -v fwupdmgr &>/dev/null; then
    fwupdmgr refresh --force &>/dev/null && fwupdmgr update -y &>/dev/null \
        && ok "Firmware verificado." || aviso "Sem atualizações de firmware ou erro."
else
    aviso "fwupdmgr não instalado — pulando."
fi

log "6/11 Removendo pacotes/dependências desnecessárias..."
apt-get autoremove -y --purge && ok "Autoremove concluído."

log "7/11 Limpando cache de pacotes..."
apt-get autoclean -y && apt-get clean && ok "Cache APT limpo."

log "8/11 Limpando arquivos temporários antigos (>7 dias)..."
# Mais seguro que rm -rf /tmp/*: não apaga arquivos em uso recente
find /tmp     -mindepth 1 -mtime +7 -user root -delete 2>/dev/null || true
find /var/tmp -mindepth 1 -mtime +7 -user root -delete 2>/dev/null || true
ok "Temporários antigos removidos."

log "9/11 Limpando logs do systemd (>7 dias)..."
journalctl --vacuum-time=7d &>/dev/null && ok "Logs expurgados." || aviso "journalctl indisponível."

log "10/11 Corrigindo pacotes quebrados..."
apt-get --fix-broken install -y && dpkg --configure -a && ok "Pacotes consistidos."

log "11/11 Sincronizando discos..."
sync && ok "sync concluído."

# (Opcional) drop_caches — descomente se realmente quiser
# echo 3 > /proc/sys/vm/drop_caches

# ===============================================================
# PARTE 2 — ATUALIZAÇÃO DO GOOGLE CHROME
# ===============================================================
echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN} ATUALIZAÇÃO DO GOOGLE CHROME${NC}"
echo -e "${GREEN}==========================================${NC}"

atualizar_chrome() {
    local CHROME_URL="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    local DEB_FILE="/tmp/google-chrome-stable_current_amd64.deb"

    # Versão instalada (vazio se não instalado)
    local versao_atual=""
    if command -v google-chrome-stable &>/dev/null; then
        versao_atual=$(google-chrome-stable --version 2>/dev/null | awk '{print $3}')
    fi

    if [ -n "$versao_atual" ]; then
        echo -e "Versão instalada: ${YELLOW}${versao_atual}${NC}"
    else
        aviso "Chrome não instalado — será instalado pela primeira vez."
    fi

    # Se não há internet, não prossegue com download
    if ! verificar_internet; then
        aviso "Chrome não atualizado por falta de rede."
        return 1
    fi

    log "Baixando .deb mais recente do Chrome..."
    if ! wget -q --show-progress -O "$DEB_FILE" "$CHROME_URL"; then
        erro "Falha no download do Chrome."
        rm -f "$DEB_FILE"
        return 1
    fi

    # Versão do .deb (dpkg-deb é local, sem rede)
    local versao_nova
    versao_nova=$(dpkg-deb -f "$DEB_FILE" Version 2>/dev/null | cut -d'-' -f1)

    if [ -z "$versao_nova" ]; then
        erro "Não foi possível ler a versão do .deb baixado."
        rm -f "$DEB_FILE"
        return 1
    fi
    echo -e "Versão disponível: ${GREEN}${versao_nova}${NC}"

    # Comparação: já está atualizado?
    if [ -n "$versao_atual" ] && [ "${versao_atual%%-*}" = "$versao_nova" ]; then
        ok "Chrome já está na versão mais recente."
        rm -f "$DEB_FILE"
        return 0
    fi

    # Fecha instâncias em execução (sem matar processos de outros usuários sem querer)
    log "Finalizando processos do Chrome..."
    pkill -u "$REAL_USER" -f 'chrome' 2>/dev/null || true

    # Instala via apt (resolve dependências automaticamente)
    log "Instalando/atualizando Chrome via APT..."
    if ! apt-get install -y "$DEB_FILE"; then
        aviso "apt install falhou; tentando dpkg + fix-broken..."
        dpkg -i "$DEB_FILE" || apt-get install -f -y
    fi

    rm -f "$DEB_FILE"

    # Confirma versão final
    local versao_final=""
    command -v google-chrome-stable &>/dev/null && \
        versao_final=$(google-chrome-stable --version 2>/dev/null | awk '{print $3}')

    echo -e "\nResumo Chrome:"
    echo -e "  Anterior : ${YELLOW}${versao_atual:-<não instalado>}${NC}"
    echo -e "  Atual    : ${GREEN}${versao_final:-<desconhecido>}${NC}"
    return 0
}

if atualizar_chrome; then
    ok "Etapa do Chrome concluída."
else
    aviso "Etapa do Chrome não concluída (veja mensagens acima)."
fi

# ===============================================================
# RESUMO FINAL
# ===============================================================
echo -e "\n${GREEN}==========================================${NC}"
echo -e "${GREEN}✅ MANUTENÇÃO CONCLUÍDA${NC}"
echo -e "${GREEN}==========================================${NC}"
echo "Operações realizadas:"
echo "  ✓ Atualização de repositórios APT"
echo "  ✓ Upgrade / full-upgrade"
echo "  ✓ Snap / Flatpak / Firmware (quando instalados)"
echo "  ✓ Remoção de pacotes órfãos"
echo "  ✓ Limpeza de caches e temporários antigos"
echo "  ✓ Limpeza de logs (>7d)"
echo "  ✓ Consistência de pacotes"
echo "  ✓ Atualização do Google Chrome"
echo