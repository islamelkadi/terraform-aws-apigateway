# API Gateway REST API Module
# Creates AWS API Gateway REST API with Lambda integration, mock integrations, and CORS support

# REST API
resource "aws_api_gateway_rest_api" "this" {
  name        = local.api_name
  description = var.description != "" ? var.description : "API Gateway REST API ${local.api_name}"

  endpoint_configuration {
    types = var.endpoint_types
  }

  # Disable default endpoint if using custom domain
  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  tags = local.tags
}

# API Gateway Deployment
resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  # Force new deployment on configuration changes
  triggers = {
    redeployment = sha256(jsonencode([
      aws_api_gateway_rest_api.this.body,
      var.stage_name,
      var.stage_variables,
      var.mock_integrations,
      var.lambda_integration
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    aws_api_gateway_rest_api.this,
    aws_api_gateway_integration.mock,
    aws_api_gateway_integration.lambda_proxy
  ]
}

# API Gateway Stage
resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.stage_name
  description   = var.stage_description

  # X-Ray tracing (enabled by default for observability)
  xray_tracing_enabled = var.enable_xray_tracing

  # Access logging
  dynamic "access_log_settings" {
    for_each = var.enable_access_logging && var.cloudwatch_log_group_arn != null ? [1] : []
    content {
      destination_arn = var.cloudwatch_log_group_arn
      format          = var.access_log_format
    }
  }

  # Stage variables
  variables = var.stage_variables

  tags = local.tags

  depends_on = [
    aws_api_gateway_deployment.this,
    aws_api_gateway_account.this
  ]
}

# CloudWatch Log Group for API Gateway (if enabled)
resource "aws_cloudwatch_log_group" "api_gateway" {
  count = var.create_log_group ? 1 : 0
  
  name              = "/aws/apigateway/${local.api_name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = var.kms_key_arn
  
  tags = merge(
    module.metadata.security_tags,
    var.tags,
    {
      Name = "/aws/apigateway/${local.api_name}"
    }
  )
}

# API Gateway Account (for CloudWatch Logs role)
resource "aws_api_gateway_account" "this" {
  count = var.create_cloudwatch_role ? 1 : 0

  cloudwatch_role_arn = var.create_cloudwatch_role ? aws_iam_role.cloudwatch[0].arn : var.cloudwatch_role_arn
}

# IAM Role for CloudWatch Logs (if create_cloudwatch_role is true)
data "aws_iam_policy_document" "cloudwatch_assume_role" {
  count = var.create_cloudwatch_role ? 1 : 0

  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  count = var.create_cloudwatch_role ? 1 : 0

  name               = "${local.api_name}-cloudwatch"
  description        = "IAM role for API Gateway CloudWatch Logs"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role[0].json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "cloudwatch" {
  count = var.create_cloudwatch_role ? 1 : 0

  role       = aws_iam_role.cloudwatch[0].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# Method Settings (for throttling and caching)
resource "aws_api_gateway_method_settings" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  stage_name  = aws_api_gateway_stage.this.stage_name
  method_path = "*/*"

  settings {
    # Metrics
    metrics_enabled = var.enable_metrics
    logging_level   = var.logging_level

    # Throttling
    throttling_burst_limit = var.throttling_burst_limit
    throttling_rate_limit  = var.throttling_rate_limit

    # Caching
    caching_enabled      = var.enable_caching
    cache_ttl_in_seconds = var.enable_caching ? var.cache_ttl_seconds : null
    cache_data_encrypted = var.enable_caching ? var.cache_data_encrypted : null

    # Data trace
    data_trace_enabled = var.enable_data_trace
  }

  depends_on = [
    aws_api_gateway_stage.this
  ]
}

# ============================================================================
# Mock Integration Resources (for testing without backend services)
# ============================================================================

# Create resources for mock integrations
resource "aws_api_gateway_resource" "mock" {
  for_each = { for idx, integration in var.mock_integrations : idx => integration }

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = trimprefix(each.value.path, "/")
}

# Mock Integration Method
resource "aws_api_gateway_method" "mock" {
  for_each = { for idx, integration in var.mock_integrations : idx => integration }

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.mock[each.key].id
  http_method   = each.value.http_method
  authorization = each.value.authorization_type
}

# Mock Integration
resource "aws_api_gateway_integration" "mock" {
  for_each = { for idx, integration in var.mock_integrations : idx => integration }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mock[each.key].id
  http_method = aws_api_gateway_method.mock[each.key].http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": ${each.value.status_code}}"
  }

  depends_on = [
    aws_api_gateway_method.mock
  ]
}

# Mock Method Response
resource "aws_api_gateway_method_response" "mock" {
  for_each = { for idx, integration in var.mock_integrations : idx => integration }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mock[each.key].id
  http_method = aws_api_gateway_method.mock[each.key].http_method
  status_code = tostring(each.value.status_code)

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.mock
  ]
}

