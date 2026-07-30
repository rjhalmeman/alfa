#!/bin/bash

# Script de instalação e configuração do PHP 7.3 + Apache
# Para Linux Mint
# Autor: Assistente IA
# Data: $(date +%Y-%m-%d)

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para exibir mensagens
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCESSO]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERRO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[AVISO]${NC} $1"
}

# Verifica se está rodando como root
if [[ $EUID -ne 0 ]]; then
   print_error "Este script deve ser executado como root. Use: sudo ./script.sh"
   exit 1
fi

print_message "Iniciando instalação do PHP 7.3 e Apache no Linux Mint..."

# Atualiza os repositórios
print_message "Atualizando lista de pacotes..."
apt update || {
    print_error "Falha ao atualizar lista de pacotes"
    exit 1
}

# Adiciona o repositório Ondrej para PHP 7.3
print_message "Adicionando repositório PHP 7.3..."
apt install -y software-properties-common || {
    print_error "Falha ao instalar software-properties-common"
    exit 1
}

add-apt-repository -y ppa:ondrej/php || {
    print_error "Falha ao adicionar repositório PHP"
    exit 1
}

# Atualiza novamente após adicionar o repositório
print_message "Atualizando lista de pacotes com novo repositório..."
apt update || {
    print_error "Falha ao atualizar lista de pacotes após adicionar repositório"
    exit 1
}

# Instala Apache
print_message "Instalando Apache..."
apt install -y apache2 || {
    print_error "Falha ao instalar Apache"
    exit 1
}

# Instala PHP 7.3 e extensões comuns
print_message "Instalando PHP 7.3 e extensões..."
apt install -y \
    php7.3 \
    php7.3-cli \
    php7.3-common \
    php7.3-mysql \
    php7.3-zip \
    php7.3-gd \
    php7.3-mbstring \
    php7.3-curl \
    php7.3-xml \
    php7.3-bcmath \
    php7.3-json \
    php7.3-tokenizer \
    php7.3-fpm \
    libapache2-mod-php7.3 || {
    print_error "Falha ao instalar PHP 7.3 e extensões"
    exit 1
}

# Habilita o módulo PHP no Apache
print_message "Habilitando módulo PHP no Apache..."
a2enmod php7.3 || {
    print_error "Falha ao habilitar módulo PHP"
    exit 1
}

# Configura o arquivo php.ini para desenvolvimento
print_message "Configurando php.ini para desenvolvimento..."
PHP_INI="/etc/php/7.3/apache2/php.ini"

# Backup do arquivo original
cp $PHP_INI ${PHP_INI}.backup.$(date +%Y%m%d_%H%M%S)

# Ajustes comuns para desenvolvimento
sed -i 's/^upload_max_filesize = .*/upload_max_filesize = 20M/' $PHP_INI
sed -i 's/^post_max_size = .*/post_max_size = 20M/' $PHP_INI
sed -i 's/^max_execution_time = .*/max_execution_time = 300/' $PHP_INI
sed -i 's/^memory_limit = .*/memory_limit = 256M/' $PHP_INI
sed -i 's/^display_errors = .*/display_errors = On/' $PHP_INI
sed -i 's/^display_startup_errors = .*/display_startup_errors = On/' $PHP_INI
sed -i 's/^error_reporting = .*/error_reporting = E_ALL/' $PHP_INI

# Cria um arquivo de configuração personalizado para desenvolvimento
print_message "Criando configuração personalizada para desenvolvimento..."
cat > /etc/php/7.3/apache2/conf.d/99-dev.ini << EOF
; Configurações para desenvolvimento
date.timezone = America/Sao_Paulo
; Ajuste o timezone conforme sua localidade

; Configurações de erro
error_reporting = E_ALL
display_errors = On
display_startup_errors = On
log_errors = On

; Configurações de memória e timeout
memory_limit = 256M
max_execution_time = 300
max_input_time = 300

; Configurações de upload
upload_max_filesize = 20M
post_max_size = 20M

; Xdebug (se instalado posteriormente)
; zend_extension=xdebug.so
; xdebug.mode=debug
; xdebug.start_with_request=yes
EOF

# Configura permissões do diretório do Apache
print_message "Configurando permissões do diretório web..."
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

# Cria um arquivo info.php de teste
print_message "Criando arquivo de teste info.php..."
cat > /var/www/html/info.php << EOF
<?php
phpinfo();
?>
EOF

chown www-data:www-data /var/www/html/info.php

# Cria um virtual host de exemplo para projetos
print_message "Criando Virtual Host de exemplo para desenvolvimento..."

# Cria diretório para projetos
mkdir -p /var/www/projetos
chown -R www-data:www-data /var/www/projetos

# Cria arquivo de virtual host
cat > /etc/apache2/sites-available/projetos.conf << EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    ServerName projetos.local
    DocumentRoot /var/www/projetos
    
    <Directory /var/www/projetos>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Habilita o virtual host
a2ensite projetos.conf || {
    print_warning "Não foi possível habilitar o virtual host projetos.conf"
}

# Reinicia o Apache
print_message "Reiniciando Apache..."
systemctl restart apache2 || {
    print_error "Falha ao reiniciar Apache"
    exit 1
}

# Verifica status do Apache
systemctl status apache2 --no-pager

# Verifica instalação do PHP
print_message "Verificando instalação do PHP..."
php -v

# Mostra resumo final
echo -e "\n${GREEN}========================================${NC}"
echo -e "${GREEN}  INSTALAÇÃO CONCLUÍDA COM SUCESSO!   ${NC}"
echo -e "${GREEN}========================================${NC}\n"

print_success "PHP 7.3 e Apache instalados e configurados!"
print_success "Document root padrão: /var/www/html/"
print_success "Diretório de projetos: /var/www/projetos/"
print_success "Arquivo de teste: http://localhost/info.php"
print_success "Virtual host exemplo: projetos.local (adicione ao /etc/hosts)"

echo -e "\n${YELLOW}Para adicionar o virtual host ao seu sistema:${NC}"
echo -e "  echo '127.0.0.1 projetos.local' | sudo tee -a /etc/hosts"
echo -e "\n${YELLOW}Para verificar a configuração do PHP:${NC}"
echo -e "  php -i | grep 'Loaded Configuration File'"
echo -e "\n${YELLOW}Comandos úteis:${NC}"
echo -e "  sudo systemctl start apache2  # Iniciar Apache"
echo -e "  sudo systemctl stop apache2   # Parar Apache"
echo -e "  sudo systemctl restart apache2 # Reiniciar Apache"
echo -e "  sudo systemctl status apache2  # Verificar status"

print_warning "Recomenda-se reiniciar o sistema ou reiniciar a sessão do usuário"
print_warning "para garantir que todas as variáveis de ambiente sejam carregadas."

echo -e "\n${GREEN}========================================${NC}\n"

exit 0
