#!/bin/bash

# Script de instalação automatizada do DOSBox-Staging em container Docker
# Autor: Assistente
# Descrição: Configura e executa o DOSBox-Staging em container Docker com interface web

# Cores para output
VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
AMARELO='\033[1;33m'
AZUL='\033[0;34m'
NC='\033[0m' # No Color

# Função para imprimir mensagens coloridas
print_mensagem() {
    echo -e "${2}${1}${NC}"
}

# Função para verificar se o Docker está instalado
verificar_docker() {
    print_mensagem "Verificando instalação do Docker..." "${AZUL}"
    
    if ! command -v docker &> /dev/null; then
        print_mensagem "Docker não encontrado. Instalando Docker..." "${AMARELO}"
        
        # Atualiza o sistema
        sudo apt update
        
        # Instala dependências
        sudo apt install -y \
            apt-transport-https \
            ca-certificates \
            curl \
            software-properties-common \
            gnupg \
            lsb-release
        
        # Adiciona a chave GPG oficial do Docker
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Adiciona o repositório do Docker
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
          $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Instala o Docker Engine
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        # Adiciona o usuário atual ao grupo docker
        sudo usermod -aG docker $USER
        
        print_mensagem "Docker instalado com sucesso!" "${VERDE}"
        print_mensagem "ATENÇÃO: Você precisa reiniciar a sessão ou executar 'newgrp docker' para usar Docker sem sudo" "${AMARELO}"
        
        return 0
    else
        print_mensagem "Docker já está instalado!" "${VERDE}"
        return 0
    fi
}

# Função para verificar se o Docker está rodando
verificar_docker_rodando() {
    print_mensagem "Verificando se o Docker daemon está rodando..." "${AZUL}"
    
    if ! sudo systemctl is-active --quiet docker; then
        print_mensagem "Iniciando Docker daemon..." "${AMARELO}"
        sudo systemctl start docker
        sudo systemctl enable docker
        sleep 2
    fi
    
    print_mensagem "Docker daemon está rodando!" "${VERDE}"
}

# Função para parar e remover container existente
limpar_container_existente() {
    if docker ps -a --format '{{.Names}}' | grep -q "^dosbox-staging$"; then
        print_mensagem "Container 'dosbox-staging' já existe. Parando e removendo..." "${AMARELO}"
        docker stop dosbox-staging 2>/dev/null
        docker rm dosbox-staging 2>/dev/null
        print_mensagem "Container antigo removido!" "${VERDE}"
    fi
}

# Função para criar diretórios necessários
criar_diretorios() {
    print_mensagem "Criando diretórios para programas DOS..." "${AZUL}"
    
    # Define o diretório base para programas DOS
    DOS_DIR="$HOME/dos-programs"
    
    # Cria o diretório se não existir
    if [ ! -d "$DOS_DIR" ]; then
        mkdir -p "$DOS_DIR"
        print_mensagem "Diretório criado: $DOS_DIR" "${VERDE}"
        
        # Cria subdiretórios organizados
        mkdir -p "$DOS_DIR/jogos"
        mkdir -p "$DOS_DIR/aplicativos"
        mkdir -p "$DOS_DIR/arquivos"
        
        # Cria um arquivo README explicativo
        cat > "$DOS_DIR/README.txt" << 'EOF'
=== PASTA DE PROGRAMAS DOS ===

Coloque seus programas e jogos DOS aqui!

Organização sugerida:
- /jogos/    : Para seus jogos DOS (.exe, .com, .bat)
- /aplicativos/ : Para aplicativos DOS (editores, ferramentas)
- /arquivos/ : Para arquivos diversos (documentos, saves)

Dentro do DOSBox, esta pasta estará disponível em: C:\DOSPROG

Para montar manualmente (se necessário):
MOUNT C /dos-programs

Divirta-se!
EOF
        
        print_mensagem "Estrutura de pastas criada com README explicativo!" "${VERDE}"
    else
        print_mensagem "Diretório já existe: $DOS_DIR" "${VERDE}"
    fi
    
    echo "$DOS_DIR"
}

