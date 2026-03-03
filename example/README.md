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

No requirements.

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_api_gateway"></a> [api\_gateway](#module\_api\_gateway) | ../ | n/a |
| <a name="module_kms_key"></a> [kms\_key](#module\_kms\_key) | ../../terraform-aws-kms | n/a |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | `"us-east-1"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | `"dev"` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Namespace for resource naming | `string` | `"example"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_api_endpoint"></a> [api\_endpoint](#output\_api\_endpoint) | API Gateway endpoint URL |
| <a name="output_deployment_id"></a> [deployment\_id](#output\_deployment\_id) | API Gateway deployment ID |
| <a name="output_rest_api_arn"></a> [rest\_api\_arn](#output\_rest\_api\_arn) | API Gateway REST API ARN |
| <a name="output_rest_api_execution_arn"></a> [rest\_api\_execution\_arn](#output\_rest\_api\_execution\_arn) | API Gateway execution ARN |
| <a name="output_rest_api_id"></a> [rest\_api\_id](#output\_rest\_api\_id) | API Gateway REST API ID |
| <a name="output_rest_api_name"></a> [rest\_api\_name](#output\_rest\_api\_name) | API Gateway REST API name |
| <a name="output_stage_arn"></a> [stage\_arn](#output\_stage\_arn) | API Gateway stage ARN |
| <a name="output_stage_id"></a> [stage\_id](#output\_stage\_id) | API Gateway stage ID |
| <a name="output_stage_invoke_url"></a> [stage\_invoke\_url](#output\_stage\_invoke\_url) | Stage invoke URL |
<!-- END_TF_DOCS -->
