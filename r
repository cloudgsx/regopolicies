# Fetch the existing IAM role
data "aws_iam_role" "ec2_ssm_role" {
  name = "AWSServiceRoleForAmazonSSM"
}

# Create the instance profile and attach the existing role
resource "aws_iam_instance_profile" "ec2_ssm_profile" {
  name = "ec2_ssm_profile"
  role = data.aws_iam_role.ec2_ssm_role.name
}

# Example: attach it to an EC2 instance
resource "aws_instance" "example" {
  ami                  = "ami-xxxxxxxx"   # <-- replace with your AMI
  instance_type        = "t3.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm_profile.name

  tags = {
    Name = "with-instance-profile"
  }
}
