variable "pm_api_url" {}
variable "pm_auth_user" {}
variable "pm_auth_password" {}
variable "pm_log_enable" {}
variable "pm_log_file" {}
variable "pm_debug" {}
variable "ssh_key" {
  type = list(string)
}

variable "qemu_config" {
  type = list(object({
    name     = string
    vmid     = number
    memory   = number
    sockets  = number
    root_disk= number
    onboot   = bool
    cores    = number
    ip0      = string
    node     = string
    template = string
    agent    = number
  }))
}