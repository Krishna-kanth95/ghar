resource "aws_cloudwatch_event_rule" "ec2_state_change" {
  name        = "ec2-state-change"
  description = "Capture EC2 state changes to pending"

  event_pattern = jsonencode({
    "source" : ["aws.ec2"],
    "detail-type" : ["EC2 Instance State-change Notification"],
    "detail" : {
      "state" : ["pending"]
    }
  })
}

resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "lambda_policy" {
  name        = "lambda-policy"
  description = "Give lambda access to S3, EC2 and CloudWatch Logs"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Statement1"
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Sid    = "Statement2"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "arn:aws:s3:::testlambda1buck/*"
        ]
      },
      {
        Sid    = "Statement3"
        Effect = "Allow"
        Action = [
          "logs:*"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_role_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Lambda function
resource "aws_lambda_function" "lambda_function" {
  function_name    = "TestLambdaFunction"
  role             = aws_iam_role.lambda_role.arn
  handler          = "main.lambda_handler" # The entry point in your code
  runtime          = "python3.11"          # Runtime language
  filename         = "lambda_function.zip" # This should contain your AWS Lambda function code
  timeout          = 60
  source_code_hash = filebase64sha256("lambda_function.zip")
}

# Allow the CloudWatch Event to trigger the Lambda function
resource "aws_lambda_permission" "lambda_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.ec2_state_change.arn
}

# CloudWatch Event Rule Target (Link rule to Lambda)
resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.ec2_state_change.name
  target_id = "SendToLambdaFunction"
  arn       = aws_lambda_function.lambda_function.arn
}

# Create S3 bucket
resource "aws_s3_bucket" "example_bucket" {
  bucket = "testlambda1bucket"
  acl    = "private"

  tags = {
    Name        = "my-unique-bucket-name"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_policy" "s3bucket_policy" {
  bucket = aws_s3_bucket.example_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = ["s3:GetObject", "s3:PutObject"]
        Effect   = "Allow"
        Resource = "${aws_s3_bucket.example_bucket.arn}/*"
        Principal = {
          AWS = "arn:aws:iam::751012142648:role/${aws_iam_role.lambda_role.name}"
        }
      }
    ]
  })
}

# Create an S3 bucket object (text file)
resource "aws_s3_bucket_object" "example_object" {
  bucket = aws_s3_bucket.example_bucket.id
  key    = "instance-ids.txt"
  source = "instance-ids.txt"          # Replace with the path to a local file
  etag   = filemd5("instance-ids.txt") # Replace with the path to the same local file
}