# Mock Integration Response
resource "aws_api_gateway_integration_response" "mock" {
  for_each = { for idx, integration in var.mock_integrations : idx => integration }

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.mock[each.key].id
  http_method = aws_api_gateway_method.mock[each.key].http_method
  status_code = aws_api_gateway_method_response.mock[each.key].status_code

  response_templates = {
    "application/json" = each.value.response_body
  }

  depends_on = [
    aws_api_gateway_integration.mock,
    aws_api_gateway_method_response.mock
  ]
}

# ============================================================================
# Lambda Integration Resources (optional)
# ============================================================================

# Lambda Integration Method
resource "aws_api_gateway_method" "lambda_proxy" {
  for_each = var.lambda_integration != null ? toset(var.lambda_integration.http_methods) : toset([])

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = var.lambda_integration.resource_id != null ? var.lambda_integration.resource_id : aws_api_gateway_rest_api.this.root_resource_id
  http_method   = each.value
  authorization = var.lambda_integration.authorization_type

  # Authorizer configuration
  authorizer_id = var.lambda_integration.authorizer_id

  # Request validation
  request_validator_id = var.lambda_integration.request_validator_id

  # API Key requirement
  api_key_required = var.lambda_integration.api_key_required
}

# Lambda Integration
resource "aws_api_gateway_integration" "lambda_proxy" {
  for_each = var.lambda_integration != null ? toset(var.lambda_integration.http_methods) : toset([])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.lambda_integration.resource_id != null ? var.lambda_integration.resource_id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.lambda_proxy[each.value].http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_integration.lambda_invoke_arn

  # Timeout
  timeout_milliseconds = var.lambda_integration.timeout_milliseconds

  depends_on = [
    aws_api_gateway_method.lambda_proxy
  ]
}

# Lambda Permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  for_each = var.lambda_integration != null ? toset(var.lambda_integration.http_methods) : toset([])

  statement_id  = "AllowAPIGatewayInvoke-${each.value}"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_integration.lambda_function_name
  principal     = "apigateway.amazonaws.com"

  # Allow invocation from this API Gateway
  source_arn = "${aws_api_gateway_rest_api.this.execution_arn}/*/*"
}

# Method Response (for Lambda proxy integration)
resource "aws_api_gateway_method_response" "lambda_proxy" {
  for_each = var.lambda_integration != null ? toset(var.lambda_integration.http_methods) : toset([])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.lambda_integration.resource_id != null ? var.lambda_integration.resource_id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.lambda_proxy[each.value].http_method
  status_code = "200"

  # CORS headers
  response_parameters = var.enable_cors ? {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  } : {}

  depends_on = [
    aws_api_gateway_method.lambda_proxy
  ]
}

# Integration Response (for Lambda proxy integration)
resource "aws_api_gateway_integration_response" "lambda_proxy" {
  for_each = var.lambda_integration != null ? toset(var.lambda_integration.http_methods) : toset([])

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = var.lambda_integration.resource_id != null ? var.lambda_integration.resource_id : aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.lambda_proxy[each.value].http_method
  status_code = aws_api_gateway_method_response.lambda_proxy[each.value].status_code

  # CORS headers
  response_parameters = var.enable_cors ? {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allow_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
  } : {}

  depends_on = [
    aws_api_gateway_integration.lambda_proxy,
    aws_api_gateway_method_response.lambda_proxy
  ]
}

# CORS Configuration (OPTIONS method for preflight)
resource "aws_api_gateway_method" "cors_options" {
  count = local.cors_resource_id != null ? 1 : 0

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = local.cors_resource_id == "root" ? aws_api_gateway_rest_api.this.root_resource_id : local.cors_resource_id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors_options" {
  count = local.cors_resource_id != null ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = local.cors_resource_id == "root" ? aws_api_gateway_rest_api.this.root_resource_id : local.cors_resource_id
  http_method = aws_api_gateway_method.cors_options[0].http_method

  type = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }

  depends_on = [
    aws_api_gateway_method.cors_options
  ]
}

resource "aws_api_gateway_method_response" "cors_options" {
  count = local.cors_resource_id != null ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = local.cors_resource_id == "root" ? aws_api_gateway_rest_api.this.root_resource_id : local.cors_resource_id
  http_method = aws_api_gateway_method.cors_options[0].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = true
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
  }

  response_models = {
    "application/json" = "Empty"
  }

  depends_on = [
    aws_api_gateway_method.cors_options
  ]
}

resource "aws_api_gateway_integration_response" "cors_options" {
  count = local.cors_resource_id != null ? 1 : 0

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = local.cors_resource_id == "root" ? aws_api_gateway_rest_api.this.root_resource_id : local.cors_resource_id
  http_method = aws_api_gateway_method.cors_options[0].http_method
  status_code = aws_api_gateway_method_response.cors_options[0].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Origin"  = "'${var.cors_allow_origin}'"
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors_allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'${join(",", var.cors_allow_methods)}'"
  }

  depends_on = [
    aws_api_gateway_integration.cors_options,
    aws_api_gateway_method_response.cors_options
  ]
}
