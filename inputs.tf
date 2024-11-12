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
