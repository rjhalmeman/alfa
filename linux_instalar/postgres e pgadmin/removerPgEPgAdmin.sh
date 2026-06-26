#!/usr/bin/env bash

set -euo pipefail

echo "======================================="
echo " Removendo PostgreSQL e pgAdmin 4"
echo "======================================="

if [[ $EUID -ne 0 ]]; then
    echo "Execute como root:"
    echo "sudo $0"
    exit 1
fi

echo
echo "==> Parando serviços..."

systemctl stop postgresql 2>/dev/null || true
systemctl disable postgresql 2>/dev/null || true

#################################################
# APT
#################################################

echo
echo "==> Removendo pacotes APT..."

apt purge -y \
    postgresql* \
    pgadmin4* \
    pgadmin3* \
    postgresql-client* \
    postgresql-common \
    postgresql-contrib \
    libpq* || true

apt autoremove -y --purge
apt autoclean

#################################################
# SNAP
#################################################

if command -v snap >/dev/null 2>&1; then
    echo
    echo "==> Verificando Snap..."

    snap list | grep -i postgres && snap remove postgres || true
    snap list | grep -i postgresql && snap remove postgresql || true
    snap list | grep -i pgadmin && snap remove pgadmin4 || true
fi

#################################################
# FLATPAK
#################################################

if command -v flatpak >/dev/null 2>&1; then
    echo
    echo "==> Verificando Flatpak..."

    flatpak list | grep -i pgadmin | awk '{print $2}' | while read app; do
        flatpak uninstall -y "$app"
    done
fi

#################################################
# BINÁRIOS MANUAIS
#################################################

echo
echo "==> Removendo binários conhecidos..."

rm -f /usr/local/bin/psql
rm -f /usr/local/bin/postgres
rm -f /usr/local/bin/pgadmin4

#################################################
# DADOS
#################################################

echo
echo "==> Removendo dados e configurações..."

rm -rf /etc/postgresql
rm -rf /etc/postgresql-common

rm -rf /var/lib/postgresql
rm -rf /var/log/postgresql
rm -rf /var/run/postgresql

rm -rf /usr/lib/postgresql
rm -rf /usr/share/postgresql
rm -rf /usr/share/pgadmin4

#################################################
# USUÁRIO postgres
#################################################

echo
echo "==> Removendo usuário postgres..."

userdel -r postgres 2>/dev/null || true
groupdel postgres 2>/dev/null || true

#################################################
# CONFIGURAÇÕES DO USUÁRIO
#################################################

echo
echo "==> Removendo configurações do usuário..."

for home in /home/*; do
    rm -rf "$home/.pgadmin"
    rm -rf "$home/.config/pgadmin"
    rm -rf "$home/.postgresql"
done

#################################################

echo
echo "==> Atualizando cache..."

updatedb 2>/dev/null || true

echo
echo "======================================="
echo "Remoção concluída."
echo "======================================="

echo
echo "Verificações finais:"
echo

echo "PostgreSQL:"
which psql || true
psql --version || true

echo
echo "pgAdmin:"
which pgadmin4 || true

echo
echo "Pacotes restantes:"
dpkg -l | grep -Ei 'postgres|pgadmin' || true

echo
echo "Snaps restantes:"
snap list 2>/dev/null | grep -Ei 'postgres|pgadmin' || true

echo
echo "Flatpaks restantes:"
flatpak list 2>/dev/null | grep -Ei 'postgres|pgadmin' || true