# Função para criar arquivo de configuração personalizado do DOSBox
criar_config_dosbox() {
    print_mensagem "Criando configuração personalizada do DOSBox..." "${AZUL}"
    
    # Cria diretório de configuração temporário
    CONFIG_DIR="$HOME/.dosbox-config"
    mkdir -p "$CONFIG_DIR"
    
    # Cria arquivo de configuração otimizado
    cat > "$CONFIG_DIR/dosbox.conf" << 'EOF'
# Configuração otimizada para DOSBox-Staging
# Personalizada para melhor desempenho e experiência

[dosbox]
machine = svga_s3
captures = /config/capture
memsize = 16

[render]
scaler = normal3x
aspect = true
vsync = false

[cpu]
core = dynamic
cputype = auto
cycles = max
cycleup = 500
cycledown = 20

[mixer]
rate = 48000
blocksize = 1024
prebuffer = 40

[sblaster]
sbtype = sb16
sbbase = 220
irq = 7
dma = 1
hdma = 5
mixer = true
oplmode = auto
oplemu = default

[gus]
gus = false

[speaker]
pcspeaker = true
pcrate = 22050
tandy = auto
disney = false

[joystick]
joysticktype = auto
timed = true
autofire = false
sensitivity = 100
deadzone = 15

[serial]
serial1 = dummy
serial2 = dummy
serial3 = disabled
serial4 = disabled

[dos]
xms = true
ems = true
umb = true
keyboardlayout = auto

[ipx]
ipx = false

[autoexec]
# Montagem automática da pasta de programas
MOUNT C /dos-programs
C:
CLS
ECHO Bem-vindo ao DOSBox-Staging!
ECHO.
ECHO Seus programas estao em C:\
ECHO Para listar os arquivos, digite: DIR
ECHO.
EOF
    
    print_mensagem "Configuração personalizada criada em: $CONFIG_DIR/dosbox.conf" "${VERDE}"
    echo "$CONFIG_DIR"
}

# Função para criar script de inicialização do container
criar_script_inicializacao() {
    print_mensagem "Criando script de inicialização rápida..." "${AZUL}"
    
    SCRIPT_PATH="$HOME/start-dosbox.sh"
    
    cat > "$SCRIPT_PATH" << 'EOF'
#!/bin/bash

# Script para iniciar o container DOSBox-Staging

# Cores
VERDE='\033[0;32m'
AZUL='\033[0;34m'
NC='\033[0m'

echo -e "${AZUL}Iniciando DOSBox-Staging...${NC}"

# Verifica se o container já está rodando
if docker ps --format '{{.Names}}' | grep -q "^dosbox-staging$"; then
    echo -e "${VERDE}Container já está rodando!${NC}"
else
    # Inicia o container
    docker start dosbox-staging 2>/dev/null || {
        echo -e "${AZUL}Criando e iniciando novo container...${NC}"
        # Se não existir, cria e inicia
        docker run -d \
            --name dosbox-staging \
            --restart unless-stopped \
            -p 8080:3001 \
            -v $HOME/dos-programs:/dos-programs \
            -v $HOME/.dosbox-config:/config \
            --security-opt seccomp=unconfined \
            lscr.io/linuxserver/dosbox-staging:latest
    }
fi

# Aguarda o container inicializar
sleep 3

# Abre o navegador automaticamente
if command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:8080
elif command -v gnome-open &> /dev/null; then
    gnome-open http://localhost:8080
else
    echo -e "${AZUL}Acesse no navegador: http://localhost:8080${NC}"
fi

echo -e "${VERDE}DOSBox-Staging está rodando!${NC}"
echo -e "${VERDE}Acesse: http://localhost:8080${NC}"
echo -e "${VERDE}Programas DOS em: $HOME/dos-programs${NC}"
EOF
    
    chmod +x "$SCRIPT_PATH"
    print_mensagem "Script de inicialização criado em: $SCRIPT_PATH" "${VERDE}"
}

# Função para criar atalho no desktop (opcional)
criar_atalho_desktop() {
    print_mensagem "Deseja criar um atalho no desktop? (s/n)" "${AZUL}"
    read -r resposta
    
    if [[ "$resposta" =~ ^[Ss]$ ]]; then
        DESKTOP_FILE="$HOME/Desktop/dosbox-staging.desktop"
        
        cat > "$DESKTOP_FILE" << EOF
[Desktop Entry]
Version=1.0
Name=DOSBox-Staging
Comment=Jogue seus jogos DOS no container Docker
Exec=$HOME/start-dosbox.sh
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=Game;Emulator;
EOF
        
        chmod +x "$DESKTOP_FILE"
        print_mensagem "Atalho criado em: $DESKTOP_FILE" "${VERDE}"
    else
        print_mensagem "Atalho não criado." "${AMARELO}"
    fi
}

