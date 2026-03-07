# Terraform AWS API Gateway REST API Module

This module creates an AWS API Gateway REST API with Lambda integration, mock integrations, CORS support, and security best practices.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Security](#security)
- [Features](#features)
- [Usage](#usage)
- [Requirements](#requirements)
- [MCP Servers](#mcp-servers)
- [License](#license)


## Prerequisites

This module is designed for macOS. The following must already be installed on your machine:
- Python 3 and pip
- [Kiro](https://kiro.dev) and Kiro CLI
- [Homebrew](https://brew.sh)

To install the remaining development tools, run:

```bash
make bootstrap
```

This will install/upgrade: tfenv, Terraform (via tfenv), tflint, terraform-docs, checkov, and pre-commit.



## Security

### Security Controls

This module implements security controls to comply with:
- AWS Foundational Security Best Practices (FSBP)
- CIS AWS Foundations Benchmark
- NIST 800-53 Rev 5
- NIST 800-171 Rev 2
- PCI DSS v4.0

### Implemented Controls

- [x] **Access Logging**: CloudWatch Logs for API access monitoring
- [x] **X-Ray Tracing**: Distributed tracing for observability
- [x] **KMS Encryption**: Customer-managed keys for log encryption
- [x] **Log Retention**: Configurable retention policies (365 days recommended)
- [x] **Throttling**: Rate limiting to prevent abuse
- [x] **Authorization**: IAM, Cognito, or Lambda authorizers
- [x] **Security Control Overrides**: Extensible override system with audit justification

### Security Best Practices

**Production APIs:**
- Enable access logging with 365-day retention
- Enable X-Ray tracing for observability
- Use KMS customer-managed keys for log encryption
- Configure throttling limits
- Use IAM or Cognito authorizers for authentication
- Enable CORS only for trusted origins
- Use private or regional endpoints when possible

**Development APIs:**
- Access logging optional for cost savings
- X-Ray tracing optional
- Shorter log retention acceptable

For complete security standards and implementation details, see [AWS Security Standards](../../../.kiro/steering/aws/aws-security-standards.md).

### Environment-Based Security Controls

Security controls are automatically applied based on the environment through the [terraform-aws-metadata](https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles){:target="_blank"} module's security profiles:

| Control | Dev | Staging | Prod |
|---------|-----|---------|------|
| KMS customer-managed keys | Optional | Required | Required |
| Access logging | Optional | Required | Required |
| X-Ray tracing | Optional | Required | Required |
| Log retention | 7 days | 90 days | 365 days |
| Throttling | Relaxed | Production-like | Enforced |

For full details on security profiles and how controls vary by environment, see the <a href="https://github.com/islamelkadi/terraform-aws-metadata?tab=readme-ov-file#security-profiles" target="_blank">Security Profiles</a> documentation.

### Security Best Practices

**Production APIs:**
- Enable access logging with 365-day retention
- Enable X-Ray tracing for observability
- Use KMS customer-managed keys for log encryption
- Configure throttling limits
- Use IAM or Cognito authorizers for authentication
- Enable CORS only for trusted origins
- Use private or regional endpoints when possible

**Development APIs:**
- Access logging optional for cost savings
- X-Ray tracing optional
- Shorter log retention acceptable

For complete security standards and implementation details, see [AWS Security Standards](../../../.kiro/steering/aws/aws-security-standards.md).
## Features

- REST API with configurable endpoint types (EDGE, REGIONAL, PRIVATE)
- Lambda proxy integration with automatic permission management
- Mock integrations for testing without backend services
- CORS configuration with preflight OPTIONS support
- CloudWatch Logs integration for access logging
- X-Ray tracing for observability
- IAM role for CloudWatch Logs
- Throttling and caching configuration
- Security controls with override capability

## Usage

### Basic Example

```hcl
module "review_api" {
  source = "../../modules/terraform-aws-apigateway"

  namespace   = "example"
  environment = "prod"
  name        = "review-api"
  region      = "us-east-1"

  # Lambda integration
  lambda_integration = {
    lambda_function_name = module.review_lambda.function_name
    lambda_invoke_arn    = module.review_lambda.function_invoke_arn
    http_methods         = ["GET", "POST"]
    authorization_type   = "NONE"
  }

  # CORS configuration
  enable_cors        = true
  cors_allow_origin  = "https://dashboard.example.com"
  cors_allow_methods = ["GET", "POST", "OPTIONS"]

  tags = {
    Project = "corporate-actions"
  }
}
```

### Mock Integration Example (No Lambda Required)

```hcl
module "mock_api" {
  source = "../../modules/terraform-aws-apigateway"

  namespace   = "example"
  environment = "dev"
  name        = "mock-api"
  region      = "us-east-1"

  # Mock integrations for testing
  mock_integrations = [
    {
      path          = "/health"
      http_method   = "GET"
      status_code   = 200
      response_body = jsonencode({
        status  = "healthy"
        service = "api-gateway"
      })
    },
    {
      path          = "/status"
      http_method   = "GET"
      status_code   = 200
      response_body = jsonencode({
        status = "operational"
      })
    }
  ]

  # CORS configuration
  enable_cors        = true
  cors_allow_origin  = "*"
  cors_allow_methods = ["GET", "OPTIONS"]

  tags = {
    Purpose = "testing"
  }
}
```


### Complete Example with Security Controls

```hcl
module "review_api" {
  source = "../../modules/terraform-aws-apigateway"

  namespace   = "example"
  environment = "prod"
  name        = "review-api"
  region      = "us-east-1"

  # Lambda integration
  lambda_integration = {
    lambda_function_name = module.review_lambda.function_name
    lambda_invoke_arn    = module.review_lambda.function_invoke_arn
    http_methods         = ["GET", "POST", "PUT", "DELETE"]
    authorization_type   = "AWS_IAM"
    timeout_milliseconds = 29000
  }

  # CORS configuration
  enable_cors        = true
  cors_allow_origin  = "https://dashboard.example.com"
  cors_allow_methods = ["GET", "POST", "PUT", "DELETE", "OPTIONS"]
  cors_allow_headers = ["Content-Type", "Authorization"]

  # Logging
  enable_access_logging = true
  log_retention_days    = 365
  logging_level         = "INFO"

  # Monitoring
  enable_xray_tracing = true
  enable_metrics      = true

  # Throttling
  throttling_burst_limit = 5000
  throttling_rate_limit  = 10000

  # Encryption
  kms_key_arn = module.kms.key_arn

  # Security controls
  security_controls = module.metadata.security_controls

  tags = {
    Project = "corporate-actions"
  }
}
```


## License

MIT Licensed. See LICENSE for full details.


## MCP Servers

This module includes two [Model Context Protocol (MCP)](https://modelcontextprotocol.io/) servers configured in `.kiro/settings/mcp.json` for use with Kiro:

| Server | Package | Description |
|--------|---------|-------------|
| `aws-docs` | `awslabs.aws-documentation-mcp-server@latest` | Provides access to AWS documentation for contextual lookups of service features, API references, and best practices. |
| `terraform` | `awslabs.terraform-mcp-server@latest` | Enables Terraform operations (init, validate, plan, fmt, tflint) directly from the IDE with auto-approved commands for common workflows. |

Both servers run via `uvx` and require no additional installation beyond the [bootstrap](#prerequisites) step.

<!-- BEGIN_TF_DOCS -->


## Usage

```hcl
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

  # Encryption (optional)
  kms_key_arn = var.kms_key_arn

  # Stage configuration
  stage_name        = var.stage_name
  stage_description = var.stage_description
  stage_variables   = var.stage_variables

  tags = var.tags
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.14.3 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 6.34 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 6.34 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_log_group"></a> [log\_group](#module\_log\_group) | ../terraform-aws-cloudwatch/modules/logs | n/a |
| <a name="module_metadata"></a> [metadata](#module\_metadata) | github.com/islamelkadi/terraform-aws-metadata | v1.1.0 |

## Resources

| Name | Type |
|------|------|
| [aws_api_gateway_account.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_account) | resource |
| [aws_api_gateway_deployment.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_deployment) | resource |
| [aws_api_gateway_integration.cors_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration.mock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration) | resource |
| [aws_api_gateway_integration_response.cors_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_integration_response.mock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_integration_response) | resource |
| [aws_api_gateway_method.cors_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method.mock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method) | resource |
| [aws_api_gateway_method_response.cors_options](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.lambda_proxy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_response.mock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_response) | resource |
| [aws_api_gateway_method_settings.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_method_settings) | resource |
| [aws_api_gateway_resource.mock](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_resource) | resource |
| [aws_api_gateway_rest_api.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_rest_api) | resource |
| [aws_api_gateway_stage.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/api_gateway_stage) | resource |
| [aws_iam_role.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.cloudwatch](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_lambda_permission.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_permission) | resource |
| [aws_iam_policy_document.cloudwatch_assume_role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_access_log_format"></a> [access\_log\_format](#input\_access\_log\_format) | Format for access logs (JSON format recommended) | `string` | `"$context.requestId $context.extendedRequestId $context.identity.sourceIp $context.requestTime $context.httpMethod $context.routeKey $context.status $context.protocol $context.responseLength"` | no |
| <a name="input_attributes"></a> [attributes](#input\_attributes) | Additional attributes for naming | `list(string)` | `[]` | no |
| <a name="input_cache_data_encrypted"></a> [cache\_data\_encrypted](#input\_cache\_data\_encrypted) | Whether to encrypt cache data | `bool` | `true` | no |
| <a name="input_cache_ttl_seconds"></a> [cache\_ttl\_seconds](#input\_cache\_ttl\_seconds) | Cache TTL in seconds | `number` | `300` | no |
| <a name="input_cloudwatch_log_group_arn"></a> [cloudwatch\_log\_group\_arn](#input\_cloudwatch\_log\_group\_arn) | ARN of CloudWatch Log Group for access logs. If not provided and create\_log\_group is true, a log group will be created | `string` | `null` | no |
| <a name="input_cloudwatch_role_arn"></a> [cloudwatch\_role\_arn](#input\_cloudwatch\_role\_arn) | ARN of IAM role for CloudWatch Logs. Only used if create\_cloudwatch\_role is false | `string` | `null` | no |
| <a name="input_cors_allow_headers"></a> [cors\_allow\_headers](#input\_cors\_allow\_headers) | Allowed headers for CORS | `list(string)` | <pre>[<br/>  "Content-Type",<br/>  "X-Amz-Date",<br/>  "Authorization",<br/>  "X-Api-Key",<br/>  "X-Amz-Security-Token"<br/>]</pre> | no |
| <a name="input_cors_allow_methods"></a> [cors\_allow\_methods](#input\_cors\_allow\_methods) | Allowed methods for CORS | `list(string)` | <pre>[<br/>  "GET",<br/>  "POST",<br/>  "PUT",<br/>  "DELETE",<br/>  "OPTIONS"<br/>]</pre> | no |
| <a name="input_cors_allow_origin"></a> [cors\_allow\_origin](#input\_cors\_allow\_origin) | Allowed origin for CORS (e.g., '*' or 'https://example.com') | `string` | `"*"` | no |
| <a name="input_create_cloudwatch_role"></a> [create\_cloudwatch\_role](#input\_create\_cloudwatch\_role) | Whether to create an IAM role for CloudWatch Logs | `bool` | `true` | no |
| <a name="input_create_log_group"></a> [create\_log\_group](#input\_create\_log\_group) | Whether to create a CloudWatch Log Group for API Gateway | `bool` | `true` | no |
| <a name="input_delimiter"></a> [delimiter](#input\_delimiter) | Delimiter to use between name components | `string` | `"-"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the API Gateway REST API | `string` | `""` | no |
| <a name="input_disable_execute_api_endpoint"></a> [disable\_execute\_api\_endpoint](#input\_disable\_execute\_api\_endpoint) | Whether to disable the default execute-api endpoint | `bool` | `false` | no |
| <a name="input_enable_access_logging"></a> [enable\_access\_logging](#input\_enable\_access\_logging) | Enable access logging to CloudWatch Logs | `bool` | `true` | no |
| <a name="input_enable_caching"></a> [enable\_caching](#input\_enable\_caching) | Enable API Gateway caching | `bool` | `false` | no |
| <a name="input_enable_cors"></a> [enable\_cors](#input\_enable\_cors) | Enable CORS configuration | `bool` | `false` | no |
| <a name="input_enable_data_trace"></a> [enable\_data\_trace](#input\_enable\_data\_trace) | Enable data trace logging (logs full request/response data) | `bool` | `false` | no |
| <a name="input_enable_metrics"></a> [enable\_metrics](#input\_enable\_metrics) | Enable CloudWatch metrics | `bool` | `true` | no |
| <a name="input_enable_xray_tracing"></a> [enable\_xray\_tracing](#input\_enable\_xray\_tracing) | Enable AWS X-Ray tracing | `bool` | `true` | no |
| <a name="input_endpoint_types"></a> [endpoint\_types](#input\_endpoint\_types) | List of endpoint types (EDGE, REGIONAL, or PRIVATE) | `list(string)` | <pre>[<br/>  "REGIONAL"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_kms_key_arn"></a> [kms\_key\_arn](#input\_kms\_key\_arn) | ARN of KMS key for encryption. If not provided, uses AWS managed key | `string` | `null` | no |
| <a name="input_lambda_integration"></a> [lambda\_integration](#input\_lambda\_integration) | Lambda integration configuration. Set to null to disable Lambda integration.<br/><br/>Fields:<br/>- lambda\_function\_name: Name of the Lambda function to integrate<br/>- lambda\_invoke\_arn: Invoke ARN of the Lambda function<br/>- http\_methods: List of HTTP methods to integrate (e.g., ["GET", "POST"])<br/>- resource\_id: API Gateway resource ID (optional, defaults to root resource)<br/>- authorization\_type: Authorization type (NONE, AWS\_IAM, CUSTOM, COGNITO\_USER\_POOLS)<br/>- authorizer\_id: ID of the authorizer (optional)<br/>- request\_validator\_id: ID of the request validator (optional)<br/>- api\_key\_required: Whether API key is required (default: false)<br/>- timeout\_milliseconds: Integration timeout in milliseconds (default: 29000) | <pre>object({<br/>    lambda_function_name = string<br/>    lambda_invoke_arn    = string<br/>    http_methods         = list(string)<br/>    resource_id          = optional(string, null)<br/>    authorization_type   = optional(string, "NONE")<br/>    authorizer_id        = optional(string, null)<br/>    request_validator_id = optional(string, null)<br/>    api_key_required     = optional(bool, false)<br/>    timeout_milliseconds = optional(number, 29000)<br/>  })</pre> | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | Number of days to retain CloudWatch logs | `number` | `30` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | Logging level for API Gateway (OFF, ERROR, INFO) | `string` | `"INFO"` | no |
| <a name="input_mock_integrations"></a> [mock\_integrations](#input\_mock\_integrations) | List of mock API integrations for testing without backend services.<br/>Each integration includes:<br/>- path: API path (e.g., "/health", "/status")<br/>- http\_method: HTTP method (GET, POST, etc.)<br/>- status\_code: Response status code (default: 200)<br/>- response\_body: Mock response body (default: {"message": "OK"})<br/>- authorization\_type: Authorization type (default: NONE) | <pre>list(object({<br/>    path               = string<br/>    http_method        = string<br/>    status_code        = optional(number, 200)<br/>    response_body      = optional(string, "{\"message\": \"OK\"}")<br/>    authorization_type = optional(string, "NONE")<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the API Gateway REST API | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region where resources will be created | `string` | n/a | yes |
| <a name="input_security_control_overrides"></a> [security\_control\_overrides](#input\_security\_control\_overrides) | Override specific security controls for this API Gateway.<br/>Only use when there's a documented business justification.<br/><br/>Example use cases:<br/>- disable\_access\_logging: Development APIs with no sensitive data<br/>- disable\_xray\_tracing: Cost optimization for low-value APIs<br/>- disable\_kms\_requirement: Public APIs with no sensitive data<br/><br/>IMPORTANT: Document the reason in the 'justification' field for audit purposes. | <pre>object({<br/>    disable_access_logging           = optional(bool, false)<br/>    disable_xray_tracing             = optional(bool, false)<br/>    disable_kms_requirement          = optional(bool, false)<br/>    disable_cloudwatch_logs          = optional(bool, false)<br/>    disable_log_retention_validation = optional(bool, false)<br/><br/>    # Audit trail - document why controls are disabled<br/>    justification = optional(string, "")<br/>  })</pre> | <pre>{<br/>  "disable_access_logging": false,<br/>  "disable_cloudwatch_logs": false,<br/>  "disable_kms_requirement": false,<br/>  "disable_log_retention_validation": false,<br/>  "disable_xray_tracing": false,<br/>  "justification": ""<br/>}</pre> | no |
| <a name="input_security_controls"></a> [security\_controls](#input\_security\_controls) | Security controls configuration from metadata module. Used to enforce security standards | <pre>object({<br/>    encryption = object({<br/>      require_kms_customer_managed  = bool<br/>      require_encryption_at_rest    = bool<br/>      require_encryption_in_transit = bool<br/>      enable_kms_key_rotation       = bool<br/>    })<br/>    logging = object({<br/>      require_cloudwatch_logs = bool<br/>      min_log_retention_days  = number<br/>      require_access_logging  = bool<br/>      require_flow_logs       = bool<br/>    })<br/>    monitoring = object({<br/>      enable_xray_tracing         = bool<br/>      enable_enhanced_monitoring  = bool<br/>      enable_performance_insights = bool<br/>      require_cloudtrail          = bool<br/>    })<br/>    network = object({<br/>      require_private_subnets = bool<br/>      require_vpc_endpoints   = bool<br/>      block_public_ingress    = bool<br/>      require_imdsv2          = bool<br/>    })<br/>    compliance = object({<br/>      enable_point_in_time_recovery = bool<br/>      require_reserved_concurrency  = bool<br/>      enable_deletion_protection    = bool<br/>    })<br/>  })</pre> | `null` | no |
| <a name="input_stage_description"></a> [stage\_description](#input\_stage\_description) | Description of the API Gateway stage | `string` | `""` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Name of the API Gateway stage | `string` | `"prod"` | no |
| <a name="input_stage_variables"></a> [stage\_variables](#input\_stage\_variables) | Map of stage variables | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags to apply to resources | `map(string)` | `{}` | no |
| <a name="input_throttling_burst_limit"></a> [throttling\_burst\_limit](#input\_throttling\_burst\_limit) | API Gateway throttling burst limit | `number` | `5000` | no |
| <a name="input_throttling_rate_limit"></a> [throttling\_rate\_limit](#input\_throttling\_rate\_limit) | API Gateway throttling rate limit (requests per second) | `number` | `10000` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | Full API endpoint URL (invoke URL) |
| <a name="output_cloudwatch_role_arn"></a> [cloudwatch\_role\_arn](#output\_cloudwatch\_role\_arn) | ARN of the CloudWatch Logs IAM role |
| <a name="output_deployment_id"></a> [deployment\_id](#output\_deployment\_id) | ID of the API Gateway deployment |
| <a name="output_log_group_arn"></a> [log\_group\_arn](#output\_log\_group\_arn) | ARN of the CloudWatch Log Group |
| <a name="output_log_group_name"></a> [log\_group\_name](#output\_log\_group\_name) | Name of the CloudWatch Log Group |
| <a name="output_mock_endpoints"></a> [mock\_endpoints](#output\_mock\_endpoints) | List of mock endpoint URLs |
| <a name="output_mock_resource_ids"></a> [mock\_resource\_ids](#output\_mock\_resource\_ids) | Map of mock integration resource IDs |
| <a name="output_rest_api_arn"></a> [rest\_api\_arn](#output\_rest\_api\_arn) | ARN of the REST API |
| <a name="output_rest_api_execution_arn"></a> [rest\_api\_execution\_arn](#output\_rest\_api\_execution\_arn) | Execution ARN of the REST API |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | ID of the REST API |
| <a name="output_rest_api_name"></a> [rest\_api\_name](#output\_rest\_api\_name) | Name of the REST API |
| <a name="output_rest_api_root_resource_id"></a> [rest\_api\_root\_resource\_id](#output\_rest\_api\_root\_resource\_id) | Root resource ID of the REST API |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | ARN of the API Gateway stage |
| <a name="output_stage_id"></a> [stage\_id](#output\_stage\_id) | ID of the API Gateway stage |
| <a name="output_stage_invoke_url"></a> [stage\_invoke\_url](#output\_stage\_invoke\_url) | Invoke URL for the API Gateway stage |
| <a name="output_stage_name"></a> [stage\_name](#output\_stage\_name) | Name of the API Gateway stage |
| <a name="output_tags"></a> [tags](#output\_tags) | Tags applied to the API Gateway |

## Example

See [example/](example/) for a complete working example with all features.

## License

MIT Licensed. See [LICENSE](LICENSE) for full details.
<!-- END_TF_DOCS -->
