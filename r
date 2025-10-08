resource "aws_iam_policy" "s3_bucket_access" {
  name        = "ec2-ssm-s3-bucket-access"
  description = "Allow EC2 SSM instance to access S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "AllowS3BucketAccess",
        Effect = "Allow",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ],
        Resource = [
          module.helper_instance_standard_bucket.bucket_arn,
          "${module.helper_instance_standard_bucket.bucket_arn}/*"
        ]
      },
      {
        Sid    = "AllowKMSAccess",
        Effect = "Allow",
        Action = [
          "kms:Decrypt",
          "kms:Encrypt",
          "kms:GenerateDataKey"
        ],
        Resource = module.helper_instance_kms.key_arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_bucket_access" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = aws_iam_policy.s3_bucket_access.arn
}
