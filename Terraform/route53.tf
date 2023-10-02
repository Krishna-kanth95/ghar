resource "aws_route53_zone" "zone" {
  for_each = module.s3_bucket
  name     = "${each.value.s3_bucket_id}.com"
}

resource "aws_route53_record" "cdn_a_record" {
  for_each = module.s3_bucket

  zone_id = aws_route53_zone.zone[each.key].zone_id
  name    = "${each.value.s3_bucket_id}.com"
  type    = "A"

  alias {
    name                   = module.cdn[each.key].domain_name    # Assuming your CloudFront Terraform module outputs the distribution domain name.
    zone_id                = module.cdn[each.key].hosted_zone_id # Assuming your CloudFront Terraform module outputs the CloudFront distribution zone ID.
    evaluate_target_health = false
  }
}
