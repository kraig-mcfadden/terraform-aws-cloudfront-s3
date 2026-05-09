variable "name" {
  type        = string
  description = "What to call the CF distro and S3 bucket"
}

variable "aliases" {
  type        = set(string)
  description = "Aliases for the Cloudfront distro"
}

variable "hosted_zone_id" {
  type        = string
  description = "Id of the hosted zone to create the aliases in"
}

variable "acm_cert_arn" {
  type        = string
  description = "ACM cert for the CF aliases"
}

variable "mode" {
  type        = string
  description = "\"website\" hosts a static site (S3 website endpoint, public bucket policy, index.html resolution). \"object\" serves raw S3 objects via CloudFront with an OAC and a private bucket."

  validation {
    condition     = contains(["website", "object"], var.mode)
    error_message = "mode must be either \"website\" or \"object\"."
  }
}

variable "min_ttl" {
  type        = number
  default     = 0
  description = "CloudFront default cache behavior min TTL (seconds)"
}

variable "default_ttl" {
  type        = number
  default     = 3600
  description = "CloudFront default cache behavior default TTL (seconds)"
}

variable "max_ttl" {
  type        = number
  default     = 86400
  description = "CloudFront default cache behavior max TTL (seconds)"
}
