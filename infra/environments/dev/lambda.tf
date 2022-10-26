module "sqs_lambda_example_function" {
  source = "../../modules/sqs-lambda"

  functions = [
    {
      function_name  = "sqs-lambda-example-function-red"
      image_uri      = "${aws_ecr_repository.sqs_lambda_example_function.repository_url}:latest"
      timeout        = 60
      memory_size    = 128
      function_color = "red"
      queue_arn      = aws_sqs_queue.sqs_lambda_example_queue.arn
    },
    {
      function_name  = "sqs-lambda-example-function-blue"
      image_uri      = "${aws_ecr_repository.sqs_lambda_example_function.repository_url}:latest"
      timeout        = 60
      memory_size    = 128
      function_color = "blue"
      queue_arn      = aws_sqs_queue.sqs_lambda_example_queue.arn
    }
  ]
}
