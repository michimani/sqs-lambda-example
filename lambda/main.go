package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/aws/aws-lambda-go/events"
	runtime "github.com/aws/aws-lambda-go/lambda"
)

type Response struct {
	Message    string `json:"message"`
	StatusCode int    `json:"statusCode"`
}

type QueueMessage struct {
	Color string `json:"color,omitempty"`
	Text  string `json:"text,omitempty"`
}

func (qm *QueueMessage) fromString(body string) error {
	return json.Unmarshal([]byte(body), qm)
}

func handleRequest(ctx context.Context, sqsEvent events.SQSEvent) (Response, error) {
	log.Println("start handler")
	defer log.Println("end handler")

	color := os.Getenv("COLOR")
	fmt.Printf("This is %s function\n", color)

	resMessage := ""

	for i, message := range sqsEvent.Records {
		fmt.Printf("The message %s for event source %s\n", message.MessageId, message.EventSource)

		qmsg := &QueueMessage{}
		err := qmsg.fromString(message.Body)
		if err != nil {
			fmt.Printf("Invalid message struct: %s err=%v\n", message.Body, err)
			continue
		}

		res := fmt.Sprintf("Color{%d}: %s, Text{%d}:%s. ", i, qmsg.Color, i, qmsg.Text)
		resMessage += res
		fmt.Println(res)
	}

	return Response{
		Message:    resMessage,
		StatusCode: http.StatusOK,
	}, nil
}

func init() {
	log.Println("cold start")
}

func main() {
	runtime.Start(handleRequest)
}
