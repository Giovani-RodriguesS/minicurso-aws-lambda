package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"os"

	"github.com/aws/aws-lambda-go/events"
	"github.com/aws/aws-lambda-go/lambda"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/dynamodb"
	"github.com/aws/aws-sdk-go/service/dynamodb/dynamodbattribute"

	"github.com/Giovani-RodriguesS/minicurso-aws-lambda/src/pkg/models"
	"github.com/Giovani-RodriguesS/minicurso-aws-lambda/src/pkg/database"
)

func handler(ctx context.Context, request events.APIGatewayProxyRequest) (events.APIGatewayProxyResponse, error) {
	dynamoDBClient := database.ConnDB(ctx)
	tableName := os.Getenv("TABLE_NAME")
	if id, ok := request.PathParameters["id"]; ok && id != "" {
		return getItem(id)
	}

	return scanItems(dynamoDBClient, tableName)
}

func scanItems(dynamoDBClient *dynamodb.DynamoDB, tableName string) (events.APIGatewayProxyResponse, error) {
	log.Println("Executando Scan para buscar todos os itens na tabela:", tableName)

	
	result, err := dynamoDBClient.Scan(&dynamodb.ScanInput{
		TableName: aws.String(tableName),
	})

	if err != nil {
		log.Printf("Erro no Scan: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       "Erro ao buscar todos os registros.",
		}, nil
	}

	// Deserializa os itens do DynamoDB para a estrutura Go
	values := []models.Data{}
	err = dynamodbattribute.UnmarshalListOfMaps(result.Items, &values)
	if err != nil {
		log.Printf("Erro ao deserializar itens: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       "Erro interno de processamento.",
		}, nil
	}

	// Converte a lista de resultados em JSON
	responseBody, _ := json.Marshal(values)
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(responseBody),
	}, nil
}

func getItem(id string) (events.APIGatewayProxyResponse, error) {
	log.Printf("Executando GetItem para ID: %s", id)

	result, err := dynamoDBClient.GetItem(&dynamodb.GetItemInput{
		TableName: aws.String(tableName),
		Key: map[string]*dynamodb.AttributeValue{
			"ID": { 
				S: aws.String(id),
			},
		},
	})

	if err != nil {
		log.Printf("Erro no GetItem: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       "Erro ao buscar o registro específico.",
		}, nil
	}

	if result.Item == nil {
		return events.APIGatewayProxyResponse{
			StatusCode: 404,
			Body:       fmt.Sprintf("Registro com ID %s não encontrado.", id),
		}, nil
	}

	// Deserializa o item do DynamoDB para a estrutura Go
	value := models.Data{}
	err = dynamodbattribute.UnmarshalMap(result.Item, &value)
	if err != nil {
		log.Printf("Erro ao deserializar item: %v", err)
		return events.APIGatewayProxyResponse{
			StatusCode: 500,
			Body:       "Erro interno de processamento.",
		}, nil
	}

	// Converte o resultado em JSON
	responseBody, _ := json.Marshal(valor)
	return events.APIGatewayProxyResponse{
		StatusCode: 200,
		Headers:    map[string]string{"Content-Type": "application/json"},
		Body:       string(responseBody),
	}, nil
}

func main() {
	lambda.Start(handler)
}