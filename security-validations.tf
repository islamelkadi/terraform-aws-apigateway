# Security validations for API Gateway module
# Enforces security controls from metadata module with override capability

locals {
  # Access logging control
  access_logging_required = local.security_controls.logging.require_access_logging && !var.security_control_overrides.disable_access_logging
  access_logging_enabled  = var.enable_access_logging && (var.cloudwatch_log_group_arn != null || var.create_log_group)
  access_logging_passed   = !local.access_logging_required || local.access_logging_enabled

  # X-Ray tracing control
  xray_tracing_required = local.security_controls.monitoring.enable_xray_tracing && !var.security_control_overrides.disable_xray_tracing
  xray_tracing_enabled  = var.enable_xray_tracing
  xray_tracing_passed   = !local.xray_tracing_required || local.xray_tracing_enabled

  # CloudWatch Logs control
  cloudwatch_logs_required = local.security_controls.logging.require_cloudwatch_logs && !var.security_control_overrides.disable_cloudwatch_logs
  cloudwatch_logs_enabled  = var.create_log_group || var.cloudwatch_log_group_arn != null
  cloudwatch_logs_passed   = !local.cloudwatch_logs_required || local.cloudwatch_logs_enabled

  # Log retention control
  log_retention_required = local.security_controls.logging.min_log_retention_days > 0 && !var.security_control_overrides.disable_log_retention_validation
  log_retention_met      = var.log_retention_days >= local.security_controls.logging.min_log_retention_days
  log_retention_passed   = !local.log_retention_required || local.log_retention_met

  # KMS encryption control
  kms_required = local.security_controls.encryption.require_kms_customer_managed && !var.security_control_overrides.disable_kms_requirement
  kms_provided = var.kms_key_arn != null
  kms_passed   = !local.kms_required || local.kms_provided

  # Override audit trail
  has_overrides = (
    var.security_control_overrides.disable_access_logging ||
    var.security_control_overrides.disable_xray_tracing ||
    var.security_control_overrides.disable_kms_requirement ||
    var.security_control_overrides.disable_cloudwatch_logs ||
    var.security_control_overrides.disable_log_retention_validation
  )
  justification_provided = var.security_control_overrides.justification != ""
  override_audit_passed  = !local.has_overrides || local.justification_provided
}

# Security control validations
check "security_controls_compliance" {
  assert {
    condition     = local.access_logging_passed
    error_message = "Security control violation: Access logging is required but not enabled. Set enable_access_logging=true and provide cloudwatch_log_group_arn or set create_log_group=true. Set security_control_overrides.disable_access_logging=true with justification if this is intentional."
  }

  assert {
    condition     = local.xray_tracing_passed
    error_message = "Security control violation: X-Ray tracing is required but not enabled. Set enable_xray_tracing=true. Set security_control_overrides.disable_xray_tracing=true with justification if this is intentional."
  }

  assert {
    condition     = local.cloudwatch_logs_passed
    error_message = "Security control violation: CloudWatch Logs are required but not configured. Set create_log_group=true or provide cloudwatch_log_group_arn. Set security_control_overrides.disable_cloudwatch_logs=true with justification if this is intentional."
  }

  assert {
    condition     = local.log_retention_passed
    error_message = "Security control violation: Log retention must be at least ${local.security_controls.logging.min_log_retention_days} days but is set to ${var.log_retention_days} days. Increase log_retention_days or set security_control_overrides.disable_log_retention_validation=true with justification."
  }

  assert {
    condition     = local.kms_passed
    error_message = "Security control violation: KMS customer-managed key is required but not provided. Provide kms_key_arn. Set security_control_overrides.disable_kms_requirement=true with justification if this is intentional."
  }

  assert {
    condition     = local.override_audit_passed
    error_message = "Security control overrides detected but no justification provided. Set security_control_overrides.justification to document the business reason for disabling security controls."
  }
}
