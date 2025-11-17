#!/bin/bash

# Para o script se qualquer comando falhar
set -e

# Função para verificar e instalar o AWS CLI
install_aws_cli() {
    echo "--- Verificando AWS CLI ---"
    if command -v aws &> /dev/null; then
        echo "AWS CLI já está instalado."
        aws --version
    else
        echo "Instalando AWS CLI..."
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
        unzip -q awscliv2.zip
        sudo ./aws/install
        
        echo "Limpando arquivos de instalação do AWS CLI..."
        rm awscliv2.zip
        rm -rf aws
        
        echo "AWS CLI instalado com sucesso."
        aws --version
    fi
}

# Função para verificar e instalar o SAM CLI
install_sam_cli() {
    echo "--- Verificando SAM CLI ---"
    if command -v sam &> /dev/null; then
        echo "SAM CLI já está instalado."
        sam --version
    else
        echo "Instalando SAM CLI..."
        wget -q https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip -O sam-cli.zip
        unzip -q sam-cli.zip -d sam-installation
        sudo ./sam-installation/install
        
        echo "Limpando arquivos de instalação do SAM CLI..."
        rm sam-cli.zip
        rm -rf sam-installation
        
        echo "SAM CLI instalado com sucesso."
        sam --version
    fi
}

# --- Execução Principal ---

echo "Iniciando verificação e instalação das ferramentas AWS..."

# 1. Garantir dependências (curl, wget, unzip)
echo "Garantindo dependências (curl, wget, unzip)..."
sudo apt-get update -y > /dev/null
sudo apt-get install -y curl wget unzip > /dev/null

# 2. Instalar AWS CLI
install_aws_cli

# 3. Instalar SAM CLI
install_sam_cli

echo ""
echo "--- Processo concluído! ---"