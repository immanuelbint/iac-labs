variable "libvirt_pool_name" {
    description = "KVM storage pool"
    default     = "pool-1"
}

variable "base_image_path" {
    description = "images path to be used by virtual machine"
    type        = string
    default     = "/pool/1/images/Rocky-8-GenericCloud-Base.latest.x86_64.qcow2"
}

variable "vm_domain" {
    description = "domain for virtual machine"
    default     = "example.com"
}

variable "vm_hostname" {
    description = "vm hostname"
    default     = "homelab"
}

variable "vm_cpu" {
    description = "number of CPU cores for the virtual machine"
    type        = number
    default     = 2
}

variable "vm_memory" {
    description = "memory size for the virtual machine in MB"
    type        = number
    default     = 4096
}

variable "ip_address" {
    type        = string
    description = "IP Addresses to be used by virtual machine (with CIDR)"
    default     = "172.23.0.89/26"
}

variable "data_volume" {
    description = "size of additional data volume"
    type        = number
    default     = 8 # will create 8 GB data vol
}
