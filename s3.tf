module "s3_bucket" {
  source = "terraform-aws-modules/s3-bucket/aws"

  bucket = "ecomm-master-jajaja"
  acl    = "private"

  ignore_public_acls      = true
  restrict_public_buckets = true
  block_public_acls       = true
  block_public_policy     = true

  #   control_object_ownership = true
  #   object_ownership         = "ObjectWriter"

  #   versioning = {
  #     enabled = false
  #   }
}


resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = module.s3_bucket.s3_bucket_id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "PublicReadGetObject",
        Effect    = "Allow",
        Principal = "*",
        Action    = "s3:GetObject",
        Resource = [
          "${module.s3_bucket.s3_bucket_arn}",
          "${module.s3_bucket.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}
