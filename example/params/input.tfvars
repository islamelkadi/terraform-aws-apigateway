# API Gateway Module Example Input Variables

namespace   = "example"
environment = "dev"
name        = "demo-api"
region      = "us-east-1"

description = "Example API Gateway with mock integrations"

# Endpoint configuration
endpoint_types               = ["REGIONAL"]
disable_execute_api_endpoint = false

# Lambda integration (optional - set to null to use only mock integrations)
lambda_integration = {
  lambda_function_name = "my-function"
  lambda_invoke_arn    = "arn:aws:lambda:us-east-1:123456789012:function:my-function"
  http_methods         = ["GET", "POST", "PUT", "DELETE"]
  authorization_type   = "NONE"
  api_key_required     = false
  timeout_milliseconds = 29000
}

# Mock integrations (for testing without Lambda)
mock_integrations = [
  {
    path          = "/health"
    http_method   = "GET"
    status_code   = 200
    response_body = "{\"status\":\"healthy\",\"service\":\"api-gateway\",\"version\":\"1.0.0\"}"
  },
  {
    path          = "/status"
    http_method   = "GET"
    status_code   = 200
    response_body = "{\"status\":\"operational\",\"timestamp\":\"2024-03-03T00:00:00Z\"}"
  },
  {
    path          = "/error"
    http_method   = "GET"
    status_code   = 500
    response_body = "{\"error\":\"Internal Server Error\",\"message\":\"This is a mock error response\"}"
  }
]

# CORS configuration
enable_cors        = true
cors_allow_origin  = "https://example.com"
cors_allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
cors_allow_headers = [
  "Content-Type",
  "X-Amz-Date",
  "Authorization",
  "X-Api-Key",
  "X-Amz-Security-Token"
]

# Logging configuration
enable_access_logging = true
log_retention_days    = 90
logging_level         = "INFO"
enable_data_trace     = false

# Monitoring
enable_xray_tracing = true
enable_metrics      = true

# Throttling
throttling_burst_limit = 5000
throttling_rate_limit  = 10000

# Caching
enable_caching       = true
cache_ttl_seconds    = 300
cache_data_encrypted = true

# Encryption (optional - replace with your KMS key ARN)
# kms_key_arn = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
kms_key_arn = null

# Stage configuration
stage_name        = "prod"
stage_description = "Production stage"
stage_variables = {
  environment = "production"
}

tags = {
  Example     = "API_GATEWAY"
  Environment = "PRODUCTION"
}

# WAF Configuration
waf_rate_limit = 2000 # requests per 5-minute period from a single IP
