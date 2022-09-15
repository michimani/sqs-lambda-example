# function red
resource "aws_lambda_function" "sqs_lambda_example_function_red" {
  function_name = "sqs-lambda-example-function-red"
  role          = aws_iam_role.role_for_lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.sqs_lambda_example_function.repository_url}:latest"
  timeout       = 60
  memory_size   = 128
  environment {
    variables = {
      "COLOR" = "red"
    }
  }
}

# function blue
resource "aws_lambda_function" "sqs_lambda_example_function_blue" {
  function_name = "sqs-lambda-example-function-blue"
  role          = aws_iam_role.role_for_lambda.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.sqs_lambda_example_function.repository_url}:latest"
  timeout       = 60
  memory_size   = 128
  environment {
    variables = {
      "COLOR" = "blue"
    }
  }
}

resource "aws_iam_role" "role_for_lambda" {
  name = "sqs-lambda-example-function-role"

  assume_role_policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Action" : "sts:AssumeRole",
        "Principal" : {
          "Service" : "lambda.amazonaws.com"
        },
        "Effect" : "Allow",
        "Sid" : ""
      }
    ]
  })

}

resource "aws_iam_policy" "policy_for_function" {
  name = "sqs-lambda-example-function-policy"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "sqs:DeleteMessage",
          "sqs:GetQueueAttributes",
          "sqs:ReceiveMessage"
        ],
        "Resource" : "${aws_sqs_queue.sqs_lambda_example_queue.arn}"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "policy_attachment_for_function_role" {
  name = "policy-attachment-for-sqs-lambda-example-function-role"

  roles = [
    aws_iam_role.role_for_lambda.name
  ]

  policy_arn = aws_iam_policy.policy_for_function.arn
}

