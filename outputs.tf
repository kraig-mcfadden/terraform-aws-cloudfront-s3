output "bucket_arn" {
  value       = aws_s3_bucket.artifact_bucket.arn
  description = "ARN of the artifact bucket"
}

output "bucket_id" {
  value       = aws_s3_bucket.artifact_bucket.id
  description = "Name of the artifact bucket — useful for attaching extra config (CORS, IAM policies for presigned uploads)"
}

output "distribution_id" {
  value       = aws_cloudfront_distribution.distro.id
  description = "CloudFront distribution ID"
}

output "distribution_domain_name" {
  value       = aws_cloudfront_distribution.distro.domain_name
  description = "CloudFront distribution domain name (e.g. d111111abcdef8.cloudfront.net)"
}
