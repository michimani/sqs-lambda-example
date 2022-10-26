resource "aws_lambda_function" "sqs_lambda_example_function" {
  count = length(var.functions)

  function_name = var.functions[count.index].function_name
  role          = aws_iam_role.role_for_lambda[count.index].arn
  package_type  = "Image"
  image_uri     = var.functions[count.index].image_uri
  timeout       = var.functions[count.index].timeout
  memory_size   = var.functions[count.index].memory_size
  environment {
    variables = {
      "COLOR" = var.functions[count.index].function_color
    }
  }
}

# SQS message contains `color: red` to red function
resource "aws_lambda_event_source_mapping" "event_source_mapping_with_sqs" {
  count = length(var.functions)

  enabled          = true
  function_name    = var.functions[count.index].function_name
  batch_size       = 1
  event_source_arn = var.functions[count.index].queue_arn
  filter_criteria {
    filter {
      pattern = jsonencode({
        body = {
          color : ["${var.functions[count.index].function_color}"]
        }
      })
    }
  }
}

resource "aws_iam_role" "role_for_lambda" {
  count = length(var.functions)

  name = "role-for-${var.functions[count.index].function_name}"

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
  count = length(var.functions)

  name = "policy-for-${var.functions[count.index].function_name}"
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
        "Resource" : var.functions[count.index].queue_arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "policy_attachment_for_function_role" {
  count = length(var.functions)

  name = "policy-attachment-for-${var.functions[count.index].function_name}"

  roles = [
    aws_iam_role.role_for_lambda[count.index].name
  ]

  policy_arn = aws_iam_policy.policy_for_function[count.index].arn
}

