terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27.0"
    }
  }
  backend "s3" {
  }
}

provider "aws" {
  region = var.region
}

data "aws_caller_identity" "self" {}

locals {
  region     = var.region
  domain     = var.domain
  prefix     = "${var.project}-${var.environment}-${var.feature}"
  account_id = data.aws_caller_identity.self.account_id
}

resource "aws_s3_bucket" "static" {
  bucket = "${local.domain}-${local.prefix}"
}

resource "aws_s3_bucket_acl" "static" {
  bucket = aws_s3_bucket.static.id
  acl    = "private"
}

resource "aws_s3_bucket_website_configuration" "static" {
  bucket = aws_s3_bucket.static.bucket

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_cloudfront_origin_access_identity" "static" {
  comment = "static"
}

data "aws_iam_policy_document" "static" {
  statement {
    sid    = "Allow CloudFront"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.static.iam_arn]
    }
    actions = [
      "s3:GetObject"
    ]
    resources = [
      "${aws_s3_bucket.static.arn}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "static" {
  bucket = aws_s3_bucket.static.id
  policy = data.aws_iam_policy_document.static.json
}

resource "aws_cloudfront_distribution" "static" {
  origin {
    domain_name = aws_s3_bucket.static.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.static.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.static.cloudfront_access_identity_path
    }
  }
  enabled             = true
  default_root_object = "index.html"
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket.static.id
    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["JP"]
    }
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
}

module "distribution_files" {
  source   = "hashicorp/dir/template"
  base_dir = "../../../../sveltekit/build"
}

resource "aws_s3_object" "static" {
  for_each = module.distribution_files.files
  bucket       = aws_s3_bucket.static.bucket
  key          = each.key
  source       = each.value.source_path
  content_type = each.value.content_type
}
