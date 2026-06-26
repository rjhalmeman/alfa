#!/usr/bin/env bash

set -euo pipefail

if [[ $EUID -ne 0 ]]; then
    echo "Execute com:"
    echo "sudo $0"
    exit 1
fi

echo "========================================="
echo " Removendo referências do pgAdmin no APT"
echo "========================================="

BACKUP_DIR="/root/backup_pgadmin_repo_$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo
echo "Procurando referências..."

FILES=$(grep -Ril "pgadmin" /etc/apt/ 2>/dev/null || true)

if [[ -z "$FILES" ]]; then
    echo "Nenhuma referência encontrada."
else
    echo
    echo "Arquivos encontrados:"
    echo "$FILES"
    echo

    while IFS= read -r file; do
        [[ -f "$file" ]] || continue

        echo "Backup: $file"
        cp -a "$file" "$BACKUP_DIR/"

        echo "Removendo: $file"
        rm -f "$file"
    done <<< "$FILES"
fi

echo
echo "Removendo possíveis arquivos restantes..."

rm -f /etc/apt/sources.list.d/*pgadmin* 2>/dev/null || true

echo
echo "Limpando cache..."

apt clean

rm -rf /var/lib/apt/lists/*

echo
echo "Atualizando repositórios..."

apt update

echo
echo "========================================="
echo "Concluído."
echo "========================================="

echo
echo "Backup dos arquivos removidos:"
echo "$BACKUP_DIR"

echo
echo "Verificando se ainda existe alguma referência..."

if grep -R "pgadmin" /etc/apt/ >/dev/null 2>&1; then
    echo
    echo "Ainda existem referências:"
    grep -R "pgadmin" /etc/apt/
else
    echo
    echo "Nenhuma referência ao pgAdmin encontrada."
fi
