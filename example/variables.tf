# API Gateway Module Example Variables

variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "name" {
  description = "Name of the API Gateway"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "description" {
  description = "Description of the API Gateway"
  type        = string
  default     = ""
}

variable "endpoint_types" {
  description = "List of endpoint types (EDGE, REGIONAL, PRIVATE)"
  type        = list(string)
  default     = ["REGIONAL"]
}

variable "disable_execute_api_endpoint" {
  description = "Whether to disable the default execute-api endpoint"
  type        = bool
  default     = false
}

variable "lambda_integration" {
  description = "Lambda integration configuration"
  type = object({
    lambda_function_name = string
    lambda_invoke_arn    = string
    http_methods         = list(string)
    authorization_type   = string
    api_key_required     = bool
    timeout_milliseconds = number
    resource_id          = optional(string)
  })
  default = null
}

variable "mock_integrations" {
  description = "List of mock integrations"
  type = list(object({
    path          = string
    http_method   = string
    status_code   = number
    response_body = string
  }))
  default = []
}

variable "enable_cors" {
  description = "Enable CORS configuration"
  type        = bool
  default     = false
}

variable "cors_allow_origin" {
  description = "CORS allowed origin"
  type        = string
  default     = "*"
}

variable "cors_allow_methods" {
  description = "CORS allowed methods"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

variable "cors_allow_headers" {
  description = "CORS allowed headers"
  type        = list(string)
  default     = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key"]
}

variable "enable_access_logging" {
  description = "Enable access logging"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "CloudWatch Logs retention in days"
  type        = number
  default     = 90
}

variable "logging_level" {
  description = "Logging level (OFF, ERROR, INFO)"
  type        = string
  default     = "INFO"
}

variable "enable_data_trace" {
  description = "Enable data trace logging"
  type        = bool
  default     = false
}

variable "enable_xray_tracing" {
  description = "Enable X-Ray tracing"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable detailed CloudWatch metrics"
  type        = bool
  default     = true
}

variable "throttling_burst_limit" {
  description = "Throttling burst limit"
  type        = number
  default     = 5000
}

variable "throttling_rate_limit" {
  description = "Throttling rate limit"
  type        = number
  default     = 10000
}

variable "enable_caching" {
  description = "Enable API caching"
  type        = bool
  default     = false
}

variable "cache_ttl_seconds" {
  description = "Cache TTL in seconds"
  type        = number
  default     = 300
}

variable "cache_data_encrypted" {
  description = "Encrypt cache data"
  type        = bool
  default     = true
}

variable "stage_name" {
  description = "Stage name"
  type        = string
  default     = "prod"
}

variable "stage_description" {
  description = "Stage description"
  type        = string
  default     = ""
}

variable "stage_variables" {
  description = "Stage variables"
  type        = map(string)
  default     = {}
}

variable "tags" {
  description = "Additional tags"
  type        = map(string)
  default     = {}
}

variable "waf_rate_limit" {
  description = "Rate limit for WAF (requests per 5-minute period from a single IP)"
  type        = number
  default     = 2000
}
