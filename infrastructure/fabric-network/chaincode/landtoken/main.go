package main

import (
	"log"

	"landtoken/contract"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
)

func main() {

	landContract := new(contract.LandContract)

	cc, err := contractapi.NewChaincode(landContract)
	if err != nil {
		log.Panicf("Error creating chaincode: %v", err)
	}

	if err := cc.Start(); err != nil {
		log.Panicf("Error starting chaincode: %v", err)
	}
}
