module "cdn" {
  for_each = module.s3_bucket
  source   = "terraform-aws-modules/cloudfront/aws"

  aliases = [
    "${each.value.s3_bucket_id}.com",
    "*.${each.value.s3_bucket_id}.com",
    "www.sub.${each.value.s3_bucket_id}.com"
  ]

  # comment             = "My awesome CloudFront"
  enabled = true
  # is_ipv6_enabled     = true
  price_class         = "PriceClass_200"
  retain_on_delete    = false
  wait_for_deployment = false

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
  }

  # logging_config = {
  #   bucket = "logs-my-cdn.s3.amazonaws.com"
  # }

  origin = {
    s3_origin = {
      domain_name = each.value.s3_bucket_regional_domain_name
      s3_origin_config = {
        origin_access_identity = "s3_bucket_one"
      }

      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "s3_origin"
    viewer_protocol_policy = "redirect-to-https"

    allowed_methods = ["GET", "HEAD"]
    cached_methods  = ["GET", "HEAD"]
    compress        = true
    query_string    = true
  }

  # ordered_cache_behavior = [
  #   {
  #     path_pattern           = "index.html"
  #     target_origin_id       = "s3_origin"
  #     viewer_protocol_policy = "redirect-to-https"

  #     allowed_methods = ["GET", "HEAD"]
  #     cached_methods  = ["GET", "HEAD"]
  #     compress        = true
  #     query_string    = true
  #   }
  # ]

  viewer_certificate = {
    acm_certificate_arn = module.acm[each.key].arn
    ssl_support_method  = "sni-only"
  }

  depends_on = [module.acm]
}
