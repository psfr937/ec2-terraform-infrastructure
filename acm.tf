resource "aws_acm_certificate" "this" {
  domain_name       = "${local.domain_name}"
  validation_method = "DNS"

  tags = {
    Environment = "production"
  }

  lifecycle {
    create_before_destroy = true
  }
}
