bucket_policy_statements = {
  AllowCloudfrontWriteLogs = {
    actions    = ["s3:PutObject"]
    principals = {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    resources = [
      "arn:aws:s3:::${var.global_name}-general/*"
    ]
  }

  DenyHTTPRequests = {
    effect     = "Deny"
    actions    = ["s3:*"]
    principals = { type = "*", identifiers = ["*"] }
    condition  = {
      Bool = {
        "aws:SecureTransport" = "false"
      }
    }
    resources = [
      "arn:aws:s3:::${var.global_name}-general",
      "arn:aws:s3:::${var.global_name}-general/*"
    ]
  }
}
