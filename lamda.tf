# define Lambda function - 
# This resource defines a Lambda function named “TestAPI” using the specified handler and runtime.

resource "aws_lambda_function" "test_lambda" {
  filename         = data.archive_file.code.output_path
  function_name    = "TestAPI"
  role             = aws_iam_role.iam_for_lambda.arn
  handler          = "lambda_function.lambda_handler"
  runtime          = "python3.8"
  source_code_hash = data.archive_file.code.output_base64sha256
}

data "archive_file" "code" {
  type        = "zip"
  source_dir  = "${path.module}/code"
  output_path = "${path.module}/code/lambda_function.zip"
}
