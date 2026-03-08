# Primary Module Example - This demonstrates the terraform-aws-apigateway module
# Supporting infrastructure (KMS) is defined in separate files
# to keep this example focused on the module's core functionality.
#
# API Gateway Module Example
# Demonstrates API Gateway with mock integrations

module "api_gateway" {
  source = "../"

  namespace   = var.namespace
  environment = var.environment
  name        = var.name
  region      = var.region

  description = var.description

  # Endpoint configuration
  endpoint_types               = var.endpoint_types
  disable_execute_api_endpoint = var.disable_execute_api_endpoint

  # Lambda integration (optional)
  lambda_integration = var.lambda_integration

  # Mock integrations
  mock_integrations = var.mock_integrations

  # CORS configuration
  enable_cors        = var.enable_cors
  cors_allow_origin  = var.cors_allow_origin
  cors_allow_methods = var.cors_allow_methods
  cors_allow_headers = var.cors_allow_headers

  # Logging configuration
  enable_access_logging = var.enable_access_logging
  log_retention_days    = var.log_retention_days
  logging_level         = var.logging_level
  enable_data_trace     = var.enable_data_trace

  # Monitoring
  enable_xray_tracing = var.enable_xray_tracing
  enable_metrics      = var.enable_metrics

  # Throttling
  throttling_burst_limit = var.throttling_burst_limit
  throttling_rate_limit  = var.throttling_rate_limit

  # Caching
  enable_caching       = var.enable_caching
  cache_ttl_seconds    = var.cache_ttl_seconds
  cache_data_encrypted = var.cache_data_encrypted

  # Direct reference to kms.tf module output
  kms_key_arn = module.kms_key.key_arn

  # Stage configuration
  stage_name        = var.stage_name
  stage_description = var.stage_description
  stage_variables   = var.stage_variables

  tags = var.tags
}
