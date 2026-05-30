package models

type Land struct {
	LandID      string `json:"landID"`
	TokenID     string `json:"tokenID"`
	Owner       string `json:"owner"`
	Location    string `json:"location"`
	Area        string `json:"area"`
	LandType    string `json:"landType"`
	Status      string `json:"status"`
	CreatedAt   string `json:"createdAt"`
	LastUpdated string `json:"lastUpdated"`
}
