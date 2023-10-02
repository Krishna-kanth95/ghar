module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"
  for_each = {
    bucket1 = "bucket1name"
    bucket2 = "bucket2name"
  }

  bucket = each.value

  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  for_each = module.s3_bucket
  bucket   = each.value.s3_bucket_id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "CloudFrontAccess",
        Effect = "Allow",
        Principal = {
          AWS = aws_cloudfront_origin_access_identity.oai[each.key].iam_arn
        },
        Action = "s3:GetObject",
        Resource = [
          "${each.value.s3_bucket_arn}",
          "${each.value.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}
