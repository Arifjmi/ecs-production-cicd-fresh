output "certificate_arn" {
  value = aws_acm_certificate_validation.this.certificate_arn
}

output "certificate_status" {
  value = aws_acm_certificate.this.status
}

output "domain_name" {
  value = aws_acm_certificate.this.domain_name
}

output "validation_record_fqdns" {
  value = [
    for record in aws_route53_record.validation :
    record.fqdn
  ]
}
