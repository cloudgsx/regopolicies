# ---- Inputs ----
variable "instance_profile_name" {
  type        = string
  default     = null         # if set, we use that existing profile
  description = "Existing IAM instance profile name to use. If null, create one."
}

variable "instance_profile_role_name" {
  type        = string
  default     = null         # required only when creating the profile
  description = "Name of an existing IAM role to attach to the profile when creating it."
  validation {
    condition     = var.instance_profile_name != null || var.instance_profile_role_name != null
    error_message = "If instance_profile_name is null (i.e., we will create a profile), you must provide instance_profile_role_name."
  }
}

variable "new_instance_profile_name" {
  type        = string
  default     = "ec2_instance_profile"
  description = "Name to give the profile if we create it."
}

# ---- Use existing, if provided ----
data "aws_iam_instance_profile" "existing" {
  count = var.instance_profile_name != null ? 1 : 0
  name  = var.instance_profile_name
}

# ---- Otherwise create the profile (attach to the existing role you provided) ----
resource "aws_iam_instance_profile" "this" {
  count = var.instance_profile_name == null ? 1 : 0
  name  = var.new_instance_profile_name
  role  = var.instance_profile_role_name
}

# ---- Single value to consume elsewhere ----
locals {
  iam_instance_profile_name = var.instance_profile_name != null
    ? data.aws_iam_instance_profile.existing[0].name
    : aws_iam_instance_profile.this[0].name
}

# Example:
# iam_instance_profile = local.iam_instance_profile_name

output "iam_instance_profile_name" {
  value = local.iam_instance_profile_name
}
