main.tf

provider "azurerm" {
  features {}
}

resource "azurerm_monitor_action_group" "this" {
  name                = var.action_group_name
  resource_group_name = var.resource_group_name
  short_name          = var.action_group_short_name

  email_receiver {
    name          = var.email_receiver_name
    email_address = var.email_receiver_email
  }

  sms_receiver {
    name         = var.sms_receiver_name
    country_code = var.sms_receiver_country_code
    phone_number = var.sms_receiver_phone
  }
}

resource "azurerm_monitor_activity_log_alert" "this" {
  name                = var.alert_name
  resource_group_name = var.resource_group_name
  scopes              = var.scopes

  criteria {
    category = var.alert_category
    operation_name {
      operator  = "Equals"
      values    = var.operation_names
    }
  }

  action {
    action_group_id = azurerm_monitor_action_group.this.id
  }
}


vars.tf

variable "resource_group_name" {
  description = "The name of the resource group."
  type        = string
}

variable "action_group_name" {
  description = "The name of the action group."
  type        = string
}

variable "action_group_short_name" {
  description = "Short name of the action group (max 12 characters)."
  type        = string
}

variable "email_receiver_name" {
  description = "Name of the email receiver."
  type        = string
}

variable "email_receiver_email" {
  description = "Email address of the receiver."
  type        = string
}

variable "sms_receiver_name" {
  description = "Name of the SMS receiver."
  type        = string
}

variable "sms_receiver_country_code" {
  description = "Country code for the SMS receiver."
  type        = string
}

variable "sms_receiver_phone" {
  description = "Phone number for the SMS receiver."
  type        = string
}

variable "alert_name" {
  description = "The name of the activity log alert."
  type        = string
}

variable "scopes" {
  description = "The scope(s) of the alert (usually the subscription ID)."
  type        = list(string)
}

variable "alert_category" {
  description = "The category of the alert (e.g., 'Administrative', 'ServiceHealth', etc.)."
  type        = string
}

variable "operation_names" {
  description = "The operation names to monitor in the activity log."
  type        = list(string)
}


outputs.tf

output "action_group_id" {
  description = "The ID of the action group."
  value       = azurerm_monitor_action_group.this.id
}

output "alert_id" {
  description = "The ID of the activity log alert."
  value       = azurerm_monitor_activity_log_alert.this.id
}



example.tf

module "activity_log_alerts" {
  source                   = "./terraform-azure-activity-log-alerts"
  resource_group_name      = "my-resource-group"
  action_group_name        = "my-action-group"
  action_group_short_name  = "myalerts"
  email_receiver_name      = "AdminEmail"
  email_receiver_email     = "admin@example.com"
  sms_receiver_name        = "AdminSMS"
  sms_receiver_country_code = "+1"
  sms_receiver_phone       = "1234567890"
  alert_name               = "ActivityLogAlert"
  scopes                   = ["<subscription_id>"]
  alert_category           = "Administrative"
  operation_names          = ["Microsoft.Resources/deployments/write"]
}
