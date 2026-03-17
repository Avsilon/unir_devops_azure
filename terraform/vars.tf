# ============================================================
# vars.tf — Variables de la infraestructura Azure
# Caso Práctico 2 — UNIR DevOps Azure
# ============================================================

variable "location" {
  description = "Región de Azure donde se despliegan los recursos"
  type        = string
  default     = "spaincentral"
}

variable "resource_group_name" {
  description = "Nombre del grupo de recursos"
  type        = string
  default     = "rg-casopractico2"
}

# ---- Azure Container Registry ----

variable "acr_name" {
  description = "Nombre único global del registro de contenedores (solo alfanumérico)"
  type        = string
  default     = "acrcasopractico2700768"
}

variable "acr_sku" {
  description = "Nivel de servicio del ACR (Basic | Standard | Premium)"
  type        = string
  default     = "Basic"
}

# ---- Máquina Virtual ----

variable "vm_name" {
  description = "Nombre de la máquina virtual Linux"
  type        = string
  default     = "vm-casopractico2"
}

variable "vm_size" {
  description = "Tamaño de la VM en Azure"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "vm_admin_username" {
  description = "Usuario administrador de la VM"
  type        = string
  default     = "azureuser"
}

# Azure solo admite claves RSA para VMs Linux
# Genera la clave con: ssh-keygen -t rsa -b 4096 -f ~/.ssh/casopractico2
variable "ssh_public_key_path" {
  description = "Ruta a la clave pública RSA para autenticación en la VM"
  type        = string
  default     = "~/.ssh/casopractico2.pub"
}

# ---- Red virtual ----

variable "vnet_address_space" {
  description = "Espacio de direcciones de la red virtual"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_prefix" {
  description = "Prefijo de dirección de la subred"
  type        = string
  default     = "10.0.1.0/24"
}

# ---- Clúster AKS ----

variable "aks_name" {
  description = "Nombre del clúster AKS"
  type        = string
  default     = "aks-casopractico2"
}

variable "kubernetes_version" {
  description = "Versión de Kubernetes (null para usar la última estable)"
  type        = string
  default     = null
}

variable "aks_node_size" {
  description = "Tamaño de VM para los nodos del clúster AKS"
  type        = string
  default     = "Standard_B2s_v2"
}

variable "aks_node_count" {
  description = "Número de nodos en el pool por defecto de AKS"
  type        = number
  default     = 1
}

# ---- Etiquetas comunes ----

variable "common_tags" {
  description = "Etiquetas comunes aplicadas a todos los recursos"
  type        = map(string)
  default = {
    project     = "casopractico2"
    environment = "student"
    managed_by  = "terraform"
  }
}
