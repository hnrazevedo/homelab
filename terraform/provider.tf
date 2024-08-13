terraform {
    required_providers {
        proxmox = {
            source  = "telmate/proxmox"
            version = "3.0.1-rc3"
        }
    }
}

provider "proxmox" {
    pm_api_url    = var.pm_api_url
    pm_user       = var.pm_auth_user
    pm_password   = var.pm_auth_password

    pm_log_enable = var.pm_log_enable
    pm_log_file   = var.pm_log_file
    pm_debug      = var.pm_debug
    pm_log_levels = {
        _default    = "debug"
        _capturelog = ""
    }
}