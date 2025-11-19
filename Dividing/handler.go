package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"strconv"
)

type InvokeRequest struct {
	Data     map[string]interface{} `json:"Data"`
	Metadata map[string]interface{} `json:"Metadata"`
}

type InvokeResponse struct {
	Outputs     map[string]interface{} `json:"Outputs"`
	Logs        []string               `json:"Logs"`
	ReturnValue interface{}            `json:"ReturnValue"`
}

type OperationResult struct {
	Operation string  `json:"operation"`
	A         float64 `json:"a"`
	B         float64 `json:"b"`
	Result    float64 `json:"result"`
}

type ErrorResponse struct {
	Error string `json:"error"`
}

func divideHandler(w http.ResponseWriter, r *http.Request) {
	log.Println("Go HTTP trigger function processed a request for division.")

	var invokeReq InvokeRequest
	d := json.NewDecoder(r.Body)
	if err := d.Decode(&invokeReq); err != nil {
		log.Printf("Error decoding request: %v", err)
		http.Error(w, "Bad request", http.StatusBadRequest)
		return
	}

	// Extract query parameters from the request
	var aStr, bStr string
	if reqData, ok := invokeReq.Data["req"].(map[string]interface{}); ok {
		if query, ok := reqData["Query"].(map[string]interface{}); ok {
			if a, ok := query["a"].(string); ok {
				aStr = a
			}
			if b, ok := query["b"].(string); ok {
				bStr = b
			}
		}
		// Check body if query params are not present
		if aStr == "" || bStr == "" {
			if body, ok := reqData["Body"].(map[string]interface{}); ok {
				if a, ok := body["a"]; ok {
					aStr = fmt.Sprintf("%v", a)
				}
				if b, ok := body["b"]; ok {
					bStr = fmt.Sprintf("%v", b)
				}
			}
		}
	}

	if aStr == "" || bStr == "" {
		errorResp := ErrorResponse{Error: "Please provide parameters 'a' and 'b' in query string or request body"}
		invokeResp := InvokeResponse{
			Outputs: map[string]interface{}{
				"res": map[string]interface{}{
					"StatusCode": 400,
					"Body":       errorResp,
				},
			},
		}
		respondJSON(w, invokeResp)
		return
	}

	a, err1 := strconv.ParseFloat(aStr, 64)
	b, err2 := strconv.ParseFloat(bStr, 64)

	if err1 != nil || err2 != nil {
		errorResp := ErrorResponse{Error: "Please provide valid numbers for parameters 'a' and 'b'"}
		invokeResp := InvokeResponse{
			Outputs: map[string]interface{}{
				"res": map[string]interface{}{
					"StatusCode": 400,
					"Body":       errorResp,
				},
			},
		}
		respondJSON(w, invokeResp)
		return
	}

	if b == 0 {
		errorResp := ErrorResponse{Error: "Division by zero is not allowed"}
		invokeResp := InvokeResponse{
			Outputs: map[string]interface{}{
				"res": map[string]interface{}{
					"StatusCode": 400,
					"Body":       errorResp,
				},
			},
		}
		respondJSON(w, invokeResp)
		return
	}

	result := a / b
	opResult := OperationResult{
		Operation: "division",
		A:         a,
		B:         b,
		Result:    result,
	}

	invokeResp := InvokeResponse{
		Outputs: map[string]interface{}{
			"res": map[string]interface{}{
				"StatusCode": 200,
				"Body":       opResult,
			},
		},
	}
	respondJSON(w, invokeResp)
}

func respondJSON(w http.ResponseWriter, data interface{}) {
	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(data)
}

func main() {
	customHandlerPort, exists := os.LookupEnv("FUNCTIONS_CUSTOMHANDLER_PORT")
	if !exists {
		customHandlerPort = "8080"
	}
	mux := http.NewServeMux()
	mux.HandleFunc("/divide", divideHandler)
	log.Printf("Go custom handler listening on port %s", customHandlerPort)
	log.Fatal(http.ListenAndServe(":"+customHandlerPort, mux))
}
