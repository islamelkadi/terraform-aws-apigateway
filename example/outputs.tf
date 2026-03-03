# Outputs for API Gateway example

output "rest_api_id" {
  description = "API Gateway REST API ID"
  value       = module.api_gateway.rest_api_id
}

output "rest_api_arn" {
  description = "API Gateway REST API ARN"
  value       = module.api_gateway.rest_api_arn
}

output "rest_api_name" {
  description = "API Gateway REST API name"
  value       = module.api_gateway.rest_api_name
}

output "api_endpoint" {
  description = "API Gateway endpoint URL"
  value       = module.api_gateway.api_endpoint
}

output "stage_id" {
  description = "API Gateway stage ID"
  value       = module.api_gateway.stage_id
}

output "stage_arn" {
  description = "API Gateway stage ARN"
  value       = module.api_gateway.stage_arn
}

output "stage_invoke_url" {
  description = "Stage invoke URL"
  value       = module.api_gateway.stage_invoke_url
}

output "deployment_id" {
  description = "API Gateway deployment ID"
  value       = module.api_gateway.deployment_id
}

output "rest_api_execution_arn" {
  description = "API Gateway execution ARN"
  value       = module.api_gateway.rest_api_execution_arn
}

output "mock_endpoints" {
  description = "Mock endpoint URLs"
  value       = module.api_gateway.mock_endpoints
}
