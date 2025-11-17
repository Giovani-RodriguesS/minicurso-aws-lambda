package internal

import (
	"encoding/json"
	"fmt"
	"github.com/Giovani-RodriguesS/minicurso-aws-lambda/src/pkg/models"
)

func ParseJsonToItem(body string) (models.Data, error) {
	var data models.Data
	if err := json.Unmarshal([]byte(body), &data); err != nil {
		return models.Data{}, err
	}
	return data, nil
}
