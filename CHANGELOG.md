## [2.0.0](https://github.com/islamelkadi/terraform-aws-apigateway/compare/v1.0.2...v2.0.0) (2026-03-10)


### ⚠ BREAKING CHANGES

* waf_acl_arn is now a required variable

* chore: address formatting issues

### Features

* Add mandatory WAF Web ACL integration for enhanced security ([#3](https://github.com/islamelkadi/terraform-aws-apigateway/issues/3)) ([6d7215d](https://github.com/islamelkadi/terraform-aws-apigateway/commit/6d7215d1eeb7ad7adb7caf52fb1360288a679cd2))


### Bug Fixes

* correct .checkov.yaml format to use simple list instead of id/comment dict ([b306bb0](https://github.com/islamelkadi/terraform-aws-apigateway/commit/b306bb068549919a8dda01f76b45ba3ef58a0a46))
* remove skip-path from .checkov.yaml, rely on workflow-level skip_path ([6122883](https://github.com/islamelkadi/terraform-aws-apigateway/commit/61228836d01be2421fe39ae72733eacc3a1132db))
* update workflow path reference to terraform-security.yaml ([c566c28](https://github.com/islamelkadi/terraform-aws-apigateway/commit/c566c28156195abbb11cd432a20cdfd7ad1ded52))


### Documentation

* add GitHub Actions workflow status badges ([326cb70](https://github.com/islamelkadi/terraform-aws-apigateway/commit/326cb70943598f1d9f633fd6bf36423eb67de8a2))
* add security scan suppressions section to README ([3cc8d05](https://github.com/islamelkadi/terraform-aws-apigateway/commit/3cc8d05d398c17541a4fa7f24043f6ed1c11bd43))

## [1.0.2](https://github.com/islamelkadi/terraform-aws-apigateway/compare/v1.0.1...v1.0.2) (2026-03-08)


### Bug Fixes

* address Checkov security findings ([152b756](https://github.com/islamelkadi/terraform-aws-apigateway/commit/152b7566e70cfff6ce3439371c5735ffa9d14b9b))

## [1.0.1](https://github.com/islamelkadi/terraform-aws-apigateway/compare/v1.0.0...v1.0.1) (2026-03-08)


### Code Refactoring

* enhance examples with real infrastructure and improve code quality ([d577df0](https://github.com/islamelkadi/terraform-aws-apigateway/commit/d577df0e35e23b77c6413da6ed0c561963ce6625))

## 1.0.0 (2026-03-07)


### ⚠ BREAKING CHANGES

* First publish - API Gateway Terraform module

### Features

* First publish - API Gateway Terraform module ([6c39d76](https://github.com/islamelkadi/terraform-aws-apigateway/commit/6c39d768c89e14fb258bceecdc60f45e8b5740b2))
