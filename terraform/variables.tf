variable "admin_cidr" {
  type        = string
  description = "CIDR block permitted to use SSH for administrative access to the demo instance."

  validation {
    condition     = can(cidrhost(var.admin_cidr, 0))
    error_message = "admin_cidr must be a valid IPv4 or IPv6 CIDR block."
  }
}
