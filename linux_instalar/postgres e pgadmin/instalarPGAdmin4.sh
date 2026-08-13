#!/usr/bin/env bash

set -euo pipefail

echo "======================================="
echo " Instalação pgAdmin4 via APT"
echo "======================================="

if [[ $EUID -ne 0 ]]; then
    echo "Execute com sudo:"
    echo "sudo $0"
    exit 1
fi

########################################
# Detectar base Ubuntu do Linux Mint
########################################

. /etc/os-release

if [[ -z "${UBUNTU_CODENAME:-}" ]]; then
    echo "Não foi possível detectar UBUNTU_CODENAME"
    exit 1
fi

echo "Base Ubuntu detectada: $UBUNTU_CODENAME"

########################################
# Dependências
########################################

apt update

apt install -y \
    curl \
    gnupg \
    ca-certificates \
    software-properties-common

########################################
# Chave do repositório pgAdmin
########################################

echo "Adicionando chave GPG..."

curl -fsS https://www.pgadmin.org/static/packages_pgadmin_org.pub \
| gpg --dearmor \
| tee /usr/share/keyrings/pgadmin.gpg > /dev/null

########################################
# Repositório correto
########################################

echo "Adicionando repositório pgAdmin..."

echo "deb [signed-by=/usr/share/keyrings/pgadmin.gpg] https://ftp.postgresql.org/pub/pgadmin/pgadmin4/apt/${UBUNTU_CODENAME} pgadmin4 main" \
> /etc/apt/sources.list.d/pgadmin4.list

########################################
# Instalar pgAdmin4 Desktop
########################################

apt update

apt install -y pgadmin4-desktop

########################################

echo
echo "======================================="
echo " pgAdmin4 instalado com sucesso"
echo "======================================="

echo
echo "Executar:"
echo "pgadmin4"
