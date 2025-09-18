############################################
# 1) EC2 INSTANCE ROLE + INSTANCE PROFILE
############################################
resource "aws_iam_role" "ec2_ssm_role" {
  name = "ec2-ssm-role-helper-instance"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { Service = "ec2.amazonaws.com" },
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ec2_ssm_core" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2-ssm-instance-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

############################################
# 2) ADMIN/USER ROLE + MINIMAL SSM POLICY
############################################
resource "aws_iam_role" "admin_role" {
  name = "ssm-session-admin"

  # Choose the trust that matches how you log in:
  # - For IAM users: Principal { AWS = "arn:aws:iam::<acct-id>:root" } with sts:AssumeRole guardrails
  # - For AWS SSO/IAM Identity Center: use the SSO principal ARN
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Principal = { AWS = "arn:aws:iam::<ACCOUNT_ID>:root" },  # <-- replace
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ssm_session_minimal" {
  name        = "SSMStartSessionMinimal"
  description = "Minimal permissions to start SSM sessions to tagged EC2 instances"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid    = "StartResumeTerminateOnTaggedInstances",
        Effect = "Allow",
        Action = ["ssm:StartSession","ssm:ResumeSession","ssm:TerminateSession"],
        Resource = "arn:aws:ec2:*:*:instance/*",
        Condition = { StringEquals = { "ssm:resourceTag/SSMSession" = "allowed" } }
      },
      {
        Sid    = "DescribeForConsole",
        Effect = "Allow",
        Action = [
          "ssm:DescribeInstanceInformation",
          "ssm:DescribeSessions",
          "ssm:GetConnectionStatus",
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_ssm_minimal_to_admin" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.ssm_session_minimal.arn
}
