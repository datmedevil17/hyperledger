package main

import (
    "encoding/json"
    "fmt"
    "github.com/hyperledger/fabric-contract-api-go/contractapi"
)

type SmartContract struct {
    contractapi.Contract
}

type Asset struct {
    ID    string `json:"ID"`
    Owner string `json:"owner"`
    Value int    `json:"value"`
}

func (s *SmartContract) CreateAsset(ctx contractapi.TransactionContextInterface, id string, owner string, value int) error {
    asset := Asset{
        ID:    id,
        Owner: owner,
        Value: value,
    }
    
    assetJSON, err := json.Marshal(asset)
    if err != nil {
        return err
    }
    
    return ctx.GetStub().PutState(id, assetJSON)
}

func (s *SmartContract) ReadAsset(ctx contractapi.TransactionContextInterface, id string) (*Asset, error) {
    assetJSON, err := ctx.GetStub().GetState(id)
    if err != nil {
        return nil, fmt.Errorf("failed to read from world state: %v", err)
    }
    if assetJSON == nil {
        return nil, fmt.Errorf("the asset %s does not exist", id)
    }
    
    var asset Asset
    err = json.Unmarshal(assetJSON, &asset)
    if err != nil {
        return nil, err
    }
    
    return &asset, nil
}

func main() {
    assetChaincode, err := contractapi.NewChaincode(&SmartContract{})
    if err != nil {
        fmt.Printf("Error creating asset chaincode: %v", err)
        return
    }
    
    if err := assetChaincode.Start(); err != nil {
        fmt.Printf("Error starting asset chaincode: %v", err)
    }
}
