#!/usr/bin/env bash

set -euo pipefail

########################################################
# Verificação
########################################################

if [[ $EUID -ne 0 ]]; then
    echo "Execute com:"
    echo "sudo $0"
    exit 1
fi

echo "========================================"
echo " Instalação do PostgreSQL"
echo "========================================"

########################################################
# Dados do usuário
########################################################

read -rp "Nome do superusuário: " DBUSER

while true; do
    read -rsp "Senha: " DBPASS
    echo
    read -rsp "Confirme a senha: " DBPASS2
    echo

    if [[ "$DBPASS" == "$DBPASS2" ]]; then
        break
    fi

    echo "As senhas não conferem."
done

########################################################
# Instalação
########################################################

echo
echo "Atualizando repositórios..."

apt update

echo
echo "Instalando PostgreSQL..."

apt install -y \
    postgresql \
    postgresql-client \
    postgresql-contrib

########################################################
# Serviço
########################################################

systemctl enable postgresql
systemctl restart postgresql

########################################################
# Configuração
########################################################

echo
echo "Configurando PostgreSQL..."

sudo -u postgres psql <<EOF
ALTER USER postgres WITH PASSWORD '${DBPASS}';

DO \$\$
BEGIN
    IF NOT EXISTS (
        SELECT
        FROM pg_roles
        WHERE rolname = '${DBUSER}'
    ) THEN
        CREATE ROLE ${DBUSER}
            LOGIN
            SUPERUSER
            CREATEDB
            CREATEROLE
            REPLICATION
            PASSWORD '${DBPASS}';
    END IF;
END
\$\$;
EOF

########################################################
# Banco padrão
########################################################

sudo -u postgres createdb \
    --owner="$DBUSER" \
    "$DBUSER" 2>/dev/null || true

########################################################
# Teste
########################################################

echo
echo "Testando conexão..."

PGPASSWORD="$DBPASS" psql \
    -h localhost \
    -U "$DBUSER" \
    -d "$DBUSER" \
    -c "SELECT current_user, current_database(), version();"

########################################################

cat <<EOF

========================================
Instalação concluída com sucesso
========================================

Host........: localhost
Porta.......: 5432

Usuário.....: $DBUSER
Banco.......: $DBUSER

Para conectar via terminal:

psql -h localhost -U $DBUSER -d $DBUSER

Ou com o usuário padrão:

psql -h localhost -U postgres

========================================

EOF
