# WAF Web ACL for API Gateway Protection
# This creates a simple WAF with common security rules for demonstration purposes
# In production, customize rules based on your specific security requirements

# WAF Web ACL
resource "aws_wafv2_web_acl" "api_gateway" {
  name  = "${var.namespace}-${var.environment}-${var.name}-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  # AWS Managed Rule - Core Rule Set (CRS)
  # Protects against OWASP Top 10 vulnerabilities
  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "CommonRuleSetMetric"
      sampled_requests_enabled    = true
    }
  }

  # AWS Managed Rule - Known Bad Inputs
  # Blocks requests with known malicious inputs
  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "KnownBadInputsMetric"
      sampled_requests_enabled    = true
    }
  }

  # AWS Managed Rule - Amazon IP Reputation List
  # Blocks requests from known malicious IP addresses
  rule {
    name     = "AWSManagedRulesAmazonIpReputationList"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "IpReputationMetric"
      sampled_requests_enabled    = true
    }
  }

  # Rate Limiting Rule
  # Limits requests from a single IP to prevent abuse
  rule {
    name     = "RateLimitRule"
    priority = 4

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.waf_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                 = "RateLimitMetric"
      sampled_requests_enabled    = true
    }
  }

  tags = merge(
    var.tags,
    {
      Name        = "${var.namespace}-${var.environment}-${var.name}-waf"
      Purpose     = "API Gateway Protection"
      Environment = var.environment
    }
  )

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                 = "${var.namespace}-${var.environment}-${var.name}-waf"
    sampled_requests_enabled    = true
  }
}

# CloudWatch Log Group for WAF Logs
resource "aws_cloudwatch_log_group" "waf_logs" {
  name              = "/aws/wafv2/${var.namespace}-${var.environment}-${var.name}"
  retention_in_days = var.log_retention_days
  kms_key_id        = module.kms_key.key_arn

  tags = merge(
    var.tags,
    {
      Name        = "/aws/wafv2/${var.namespace}-${var.environment}-${var.name}"
      Purpose     = "WAF Logging"
      Environment = var.environment
    }
  )
}

# WAF Logging Configuration
resource "aws_wafv2_web_acl_logging_configuration" "api_gateway" {
  resource_arn            = aws_wafv2_web_acl.api_gateway.arn
  log_destination_configs = [aws_cloudwatch_log_group.waf_logs.arn]

  # Redact sensitive fields from logs
  redacted_fields {
    single_header {
      name = "authorization"
    }
  }

  redacted_fields {
    single_header {
      name = "x-api-key"
    }
  }
}