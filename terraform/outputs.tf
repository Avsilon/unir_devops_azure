# ============================================================
# outputs.tf — Valores de salida de Terraform
# Caso Práctico 2 — UNIR DevOps Azure
# ============================================================

# ---- ACR ----

output "acr_login_server" {
  description = "URL del servidor de login del ACR"
  value       = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  description = "Usuario administrador del ACR"
  value       = azurerm_container_registry.acr.admin_username
}

output "acr_admin_password" {
  description = "Contraseña del ACR"
  value       = azurerm_container_registry.acr.admin_password
  sensitive   = true
}

# ---- VM ----

output "vm_public_ip" {
  description = "IP pública de la VM Linux"
  value       = azurerm_public_ip.vm_pip.ip_address
}

# ---- AKS ----

output "kube_config" {
  description = "kubeconfig del clúster AKS"
  value       = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive   = true
}

output "aks_host" {
  description = "URL del servidor API de AKS"
  value       = azurerm_kubernetes_cluster.aks.kube_config[0].host
  sensitive   = true
}
