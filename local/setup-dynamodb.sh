#!/bin/bash

# --- 1. CONFIGURAÇÃO DE VARIÁVEIS DE AMBIENTE ---
echo "Configurando variáveis de ambiente locais..."

export ENV="local"

export DB_URL="http://localhost:8000"

export AWS_DEFAULT_REGION="us-east-1"

echo "   - ENV: ${ENV}"
echo "   - DB_URL: ${DB_URL}"
echo "   - AWS_DEFAULT_REGION: ${AWS_DEFAULT_REGION}"

# --- 2. INICIALIZAÇÃO DO DYNAMODB LOCAL COM DOCKER ---
echo -e "\n Iniciando o DynamoDB Local com Docker..."

docker-compose up -d

echo "   Aguardando 5 segundos para o DynamoDB iniciar..."
sleep 5

if [ "$(docker ps -q -f name=dynamodb-local)" ]; then
    echo "   DynamoDB Local iniciado com sucesso em ${DB_URL}"
else
    echo "Falha ao iniciar o container DynamoDB. Saindo."
    exit 1
fi

# --- 3. CRIAÇÃO DA TABELA (ItemsTable) ---
echo -e "\n Criando a tabela ItemsTable..."

aws dynamodb create-table \
    --table-name ItemsTable \
    --key-schema \
        AttributeName=ID,KeyType=HASH \
    --attribute-definitions \
        AttributeName=ID,AttributeType=S \
    --provisioned-throughput \
        ReadCapacityUnits=1,WriteCapacityUnits=1 \
    --endpoint-url ${DB_URL} \
    --region ${AWS_DEFAULT_REGION}

if [ $? -eq 0 ]; then
    echo " Tabela 'ItemsTable' criada com sucesso!"
else
    echo " Falha ao criar a tabela. A tabela pode já existir ou o AWS CLI não está instalado/configurado."
fi

echo -e "\n Configuração local do DynamoDB concluída."