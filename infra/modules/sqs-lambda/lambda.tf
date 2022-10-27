resource "aws_lambda_function" "sqs_lambda_example_function" {
  for_each = { for f in var.functions : f.function_name => f }

  function_name = each.value.function_name
  role          = aws_iam_role.role_for_lambda[each.key].arn
  package_type  = "Image"
  image_uri     = each.value.image_uri
  timeout       = each.value.timeout
  memory_size   = each.value.memory_size
  environment {
    variables = {
      "COLOR" = each.value.function_color
    }
  }
}

# SQS message contains `color: red` to red function
resource "aws_lambda_event_source_mapping" "event_source_mapping_with_sqs" {
  for_each = { for f in var.functions : f.function_name => f }

  enabled          = true
  function_name    = aws_lambda_function.sqs_lambda_example_function[each.key].function_name
  batch_size       = 1
  event_source_arn = each.value.queue_arn
  filter_criteria {
    filter {
      pattern = jsonencode({
        body = {
          color : ["${each.value.function_color}"]
        }
      })
    }
  }
}

resource "aws_iam_role" "role_for_lambda" {
  for_each = { for f in var.functions : f.function_name => f }

  name = "role-for-${each.value.function_name}"

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
  for_each = { for f in var.functions : f.function_name => f }

  name = "policy-for-${each.value.function_name}"
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
        "Resource" : each.value.queue_arn
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "policy_attachment_for_function_role" {
  for_each = { for f in var.functions : f.function_name => f }

  name = "policy-attachment-for-${each.value.function_name}"

  roles = [
    aws_iam_role.role_for_lambda[each.key].name
  ]

  policy_arn = aws_iam_policy.policy_for_function[each.key].arn
}

