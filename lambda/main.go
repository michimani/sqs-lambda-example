package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	runtime "github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	Message    string `json:"message"`
	StatusCode int    `json:"statusCode"`
}

var count int

func handleRequest() (Response, error) {
	log.Println("start handler")
	defer log.Println("end handler")

	color := os.Getenv("COLOR")

	count++
	message := fmt.Sprintf("[%s] Hello AWS Lambda", color)
	for i := 0; i < count; i++ {
		message = message + "!"
	}

	return Response{
		Message:    message,
		StatusCode: http.StatusOK,
	}, nil
}

func init() {
	count = 0
	log.Println("init function called")
}

func main() {
	runtime.Start(handleRequest)
}
