output "certificate_arn" {
  value = try(module.acm[0].acm_certificate_arn, null)
}

output "validation_record_fqdns" {
  value = try(module.acm[0].validation_route53_record_fqdns, null)
}
