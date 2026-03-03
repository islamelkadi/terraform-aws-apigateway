# API Gateway REST API Module Outputs

output "rest_api_id" {
  description = "ID of the REST API"
  value       = aws_api_gateway_rest_api.this.id
}

output "rest_api_arn" {
  description = "ARN of the REST API"
  value       = aws_api_gateway_rest_api.this.arn
}

output "rest_api_name" {
  description = "Name of the REST API"
  value       = aws_api_gateway_rest_api.this.name
}

output "rest_api_root_resource_id" {
  description = "Root resource ID of the REST API"
  value       = aws_api_gateway_rest_api.this.root_resource_id
}

output "rest_api_execution_arn" {
  description = "Execution ARN of the REST API"
  value       = aws_api_gateway_rest_api.this.execution_arn
}

output "deployment_id" {
  description = "ID of the API Gateway deployment"
  value       = aws_api_gateway_deployment.this.id
}

output "stage_id" {
  description = "ID of the API Gateway stage"
  value       = aws_api_gateway_stage.this.id
}

output "stage_arn" {
  description = "ARN of the API Gateway stage"
  value       = aws_api_gateway_stage.this.arn
}

output "stage_name" {
  description = "Name of the API Gateway stage"
  value       = aws_api_gateway_stage.this.stage_name
}

output "stage_invoke_url" {
  description = "Invoke URL for the API Gateway stage"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "api_endpoint" {
  description = "Full API endpoint URL (invoke URL)"
  value       = aws_api_gateway_stage.this.invoke_url
}

output "cloudwatch_role_arn" {
  description = "ARN of the CloudWatch Logs IAM role"
  value       = var.create_cloudwatch_role ? aws_iam_role.cloudwatch[0].arn : var.cloudwatch_role_arn
}

output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = var.create_log_group ? module.log_group[0].log_group_name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch Log Group"
  value       = var.create_log_group ? module.log_group[0].log_group_arn : null
}

output "tags" {
  description = "Tags applied to the API Gateway"
  value       = aws_api_gateway_rest_api.this.tags
}

output "mock_resource_ids" {
  description = "Map of mock integration resource IDs"
  value       = { for k, v in aws_api_gateway_resource.mock : k => v.id }
}

output "mock_endpoints" {
  description = "List of mock endpoint URLs"
  value = [
    for idx, integration in var.mock_integrations :
    "${aws_api_gateway_stage.this.invoke_url}${integration.path}"
  ]
}
