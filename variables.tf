# API Gateway REST API Module Variables

# Metadata variables for consistent naming
variable "namespace" {
  description = "Namespace (organization/team name)"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "name" {
  description = "Name of the API Gateway REST API"
  type        = string
}

variable "attributes" {
  description = "Additional attributes for naming"
  type        = list(string)
  default     = []
}

variable "delimiter" {
  description = "Delimiter to use between name components"
  type        = string
  default     = "-"
}

variable "tags" {
  description = "Additional tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "region" {
  description = "AWS region where resources will be created"
  type        = string
}

# API Gateway configuration
variable "description" {
  description = "Description of the API Gateway REST API"
  type        = string
  default     = ""
}

variable "endpoint_types" {
  description = "List of endpoint types (EDGE, REGIONAL, or PRIVATE)"
  type        = list(string)
  default     = ["REGIONAL"]

  validation {
    condition = alltrue([
      for type in var.endpoint_types : contains(["EDGE", "REGIONAL", "PRIVATE"], type)
    ])
    error_message = "Endpoint types must be EDGE, REGIONAL, or PRIVATE"
  }
}

variable "disable_execute_api_endpoint" {
  description = "Whether to disable the default execute-api endpoint"
  type        = bool
  default     = false
}

# Stage configuration
variable "stage_name" {
  description = "Name of the API Gateway stage"
  type        = string
  default     = "prod"
}

variable "stage_description" {
  description = "Description of the API Gateway stage"
  type        = string
  default     = ""
}

variable "stage_variables" {
  description = "Map of stage variables"
  type        = map(string)
  default     = {}
}

# Lambda Integration configuration
variable "lambda_integration" {
  description = <<-EOT
    Lambda integration configuration. Set to null to disable Lambda integration.
    
    Fields:
    - lambda_function_name: Name of the Lambda function to integrate
    - lambda_invoke_arn: Invoke ARN of the Lambda function
    - http_methods: List of HTTP methods to integrate (e.g., ["GET", "POST"])
    - resource_id: API Gateway resource ID (optional, defaults to root resource)
    - authorization_type: Authorization type (NONE, AWS_IAM, CUSTOM, COGNITO_USER_POOLS)
    - authorizer_id: ID of the authorizer (optional)
    - request_validator_id: ID of the request validator (optional)
    - api_key_required: Whether API key is required (default: false)
    - timeout_milliseconds: Integration timeout in milliseconds (default: 29000)
  EOT

  type = object({
    lambda_function_name = string
    lambda_invoke_arn    = string
    http_methods         = list(string)
    resource_id          = optional(string, null)
    authorization_type   = optional(string, "NONE")
    authorizer_id        = optional(string, null)
    request_validator_id = optional(string, null)
    api_key_required     = optional(bool, false)
    timeout_milliseconds = optional(number, 29000)
  })
  default = null

  validation {
    condition = (
      var.lambda_integration == null ||
      can(var.lambda_integration.timeout_milliseconds >= 50 && var.lambda_integration.timeout_milliseconds <= 29000)
    )
    error_message = "Integration timeout must be between 50 and 29000 milliseconds"
  }
}

# Mock integrations (for testing without Lambda)
variable "mock_integrations" {
  description = <<-EOT
    List of mock API integrations for testing without backend services.
    Each integration includes:
    - path: API path (e.g., "/health", "/status")
    - http_method: HTTP method (GET, POST, etc.)
    - status_code: Response status code (default: 200)
    - response_body: Mock response body (default: {"message": "OK"})
    - authorization_type: Authorization type (default: NONE)
  EOT

  type = list(object({
    path               = string
    http_method        = string
    status_code        = optional(number, 200)
    response_body      = optional(string, "{\"message\": \"OK\"}")
    authorization_type = optional(string, "NONE")
  }))
  default = []
}

# CORS configuration
variable "enable_cors" {
  description = "Enable CORS configuration"
  type        = bool
  default     = false
}

variable "cors_allow_origin" {
  description = "Allowed origin for CORS (e.g., '*' or 'https://example.com')"
  type        = string
  default     = "*"
}

variable "cors_allow_headers" {
  description = "Allowed headers for CORS"
  type        = list(string)
  default = [
    "Content-Type",
    "X-Amz-Date",
    "Authorization",
    "X-Api-Key",
    "X-Amz-Security-Token"
  ]
}

variable "cors_allow_methods" {
  description = "Allowed methods for CORS"
  type        = list(string)
  default     = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
}

# Logging configuration
variable "enable_access_logging" {
  description = "Enable access logging to CloudWatch Logs"
  type        = bool
  default     = true
}

variable "cloudwatch_log_group_arn" {
  description = "ARN of CloudWatch Log Group for access logs. If not provided and create_log_group is true, a log group will be created"
  type        = string
  default     = null
}

variable "access_log_format" {
  description = "Format for access logs (JSON format recommended)"
  type        = string
  default     = "$context.requestId $context.extendedRequestId $context.identity.sourceIp $context.requestTime $context.httpMethod $context.routeKey $context.status $context.protocol $context.responseLength"
}

variable "create_log_group" {
  description = "Whether to create a CloudWatch Log Group for API Gateway"
  type        = bool
  default     = true
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 365

  validation {
    condition = contains([
      1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1096, 1827, 2192, 2557, 2922, 3288, 3653
    ], var.log_retention_days)
    error_message = "Log retention days must be a valid CloudWatch Logs retention period"
  }
}

variable "logging_level" {
  description = "Logging level for API Gateway (OFF, ERROR, INFO)"
  type        = string
  default     = "INFO"

  validation {
    condition     = contains(["OFF", "ERROR", "INFO"], var.logging_level)
    error_message = "Logging level must be OFF, ERROR, or INFO"
  }
}

# CloudWatch role configuration
variable "create_cloudwatch_role" {
  description = "Whether to create an IAM role for CloudWatch Logs"
  type        = bool
  default     = true
}

variable "cloudwatch_role_arn" {
  description = "ARN of IAM role for CloudWatch Logs. Only used if create_cloudwatch_role is false"
  type        = string
  default     = null
}

# Monitoring configuration
variable "enable_xray_tracing" {
  description = "Enable AWS X-Ray tracing"
  type        = bool
  default     = true
}

variable "enable_metrics" {
  description = "Enable CloudWatch metrics"
  type        = bool
  default     = true
}

variable "enable_data_trace" {
  description = "Enable data trace logging (logs full request/response data)"
  type        = bool
  default     = false
}

# Throttling configuration
variable "throttling_burst_limit" {
  description = "API Gateway throttling burst limit"
  type        = number
  default     = 5000

  validation {
    condition     = var.throttling_burst_limit >= 0
    error_message = "Throttling burst limit must be a non-negative number"
  }
}

variable "throttling_rate_limit" {
  description = "API Gateway throttling rate limit (requests per second)"
  type        = number
  default     = 10000

  validation {
    condition     = var.throttling_rate_limit >= 0
    error_message = "Throttling rate limit must be a non-negative number"
  }
}

# Caching configuration
variable "enable_caching" {
  description = "Enable API Gateway caching"
  type        = bool
  default     = false
}

variable "cache_ttl_seconds" {
  description = "Cache TTL in seconds"
  type        = number
  default     = 300

  validation {
    condition     = var.cache_ttl_seconds >= 0 && var.cache_ttl_seconds <= 3600
    error_message = "Cache TTL must be between 0 and 3600 seconds"
  }
}

variable "cache_data_encrypted" {
  description = "Whether to encrypt cache data"
  type        = bool
  default     = true
}

# Encryption
variable "kms_key_arn" {
  description = "ARN of KMS key for encryption. If not provided, uses AWS managed key"
  type        = string
  default     = null
}

# WAF Configuration
variable "waf_acl_arn" {
  description = "ARN of the WAF Web ACL to associate with the API Gateway stage. Required for production environments to protect against common web exploits"
  type        = string
}

# Security Controls
variable "security_controls" {
  description = "Security controls configuration from metadata module. Used to enforce security standards"
  type = object({
    encryption = object({
      require_kms_customer_managed  = bool
      require_encryption_at_rest    = bool
      require_encryption_in_transit = bool
      enable_kms_key_rotation       = bool
    })
    logging = object({
      require_cloudwatch_logs = bool
      min_log_retention_days  = number
      require_access_logging  = bool
      require_flow_logs       = bool
    })
    monitoring = object({
      enable_xray_tracing         = bool
      enable_enhanced_monitoring  = bool
      enable_performance_insights = bool
      require_cloudtrail          = bool
    })
    network = object({
      require_private_subnets = bool
      require_vpc_endpoints   = bool
      block_public_ingress    = bool
      require_imdsv2          = bool
    })
    compliance = object({
      enable_point_in_time_recovery = bool
      require_reserved_concurrency  = bool
      enable_deletion_protection    = bool
    })
  })
  default = null
}

# Security Control Overrides
variable "security_control_overrides" {
  description = <<-EOT
    Override specific security controls for this API Gateway.
    Only use when there's a documented business justification.
    
    Example use cases:
    - disable_access_logging: Development APIs with no sensitive data
    - disable_xray_tracing: Cost optimization for low-value APIs
    - disable_kms_requirement: Public APIs with no sensitive data
    
    IMPORTANT: Document the reason in the 'justification' field for audit purposes.
  EOT

  type = object({
    disable_access_logging           = optional(bool, false)
    disable_xray_tracing             = optional(bool, false)
    disable_kms_requirement          = optional(bool, false)
    disable_cloudwatch_logs          = optional(bool, false)
    disable_log_retention_validation = optional(bool, false)

    # Audit trail - document why controls are disabled
    justification = optional(string, "")
  })

  default = {
    disable_access_logging           = false
    disable_xray_tracing             = false
    disable_kms_requirement          = false
    disable_cloudwatch_logs          = false
    disable_log_retention_validation = false
    justification                    = ""
  }
}
