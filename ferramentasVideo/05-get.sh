#!/bin/bash

# Define o nome do arquivo Python e do serviço
NOME_SCRIPT="05-get.py"
NOME_SERVICO="capturador.service"
DIRETORIO_ATUAL=$(pwd)
CAMINHO_SCRIPT="$DIRETORIO_ATUAL/$NOME_SCRIPT"
VENV_DIR="$DIRETORIO_ATUAL/venv"

echo "===================================================="
echo "Iniciando a instalação e configuração do Capturador"
echo "===================================================="

# 1. Verifica se o get.py realmente existe nesta pasta
if [ ! -f "$CAMINHO_SCRIPT" ]; then
    echo "❌ Erro: O arquivo $NOME_SCRIPT não foi encontrado em $DIRETORIO_ATUAL."
    echo "Por favor, coloque este arquivo .sh na mesma pasta que o $NOME_SCRIPT e rode novamente."
    exit 1
fi

# 2. Instala dependências do sistema operacional
# Vai pedir a sua senha de usuário (sudo) para instalar o Python, Tkinter e Venv
echo "📦 Verificando/Instalando dependências do sistema (Python 3, Tkinter, Venv)..."
sudo apt-get update
sudo apt-get install -y python3 python3-pip python3-venv python3-tk

# 3. Cria o Ambiente Virtual Python (se não existir)
echo "🐍 Criando ambiente virtual Python isolado..."
if [ ! -d "$VENV_DIR" ]; then
    python3 -m venv "$VENV_DIR"
fi

# 4. Instala as dependências do Python DENTRO do ambiente virtual
echo "📚 Baixando e instalando bibliotecas Python (mss, pynput)..."
"$VENV_DIR/bin/pip" install --upgrade pip
"$VENV_DIR/bin/pip" install mss pynput

# 5. Cria o serviço systemd de usuário apontando para o Python do venv
echo "⚙️ Configurando o serviço de inicialização automática..."
PASTA_SYSTEMD="$HOME/.config/systemd/user"
mkdir -p "$PASTA_SYSTEMD"

cat <<EOF > "$PASTA_SYSTEMD/$NOME_SERVICO"
[Unit]
Description=Serviço Get.py de Captura de Tela
After=graphical-session.target

[Service]
# Usa o Python do ambiente virtual para garantir que ache o mss e pynput
ExecStart=$VENV_DIR/bin/python $CAMINHO_SCRIPT
Restart=on-failure
Environment="DISPLAY=:0"
Environment="XAUTHORITY=%h/.Xauthority"

[Install]
WantedBy=default.target
EOF

# 6. Ativa e inicia o serviço
echo "🚀 Ativando o serviço no sistema..."
systemctl --user daemon-reload
systemctl --user enable "$NOME_SERVICO"
systemctl --user restart "$NOME_SERVICO"

echo ""
echo "===================================================="
echo "✅ Instalação concluída com sucesso!"
echo "O programa '$NOME_SCRIPT' já está rodando em segundo plano."
echo "Ele iniciará automaticamente toda vez que você ligar o PC."
echo "Pressione Ctrl + Alt + 9 para abrir a interface."
echo "===================================================="
