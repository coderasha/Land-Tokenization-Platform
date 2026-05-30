package contract

import (
	"encoding/json"
	"fmt"
	"time"

	"landtoken/models"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type LandContract struct {
	contractapi.Contract
}

func (lc *LandContract) RegisterLand(
	ctx contractapi.TransactionContextInterface,
	landID string,
	tokenID string,
	owner string,
	location string,
	area string,
	landType string,
) error {

	exists, err := lc.LandExists(ctx, landID)
	if err != nil {
		return err
	}

	if exists {
		return fmt.Errorf("land %s already exists", landID)
	}

	land := models.Land{
		LandID:      landID,
		TokenID:     tokenID,
		Owner:       owner,
		Location:    location,
		Area:        area,
		LandType:    landType,
		Status:      "ACTIVE",
		CreatedAt:   time.Now().Format(time.RFC3339),
		LastUpdated: time.Now().Format(time.RFC3339),
	}

	landJSON, err := json.Marshal(land)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(landID, landJSON)
}

func (lc *LandContract) ReadLand(
	ctx contractapi.TransactionContextInterface,
	landID string,
) (*models.Land, error) {

	landJSON, err := ctx.GetStub().GetState(landID)
	if err != nil {
		return nil, err
	}

	if landJSON == nil {
		return nil, fmt.Errorf("land %s does not exist", landID)
	}

	var land models.Land
	err = json.Unmarshal(landJSON, &land)
	if err != nil {
		return nil, err
	}

	return &land, nil
}

func (lc *LandContract) TransferOwnership(
	ctx contractapi.TransactionContextInterface,
	landID string,
	newOwner string,
) error {

	land, err := lc.ReadLand(ctx, landID)
	if err != nil {
		return err
	}

	land.Owner = newOwner
	land.LastUpdated = time.Now().Format(time.RFC3339)

	updatedJSON, err := json.Marshal(land)
	if err != nil {
		return err
	}

	return ctx.GetStub().PutState(landID, updatedJSON)
}

func (lc *LandContract) LandExists(
	ctx contractapi.TransactionContextInterface,
	landID string,
) (bool, error) {

	data, err := ctx.GetStub().GetState(landID)
	if err != nil {
		return false, err
	}

	return data != nil, nil
}
