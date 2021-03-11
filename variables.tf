variable domain_name {
  type        = string
  description = "Domain name"
}

variable organization {
  type        = string
  description = "Organization name"
}

variable cidr {
  type        = string
  description = "CIDR block for assigning client IPs from"
}

variable subnets {
  type        = set(string)
  description = "List of subnet IDs to associate with the endpoint"
}

variable destination_cidr {
  type        = string
  description = "Outbound route destination CIDR"
  default     = "0.0.0.0/0"
}

variable private_key_algorithm {
  type        = string
  description = "Private key algorithm"
  default     = "RSA"
}

variable root_certificate_early_renewal {
  type        = number
  description = "Renew root certificate # hours prior to expiration"
  default     = 0
}

variable root_certificate_validity {
  type        = number
  description = "Root certificate validity in hours"
  default     = 8760
}

variable server_certificate_validity {
  type        = number
  description = "Root certificate validity in hours"
  default     = 12
}

variable client_certificate_validity {
  type        = number
  description = "Root certificate validity in hours"
  default     = 12
}

variable log_retention {
  type        = number
  description = "Number of days to retain log events"
  default     = null
}

variable tags {
  type        = map(any)
  description = "Tags to be applied to all created AWS resources"
  default     = {}
}