# attach the managed policy to the existing role
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = data.aws_iam_role.ec2_ssm_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name
