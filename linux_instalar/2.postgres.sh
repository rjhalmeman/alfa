#!/bin/bash

# Script para instalar PostgreSQL via Snap e configurar usuário
# Execute com privilégios de administrador

echo "=========================================="
echo "Instalador PostgreSQL via Snap"
echo "Linux Mint"
echo "=========================================="

# Verificar se o script está sendo executado como root
if [ "$EUID" -ne 0 ]; then
    echo "Por favor, execute este script como root ou com sudo:"
    echo "sudo ./instalar_postgres_snap.sh"
    exit 1
fi

# Verificar se o Snap está instalado
echo "Verificando se o Snap está instalado..."
if ! command -v snap &> /dev/null; then
    echo "Snap não está instalado. Instalando Snap primeiro..."
    apt update
    apt install -y snapd
    systemctl enable --now snapd.socket
    ln -s /var/lib/snapd/snap /snap
    export PATH="$PATH:/snap/bin"
    echo "Snap instalado com sucesso!"
fi

# Instalar PostgreSQL via Snap
echo "Instalando PostgreSQL via Snap..."
snap install postgresql

# Verificar se a instalação foi bem sucedida
if [ $? -eq 0 ]; then
    echo "PostgreSQL instalado com sucesso via Snap!"
else
    echo "Erro na instalação do PostgreSQL."
    echo "Tentando método alternativo..."
    snap install postgresql --channel=14/stable
fi

# Aguardar a inicialização do PostgreSQL
echo "Aguardando inicialização do PostgreSQL..."
sleep 10

# Obter a versão instalada
POSTGRES_VERSION=$(snap list postgresql | grep postgresql | awk '{print $2}' | cut -d'-' -f1)
echo "Versão do PostgreSQL instalada: $POSTGRES_VERSION"

# Configurar variáveis importantes
export PATH="$PATH:/snap/bin"
export PGDATA="/var/snap/postgresql/common/var/lib/postgresql/$POSTGRES_VERSION/main"
export PGHOST="/var/snap/postgresql/common/var/run/postgresql"
export PGPORT="5432"

# Criar arquivo de configuração de ambiente
echo "Criando arquivo de configuração de ambiente..."
cat > /etc/profile.d/postgresql_snap.sh << EOF
export PATH="\$PATH:/snap/bin"
export PGDATA="/var/snap/postgresql/common/var/lib/postgresql/$POSTGRES_VERSION/main"
export PGHOST="/var/snap/postgresql/common/var/run/postgresql"
export PGPORT="5432"
export PGUSER="postgres"
EOF

# Recarregar variáveis de ambiente
source /etc/profile.d/postgresql_snap.sh

# Verificar status do PostgreSQL
echo "Verificando status do PostgreSQL..."
snap services postgresql

# Aguardar um pouco mais para garantir que o PostgreSQL está rodando
echo "Aguardando PostgreSQL inicializar completamente..."
sleep 15

# Criar usuário personalizado e alterar senha
echo "=========================================="
echo "Criando usuário e configurando senha..."
echo "=========================================="

# Nome do usuário a ser criado
NOVO_USUARIO="gabis"

# Senha padrão (altere conforme necessário)
SENHA_PADRAO="Lageado001."

# Entrar no PostgreSQL como superusuário e criar usuário
echo "Criando usuário '$NOVO_USUARIO'..."
sudo -u postgres psql -c "CREATE USER $NOVO_USUARIO WITH SUPERUSER CREATEDB CREATEROLE LOGIN PASSWORD '$SENHA_PADRAO';"

# Verificar se o usuário foi criado
if [ $? -eq 0 ]; then
    echo "Usuário '$NOVO_USUARIO' criado com sucesso!"
else
    echo "Erro ao criar usuário. Tentando método alternativo..."
    # Método alternativo usando createdb
    sudo -u postgres createdb $NOVO_USUARIO
    sudo -u postgres psql -c "ALTER USER $NOVO_USUARIO WITH PASSWORD '$SENHA_PADRAO';"
fi

# Alterar senha do usuário postgres padrão
echo "Alterando senha do usuário postgres padrão..."
SENHA_POSTGRES="postgres123"
sudo -u postgres psql -c "ALTER USER postgres WITH PASSWORD '$SENHA_POSTGRES';"

# Criar um banco de dados de teste para o novo usuário
echo "Criando banco de dados de teste..."
sudo -u postgres createdb -O $NOVO_USUARIO "testdb_$NOVO_USUARIO"

# Listar usuários criados
echo "=========================================="
echo "Usuários PostgreSQL criados:"
echo "=========================================="
sudo -u postgres psql -c "\du"

# Listar bancos de dados
echo "=========================================="
echo "Bancos de dados disponíveis:"
echo "=========================================="
sudo -u postgres psql -c "\l"

# Mostrar informações de conexão
echo "=========================================="
echo "INSTALAÇÃO CONCLUÍDA!"
echo "=========================================="
echo "Informações de conexão:"
echo "Host: $PGHOST"
echo "Port: $PGPORT"
echo "Data Directory: $PGDATA"
echo ""
echo "Usuários criados:"
echo "1. postgres - Senha: $SENHA_POSTGRES"
echo "2. $NOVO_USUARIO - Senha: $SENHA_PADRAO"
echo ""
echo "Comandos úteis:"
echo "Conectar como postgres: sudo -u postgres psql"
echo "Conectar como $NOVO_USUARIO: psql -U $NOVO_USUARIO -h $PGHOST -p $PGPORT postgres"
echo "Listar bancos: sudo -u postgres psql -c '\l'"
echo "Listar usuários: sudo -u postgres psql -c '\du'"
echo ""
echo "Gerenciar serviço:"
echo "sudo snap start postgresql"
echo "sudo snap stop postgresql"
echo "sudo snap restart postgresql"
echo "sudo snap services postgresql"
echo "=========================================="

# Testar conexão com o novo usuário
echo "Testando conexão com o novo usuário..."
sudo -u postgres psql -c "SELECT version();" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "✅ PostgreSQL está funcionando corretamente!"
else
    echo "⚠️  PostgreSQL instalado, mas há problemas de conexão."
    echo "Tente reiniciar o serviço: sudo snap restart postgresql"
fi