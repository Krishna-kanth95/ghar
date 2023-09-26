terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.15.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# #KMS for s3 encryption
# resource "aws_kms_key" "s3_kms" {
#   description             = "This key is used to encrypt bucket objects"
#   deletion_window_in_days = 10
# }

# #create s3 bucket
# resource "aws_s3_bucket" "terraform-remote-state-bucket" {
#   bucket = "terraform-remote-state-12345"
# }

# #bucket versioning
# resource "aws_s3_bucket_versioning" "versioning_example" {
#   bucket = aws_s3_bucket.terraform-remote-state-bucket.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# #server side encryptioj for s3 bucket
# resource "aws_s3_bucket_server_side_encryption_configuration" "example" {
#   bucket = aws_s3_bucket.terraform-remote-state-bucket.id

#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = aws_kms_key.s3_kms.arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# #create DynamoDB table for state locking
# resource "aws_dynamodb_table" "terraform-state-locking-dynamodb-table" {
#   name           = "s3StateLock12345"
#   billing_mode   = "PROVISIONED"
#   read_capacity  = 20
#   write_capacity = 20
#   hash_key       = "UserId"
#   range_key      = "GameTitle"

#   attribute {
#     name = "UserId"
#     type = "S" # 'S' indicates String type
#   }

#   attribute {
#     name = "GameTitle"
#     type = "S" # 'S' indicates String type
#   }
#   deletion_protection_enabled = true
# }
