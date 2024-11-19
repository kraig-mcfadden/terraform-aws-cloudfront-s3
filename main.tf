/* ------- S3 ------- */

resource "aws_s3_bucket" "artifact_bucket" {
  bucket = "${var.name}-artifacts"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "artifact_bucket_sse" {
  bucket = aws_s3_bucket.artifact_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }

    bucket_key_enabled = "true"
  }
}

resource "aws_s3_bucket_versioning" "artifact_bucket_versioning" {
  bucket = aws_s3_bucket.artifact_bucket.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "artifact_bucket_lifecycle" {
  bucket = aws_s3_bucket.artifact_bucket.bucket

  rule {
    id = "Delete old versions after a week"

    status = "Enabled"

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }

    expiration {
      days = 0
    }

    noncurrent_version_expiration {
      newer_noncurrent_versions = 1
      noncurrent_days           = 7
    }
  }
}

resource "aws_s3_bucket_public_access_block" "allow_public_access" {
  bucket = aws_s3_bucket.artifact_bucket.id
}

data "aws_iam_policy_document" "bucket_policy_doc" {
  statement {
    sid       = "PublicReadGetObject"
    effect    = "Allow"
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.artifact_bucket.arn}/*"]
    principals {
      type        = "*"
      identifiers = ["*"]
    }
  }
}

resource "aws_s3_bucket_policy" "artifact_bucket_policy" {
  bucket = aws_s3_bucket.artifact_bucket.bucket
  policy = data.aws_iam_policy_document.bucket_policy_doc.json

  depends_on = [aws_s3_bucket_public_access_block.allow_public_access]
}

resource "aws_s3_bucket_website_configuration" "artifact_bucket_website_config" {
  bucket = aws_s3_bucket.artifact_bucket.bucket

  index_document {
    suffix = "index.html"
  }
}

/* ------- Cloudfront ------- */

resource "aws_cloudfront_distribution" "distro" {
  origin {
    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1.2"]
    }

    domain_name = aws_s3_bucket_website_configuration.artifact_bucket_website_config.website_endpoint
    origin_id   = aws_s3_bucket_website_configuration.artifact_bucket_website_config.website_endpoint
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  aliases = var.aliases

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_s3_bucket_website_configuration.artifact_bucket_website_config.website_endpoint

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

  price_class = "PriceClass_100"

  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["US", "CA", "GB", "DE"]
    }
  }

  viewer_certificate {
    acm_certificate_arn      = var.acm_cert_arn
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }
}

/* ------- Route 53 ------- */

resource "aws_route53_record" "cloudfront_alias" {
  for_each = var.aliases

  name    = each.key
  type    = "A"
  zone_id = var.hosted_zone_id

  alias {
    name                   = aws_cloudfront_distribution.distro.domain_name
    zone_id                = aws_cloudfront_distribution.distro.hosted_zone_id
    evaluate_target_health = false
  }
}
