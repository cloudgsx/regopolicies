variable "vm_size" {
  type = string

  validation {
    condition     = module.compute_skus.is_valid
    error_message = "The VM size '${var.vm_size}' is not valid for the location '${var.location}'. Please choose a valid size."
  }
}
