variable "entorno" {
  description = "Nombre del entorno que se aprovisiona"
  type        = string
  default     = "produccion"
}

variable "sistema_operativo" {
  description = "Sistema operativo del servidor simulado"
  type        = string
  default     = "Ubuntu 24.04 LTS"
}

variable "ip_servidor" {
  description = "IP privada del servidor simulado"
  type        = string
  default     = "10.0.1.25"

  validation {
    condition     = can(regex("^\\d{1,3}(\\.\\d{1,3}){3}$", var.ip_servidor))
    error_message = "ip_servidor debe ser una IPv4 válida, por ejemplo 10.0.1.25."
  }
}
