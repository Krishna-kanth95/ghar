module "acm" {
  for_each = module.s3_bucket
  source   = "terraform-aws-modules/acm/aws"
  version  = "~> 4.0"

  providers = {
    aws = aws.useast1
  }

  domain_name = "${each.value.s3_bucket_id}.com"
  zone_id     = aws_route53_zone.zone[each.key].zone_id

  subject_alternative_names = [
    "*.${each.value.s3_bucket_id}.com",
    "www.sub.${each.value.s3_bucket_id}.com",
  ]
  validation_method       = "DNS"
  create_route53_records = true
  wait_for_validation    = true

  tags = {
    Name = "${each.value.s3_bucket_id}.com"
  }
}
