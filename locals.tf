# Local values for API Gateway module

locals {
  # Generate API name using metadata pattern
  api_name = join(var.delimiter, compact([
    var.namespace,
    var.environment,
    var.name,
    join(var.delimiter, var.attributes)
  ]))

  # Determine the resource ID for CORS (use provided resource_id or root)
  cors_resource_id = var.enable_cors && var.lambda_integration != null ? (
    var.lambda_integration.resource_id != null ? var.lambda_integration.resource_id : "root"
  ) : null

  # Security controls with defaults
  security_controls = var.security_controls != null ? var.security_controls : {
    encryption = {
      require_kms_customer_managed  = true
      require_encryption_at_rest    = true
      require_encryption_in_transit = true
      enable_kms_key_rotation       = true
    }
    logging = {
      require_cloudwatch_logs = true
      min_log_retention_days  = 365
      require_access_logging  = true
      require_flow_logs       = false
    }
    monitoring = {
      enable_xray_tracing         = true
      enable_enhanced_monitoring  = false
      enable_performance_insights = false
      require_cloudtrail          = true
    }
    network = {
      require_private_subnets = false
      require_vpc_endpoints   = false
      block_public_ingress    = false
      require_imdsv2          = false
    }
    compliance = {
      enable_point_in_time_recovery = false
      require_reserved_concurrency  = false
      enable_deletion_protection    = false
    }
  }

  # Merge tags with metadata
  tags = merge(
    var.tags,
    module.metadata.security_tags,
    {
      Name   = local.api_name
      Module = "terraform-aws-apigateway"
    }
  )
}
