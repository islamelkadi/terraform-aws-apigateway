# API Gateway Example

This example demonstrates a complete API Gateway REST API configuration with all available features.

## Features

- REST API with Lambda integration
- CORS configuration with custom origin
- CloudWatch logging with custom retention
- X-Ray tracing enabled
- CloudWatch metrics enabled
- API caching with encryption
- Custom throttling limits
- KMS encryption
- Custom stage configuration

## Usage

```bash
terraform init
terraform plan
terraform apply
```

## Requirements

- Terraform >= 1.0
- AWS Provider >= 5.0
- Existing Lambda function
- KMS key (created in this example)

## Configuration

This example includes:

1. **Endpoint Configuration**
   - Regional endpoint type
   - Execute API endpoint enabled

2. **Lambda Integration**
   - Multiple HTTP methods (GET, POST, PUT, DELETE)
   - Custom timeout (29 seconds)
   - No authorization (can be customized)

3. **CORS**
   - Specific origin allowed
   - Multiple HTTP methods
   - Standard headers

4. **Logging & Monitoring**
   - Access logging to CloudWatch
   - 90-day log retention
   - INFO level logging
   - X-Ray tracing
   - CloudWatch metrics

5. **Performance**
   - API caching enabled (5 minutes TTL)
   - Encrypted cache
   - Custom throttling limits

6. **Security**
   - KMS encryption for cache
   - CloudWatch logs encryption

<!-- BEGIN_TF_DOCS -->
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
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | ../ | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | git::https://github.com/islamelkadi/terraform-aws-kms.git | v1.0.0 |

## Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.waf_logs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_wafv2_web_acl.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl) | resource |
| [aws_wafv2_web_acl_logging_configuration.api_gateway](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/wafv2_web_acl_logging_configuration) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_cache_data_encrypted"></a> [cache\_data\_encrypted](#input\_cache\_data\_encrypted) | Encrypt cache data | `bool` | `true` | no |
| <a name="input_cache_ttl_seconds"></a> [cache\_ttl\_seconds](#input\_cache\_ttl\_seconds) | Cache TTL in seconds | `number` | `300` | no |
| <a name="input_cors_allow_headers"></a> [cors\_allow\_headers](#input\_cors\_allow\_headers) | CORS allowed headers | `list(string)` | <pre>[<br/>  "Content-Type",<br/>  "X-Amz-Date",<br/>  "Authorization",<br/>  "X-Api-Key"<br/>]</pre> | no |
| <a name="input_cors_allow_methods"></a> [cors\_allow\_methods](#input\_cors\_allow\_methods) | CORS allowed methods | `list(string)` | <pre>[<br/>  "GET",<br/>  "POST",<br/>  "PUT",<br/>  "DELETE",<br/>  "OPTIONS"<br/>]</pre> | no |
| <a name="input_cors_allow_origin"></a> [cors\_allow\_origin](#input\_cors\_allow\_origin) | CORS allowed origin | `string` | `"*"` | no |
| <a name="input_description"></a> [description](#input\_description) | Description of the API Gateway | `string` | `""` | no |
| <a name="input_disable_execute_api_endpoint"></a> [disable\_execute\_api\_endpoint](#input\_disable\_execute\_api\_endpoint) | Whether to disable the default execute-api endpoint | `bool` | `false` | no |
| <a name="input_enable_access_logging"></a> [enable\_access\_logging](#input\_enable\_access\_logging) | Enable access logging | `bool` | `true` | no |
| <a name="input_enable_caching"></a> [enable\_caching](#input\_enable\_caching) | Enable API caching | `bool` | `false` | no |
| <a name="input_enable_cors"></a> [enable\_cors](#input\_enable\_cors) | Enable CORS configuration | `bool` | `false` | no |
| <a name="input_enable_data_trace"></a> [enable\_data\_trace](#input\_enable\_data\_trace) | Enable data trace logging | `bool` | `false` | no |
| <a name="input_enable_metrics"></a> [enable\_metrics](#input\_enable\_metrics) | Enable detailed CloudWatch metrics | `bool` | `true` | no |
| <a name="input_enable_xray_tracing"></a> [enable\_xray\_tracing](#input\_enable\_xray\_tracing) | Enable X-Ray tracing | `bool` | `true` | no |
| <a name="input_endpoint_types"></a> [endpoint\_types](#input\_endpoint\_types) | List of endpoint types (EDGE, REGIONAL, PRIVATE) | `list(string)` | <pre>[<br/>  "REGIONAL"<br/>]</pre> | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, staging, prod) | `string` | n/a | yes |
| <a name="input_lambda_integration"></a> [lambda\_integration](#input\_lambda\_integration) | Lambda integration configuration | <pre>object({<br/>    lambda_function_name = string<br/>    lambda_invoke_arn    = string<br/>    http_methods         = list(string)<br/>    authorization_type   = string<br/>    api_key_required     = bool<br/>    timeout_milliseconds = number<br/>    resource_id          = optional(string)<br/>  })</pre> | `null` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | CloudWatch Logs retention in days | `number` | `90` | no |
| <a name="input_logging_level"></a> [logging\_level](#input\_logging\_level) | Logging level (OFF, ERROR, INFO) | `string` | `"INFO"` | no |
| <a name="input_mock_integrations"></a> [mock\_integrations](#input\_mock\_integrations) | List of mock integrations | <pre>list(object({<br/>    path          = string<br/>    http_method   = string<br/>    status_code   = number<br/>    response_body = string<br/>  }))</pre> | `[]` | no |
| <a name="input_name"></a> [name](#input\_name) | Name of the API Gateway | `string` | n/a | yes |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace (organization/team name) | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | AWS region | `string` | n/a | yes |
| <a name="input_stage_description"></a> [stage\_description](#input\_stage\_description) | Stage description | `string` | `""` | no |
| <a name="input_stage_name"></a> [stage\_name](#input\_stage\_name) | Stage name | `string` | `"prod"` | no |
| <a name="input_stage_variables"></a> [stage\_variables](#input\_stage\_variables) | Stage variables | `map(string)` | `{}` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags | `map(string)` | `{}` | no |
| <a name="input_throttling_burst_limit"></a> [throttling\_burst\_limit](#input\_throttling\_burst\_limit) | Throttling burst limit | `number` | `5000` | no |
| <a name="input_throttling_rate_limit"></a> [throttling\_rate\_limit](#input\_throttling\_rate\_limit) | Throttling rate limit | `number` | `10000` | no |
| <a name="input_waf_rate_limit"></a> [waf\_rate\_limit](#input\_waf\_rate\_limit) | Rate limit for WAF (requests per 5-minute period from a single IP) | `number` | `2000` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API Gateway endpoint URL |
| <a name="output_deployment_id"></a> [deployment\_id](#output\_deployment\_id) | API Gateway deployment ID |
| <a name="output_mock_endpoints"></a> [mock\_endpoints](#output\_mock\_endpoints) | Mock endpoint URLs |
| <a name="output_rest_api_arn"></a> [rest\_api\_arn](#output\_rest\_api\_arn) | API Gateway REST API ARN |
| <a name="output_rest_api_execution_arn"></a> [rest\_api\_execution\_arn](#output\_rest\_api\_execution\_arn) | API Gateway execution ARN |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | API Gateway REST API ID |
| <a name="output_rest_api_name"></a> [rest\_api\_name](#output\_rest\_api\_name) | API Gateway REST API name |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | API Gateway stage ARN |
| <a name="output_stage_id"></a> [stage\_id](#output\_stage\_id) | API Gateway stage ID |
| <a name="output_stage_invoke_url"></a> [stage\_invoke\_url](#output\_stage\_invoke\_url) | Stage invoke URL |
| <a name="output_waf_web_acl_arn"></a> [waf\_web\_acl\_arn](#output\_waf\_web\_acl\_arn) | WAF Web ACL ARN |
| <a name="output_waf_web_acl_id"></a> [waf\_web\_acl\_id](#output\_waf\_web\_acl\_id) | WAF Web ACL ID |
| <a name="output_waf_web_acl_name"></a> [waf\_web\_acl\_name](#output\_waf\_web\_acl\_name) | WAF Web ACL name |
<!-- END_TF_DOCS -->