# Função para criar script de parada
criar_script_parada() {
    SCRIPT_STOP="$HOME/stop-dosbox.sh"
    
    cat > "$SCRIPT_STOP" << 'EOF'
#!/bin/bash

# Script para parar o container DOSBox-Staging

VERMELHO='\033[0;31m'
VERDE='\033[0;32m'
NC='\033[0m'

echo -e "${VERMELHO}Parando DOSBox-Staging...${NC}"
docker stop dosbox-staging

if [ $? -eq 0 ]; then
    echo -e "${VERDE}Container parado com sucesso!${NC}"
else
    echo -e "${VERMELHO}Erro ao parar container ou container não estava rodando.${NC}"
fi
EOF
    
    chmod +x "$SCRIPT_STOP"
    print_mensagem "Script de parada criado em: $SCRIPT_STOP" "${VERDE}"
}

# Função principal
main() {
    print_mensagem "=== INSTALADOR AUTOMÁTICO DOSBOX-STAGING ===" "${AZUL}"
    print_mensagem "Iniciando instalação..." "${AZUL}"
    echo ""
    
    # Verifica e instala Docker se necessário
    verificar_docker
    verificar_docker_rodando
    
    # Limpa container existente
    limpar_container_existente
    
    # Cria diretórios necessários
    DOS_DIR=$(criar_diretorios)
    
    # Cria configuração personalizada
    CONFIG_DIR=$(criar_config_dosbox)
    
    # Puxa a imagem do DOSBox-Staging
    print_mensagem "Baixando imagem do DOSBox-Staging..." "${AZUL}"
    docker pull lscr.io/linuxserver/dosbox-staging:latest
    
    # Inicia o container com todas as configurações
    print_mensagem "Iniciando container do DOSBox-Staging..." "${AZUL}"
    
    docker run -d \
        --name dosbox-staging \
        --restart unless-stopped \
        -p 8080:3001 \
        -v "$DOS_DIR":/dos-programs \
        -v "$CONFIG_DIR":/config \
        --security-opt seccomp=unconfined \
        lscr.io/linuxserver/dosbox-staging:latest
    
    if [ $? -eq 0 ]; then
        print_mensagem "Container iniciado com sucesso!" "${VERDE}"
        
        # Cria scripts auxiliares
        criar_script_inicializacao
        criar_script_parada
        
        # Pergunta sobre atalho no desktop
        criar_atalho_desktop
        
        # Aguarda inicialização completa
        sleep 5
        
        print_mensagem "" ""
        print_mensagem "=== INSTALAÇÃO CONCLUÍDA ===" "${VERDE}"
        print_mensagem "" ""
        print_mensagem "📦 Container: dosbox-staging" "${VERDE}"
        print_mensagem "🌐 Acesso Web: http://localhost:8080" "${VERDE}"
        print_mensagem "📁 Programas DOS: $DOS_DIR" "${VERDE}"
        print_mensagem "⚙️  Configuração: $CONFIG_DIR/dosbox.conf" "${VERDE}"
        print_mensagem "" ""
        print_mensagem "🎮 COMANDOS ÚTEIS:" "${AZUL}"
        print_mensagem "   Iniciar: $HOME/start-dosbox.sh" "${VERDE}"
        print_mensagem "   Parar:   $HOME/stop-dosbox.sh" "${VERDE}"
        print_mensagem "   Logs:    docker logs dosbox-staging" "${VERDE}"
        print_mensagem "   Shell:   docker exec -it dosbox-staging /bin/bash" "${VERDE}"
        print_mensagem "" ""
        print_mensagem "🚀 Abrindo navegador automaticamente..." "${AZUL}"
        
        # Tenta abrir o navegador automaticamente
        sleep 2
        if command -v xdg-open &> /dev/null; then
            xdg-open http://localhost:8080
        elif command -v gnome-open &> /dev/null; then
            gnome-open http://localhost:8080
        fi
        
        print_mensagem "" ""
        print_mensagem "✨ Divirta-se com seus jogos DOS! ✨" "${VERDE}"
        
    else
        print_mensagem "Erro ao iniciar o container!" "${VERMELHO}"
        exit 1
    fi
}

# Executa a função principal
main
