# ============================================================
# main.tf — Configuración del proveedor Terraform
# Caso Práctico 2 — UNIR DevOps Azure
# ============================================================

# Versión mínima de Terraform y proveedor AzureRM requeridos
terraform {
  required_version = ">= 1.3.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }
}

# Autenticación mediante Azure CLI (az login)
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Grupo de recursos que contiene toda la infraestructura del proyecto
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.common_tags
}
