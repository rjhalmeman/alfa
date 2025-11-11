#!/bin/bash

# Script para remover completamente o PostgreSQL do Linux Mint
# Execute com: sudo ./remove_postgres.sh

set -e  # Para o script em caso de erro

echo "=========================================="
echo "  REMOÇÃO COMPLETA DO POSTGRESQL"
echo "=========================================="

# Função para verificar confirmação
confirm_removal() {
    read -p "Tem certeza que deseja remover completamente o PostgreSQL? (s/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Ss]$ ]]; then
        echo "Remoção cancelada."
        exit 0
    fi
}

# Verificar se é root
if [ "$EUID" -ne 0 ]; then
    echo "ERRO: Este script deve ser executado como root ou com sudo"
    echo "Use: sudo ./remove_postgres.sh"
    exit 1
fi

# Confirmar remoção
confirm_removal

echo ">>> Parando serviços do PostgreSQL..."
systemctl stop postgresql 2>/dev/null || true
systemctl disable postgresql 2>/dev/null || true

# Remover via Snap (se instalado)
echo ">>> Verificando instalação via Snap..."
if snap list | grep -q postgres; then
    echo ">>> Removendo PostgreSQL Snap..."
    snap list | grep postgres | while read -r line; do
        snap_name=$(echo "$line" | awk '{print $1}')
        echo "Removendo snap: $snap_name"
        snap stop "$snap_name" 2>/dev/null || true
        snap remove "$snap_name" --purge
    done
fi

# Remover via APT (instalação tradicional)
echo ">>> Removendo pacotes APT do PostgreSQL..."
apt-get remove --purge -y \
    postgresql \
    postgresql-* \
    postgresql-contrib \
    postgresql-client \
    postgresql-client-* \
    pgadmin4* \
    2>/dev/null || true

# Remover configurações e dados
echo ">>> Removendo arquivos de configuração e dados..."
rm -rf /var/lib/postgresql
rm -rf /var/log/postgresql
rm -rf /etc/postgresql
rm -rf /etc/postgresql-common
rm -rf /var/run/postgresql

# Remover diretórios do usuário postgres
echo ">>> Removendo diretórios do usuário..."
if id "postgres" &>/dev/null; then
    user_home=$(getent passwd postgres | cut -d: -f6)
    if [ -d "$user_home" ]; then
        rm -rf "$user_home"
    fi
fi

# Remover usuário e grupo postgres
echo ">>> Removendo usuário e grupo postgres..."
userdel -r postgres 2>/dev/null || true
groupdel postgres 2>/dev/null || true

# Limpar diretórios do Snap
echo ">>> Limpando diretórios do Snap..."
rm -rf /var/snap/postgresql* 2>/dev/null || true
find /home -type d -name "postgresql" -path "*/snap/*" -exec rm -rf {} + 2>/dev/null || true
find /root -type d -name "postgresql" -path "*/snap/*" -exec rm -rf {} + 2>/dev/null || true

# Limpar pacotes órfãos
echo ">>> Limpando pacotes órfãos..."
apt-get autoremove -y
apt-get autoclean -y

# Remover repositórios específicos do PostgreSQL (se existirem)
echo ">>> Verificando repositórios do PostgreSQL..."
if [ -f /etc/apt/sources.list.d/pgdg.list ]; then
    echo ">>> Removendo repositório PGDG..."
    rm -f /etc/apt/sources.list.d/pgdg.list
    apt-get update
fi

# Limpar cache do apt
echo ">>> Limpando cache do APT..."
apt-get clean

# Verificação final
echo ">>> Verificando remoção completa..."
echo ""

# Verificar se pacotes ainda existem
if dpkg -l | grep -q postgres; then
    echo "AVISO: Alguns pacotes do PostgreSQL ainda podem estar presentes:"
    dpkg -l | grep postgres
else
    echo "✓ Nenhum pacote PostgreSQL encontrado no APT"
fi

# Verificar se snaps ainda existem
if snap list | grep -q postgres; then
    echo "AVISO: Alguns snaps do PostgreSQL ainda podem estar presentes:"
    snap list | grep postgres
else
    echo "✓ Nenhum snap PostgreSQL encontrado"
fi

# Verificar se arquivos ainda existem
echo ""
echo ">>> Verificando arquivos remanescentes..."
find / -name "*postgres*" -type f 2>/dev/null | head -10

echo ""
echo "=========================================="
echo "  REMOÇÃO CONCLUÍDA!"
echo "=========================================="
echo "Recomenda-se reiniciar o sistema para garantir"
echo "que todos os processos foram finalizados."
echo ""