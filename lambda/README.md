sqs-lambda-example-function
---

AWS Lambda functions using container images.

## Run at local

0. Login to ECR

    ```bash
    REGION='ap-northeast-1'
    ACCOUNT_ID=$(
      aws sts get-caller-identity \
      --query 'Account' \
      --output text) \
    && aws ecr get-login-password \
      --region "${REGION}" \
      | docker login \
      --username AWS \
      --password-stdin ${ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com
    ```

1. Build

    ```bash
    docker build -t sqs-lambda-example-function .
    ```

2. Run the image

    ```bash
    docker run \
    --rm \
    -p 9000:8080 \
    sqs-lambda-example-function:latest /main
    ```

3. Invoke function

    ```bash
    curl "http://localhost:9000/2015-03-31/functions/function/invocations"
    ```
