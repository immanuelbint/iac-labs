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

# --- Master node variable --- #

variable "master_hostname" {
    description = "vm master hostname"
    default     = "masternode"
}

variable "master_cpu" {
    description = "number of CPU cores for the master virtual machine"
    type        = number
    default     = 1
}

variable "master_memory" {
    description = "memory size for the master virtual machine in MB"
    type        = number
    default     = 2048
}

variable "master_ip_address" {
    type        = list(string)
    description = "IP Addresses to be used by master virtual machine (with CIDR)"
    default     = ["172.23.0.87/26"]
}

variable "master_count" {
    description = "Number of master VMs to create"
    default     = 1
}

# --- Worker node variable --- #

variable "worker_hostname" {
    description = "vm worker hostname"
    default     = "workernode"
}

variable "worker_cpu" {
    description = "number of CPU cores for the worker virtual machine"
    type        = number
    default     = 1
}

variable "worker_memory" {
    description = "memory size for the worker virtual machine in MB"
    type        = number
    default     = 4096
}

variable "worker_ip_address" {
    type        = list(string)
    description = "IP Addresses to be used by worker virtual machine (with CIDR)"
    default     = ["172.23.0.88/26", "172.23.0.89/26"]
}

variable "worker_count" {
    description = "Number of worker VMs to create"
    default     = 2
}

variable "worker_data_volume" {
    description = "Additional data volume config to be used by virtual machine"
    type        = list(object({
        name    = string
        pool    = string
        size    = number
        format  = string
    }))
    default     = [
        {
            name    = "data-vol"
            pool    = "pool-1"
            size    = 10
            format  = "qcow2"
        }
    ]
}