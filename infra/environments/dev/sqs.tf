resource "aws_sqs_queue" "sqs_lambda_example_queue" {
  name                       = "sqs-lambda-example-queue"
  visibility_timeout_seconds = 60
}
