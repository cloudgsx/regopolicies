variable "create_instance_profile" {
  type    = bool
  default = true
}

resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  count = var.create_instance_profile ? 1 : 0
  name  = "ec2_ssm_profile"
  role  = aws_iam_role.ec2_ssm_role.name
}

data "aws_iam_instance_profile" "existing" {
  count = var.create_instance_profile ? 0 : 1
  name  = "ec2_ssm_profile"
}

output "iam_instance_profile_name" {
  value = var.create_instance_profile ?
    aws_iam_instance_profile.ec2_ssm_profile[0].name :
    data.aws_iam_instance_profile.existing[0].name
}
