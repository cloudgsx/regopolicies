validation {
  condition = alltrue([
    for ip in var.bank_internet_proxy_ip :
    can(cidrnetmask(ip)) &&
    can(regex("^((25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d)\\.){3}(25[0-5]|2[0-4]\\d|1\\d{2}|[1-9]?\\d)/(3[0-2]|[12]?\\d)$", ip))
  ])
  error_message = "Each value in bank_internet_proxy_ip must be a valid IPv4 CIDR (e.g., 192.168.0.0/24)."
}
