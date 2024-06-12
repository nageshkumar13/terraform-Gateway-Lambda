# This resource creates an API Gateway REST API with a specified name and description.

resource "aws_api_gateway_rest_api" "testAPI" {
  name        = "TestAPI"
  description = "This is my API for demonstration purposes"
  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

#Following resources define a resource named “testapi” under our API and a GET method associated with it.

resource "aws_api_gateway_resource" "testresource" {
  parent_id   = aws_api_gateway_rest_api.testAPI.root_resource_id
  path_part   = "testapi"
  rest_api_id = aws_api_gateway_rest_api.testAPI.id
}

# Get method 

resource "aws_api_gateway_method" "testMethod" {
  rest_api_id   = aws_api_gateway_rest_api.testAPI.id
  resource_id   = aws_api_gateway_resource.testresource.id
  http_method   = "GET"
  authorization = "NONE"
}

# This resource integrates our API Gateway with a Lambda function using the HTTP POST method.

resource "aws_api_gateway_integration" "MyDemoIntegration" {
  rest_api_id             = aws_api_gateway_rest_api.testAPI.id
  resource_id             = aws_api_gateway_resource.testresource.id
  http_method             = aws_api_gateway_method.testMethod.http_method
  integration_http_method = "POST"
  uri                     = aws_lambda_function.test_lambda.invoke_arn
  type                    = "AWS"
  passthrough_behavior    = "WHEN_NO_TEMPLATES"
}

# This resource deploys our API Gateway configuration.

resource "aws_api_gateway_deployment" "testdep" {
  rest_api_id = aws_api_gateway_rest_api.testAPI.id
  stage_name = "rain"
  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.testresource.id,
      aws_api_gateway_method.testMethod.id,
      aws_api_gateway_integration.MyDemoIntegration.id,
      aws_api_gateway_method_response.proxy.id,
      aws_api_gateway_integration_response.proxy.id
    ]))
  }
  lifecycle {
    create_before_destroy = true
  }
  
}

#Grant permission for API Gateway to invoke our Lambda function.

resource "aws_lambda_permission" "api_gw" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.test_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.testAPI.execution_arn}/*/*"
}


resource "aws_api_gateway_method_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.testAPI.id
  resource_id = aws_api_gateway_resource.testresource.id
  http_method = aws_api_gateway_method.testMethod.http_method
  status_code = "200"

  //cors section
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin" = true
  }
}

resource "aws_api_gateway_integration_response" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.testAPI.id
  resource_id = aws_api_gateway_resource.testresource.id
  http_method = aws_api_gateway_method.testMethod.http_method
  status_code = aws_api_gateway_method_response.proxy.status_code

    //cors
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" =  "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT'",
    "method.response.header.Access-Control-Allow-Origin" = "'*'"
}

  depends_on = [
    aws_api_gateway_method.testMethod,
    aws_api_gateway_integration.MyDemoIntegration
  ]
}