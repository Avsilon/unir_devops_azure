#!/usr/bin/env bash
# ============================================================
# deploy.sh — Script de orquestación del despliegue
# Caso Práctico 2 — UNIR DevOps Azure
#
# Pasos:
#   1. Instala colecciones Ansible y dependencias Python
#   2. Lee las salidas de Terraform (IP VM, credenciales ACR)
#   3. Actualiza el inventario Ansible con la IP real de la VM
#   4. Exporta las credenciales del ACR como variables de entorno
#   5. Obtiene el kubeconfig de AKS
#   6. Ejecuta el playbook Ansible
#
# Uso:
#   chmod +x deploy.sh && ./deploy.sh
#
# Requisitos previos:
#   - terraform apply ejecutado en ../terraform/
#   - az login realizado en el nodo de control
#   - Clave SSH disponible en ~/.ssh/casopractico2
# ============================================================

set -euo pipefail

# ---- Helpers de color ----
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info()    { echo -e "${GREEN}[INFO]${NC} $*"; }
warn()    { echo -e "${YELLOW}[WARN]${NC} $*"; }
error()   { echo -e "${RED}[ERROR]${NC} $*" >&2; exit 1; }

# ---- Rutas ----
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="${SCRIPT_DIR}/../terraform"
HOSTS_FILE="${SCRIPT_DIR}/hosts"
PLAYBOOK_FILE="${SCRIPT_DIR}/playbook.yml"

# ---- Paso 1: Colecciones Ansible y SDK de Python ----
info "Instalando colecciones Ansible requeridas..."
ansible-galaxy collection install \
    containers.podman \
    kubernetes.core \
    community.general \
    ansible.posix \
    --force-with-deps

info "Instalando SDK de Kubernetes para Python..."
pip install --quiet kubernetes

# ---- Paso 2: Leer salidas de Terraform ----
info "Leyendo salidas de Terraform..."
cd "${TERRAFORM_DIR}"

VM_PUBLIC_IP=$(terraform output -raw vm_public_ip 2>/dev/null) \
    || error "No se pudo leer vm_public_ip. ¿Has ejecutado 'terraform apply'?"

ACR_LOGIN_SERVER=$(terraform output -raw acr_login_server 2>/dev/null) \
    || error "No se pudo leer acr_login_server."

ACR_USERNAME=$(terraform output -raw acr_admin_username 2>/dev/null) \
    || error "No se pudo leer acr_admin_username."

ACR_PASSWORD=$(terraform output -raw acr_admin_password 2>/dev/null) \
    || error "No se pudo leer acr_admin_password."

# Derivar nombre del ACR y grupo de recursos desde las salidas de Terraform
ACR_NAME="${ACR_LOGIN_SERVER%%.*}"
RG_NAME=$(terraform show -json 2>/dev/null \
    | python3 -c "import sys,json; s=json.load(sys.stdin); \
      rg=[v['values']['name'] for r in s.get('values',{}).get('root_module',{}).get('resources',[]) \
          if r['type']=='azurerm_resource_group' for v in [r]]; print(rg[0])" \
    2>/dev/null || echo "rg-casopractico2")

cd "${SCRIPT_DIR}"

info "IP pública VM    : ${VM_PUBLIC_IP}"
info "ACR Login Server : ${ACR_LOGIN_SERVER}"
info "Grupo de recursos: ${RG_NAME}"

# ---- Paso 3: Actualizar inventario con la IP real de la VM ----
info "Actualizando inventario Ansible con IP: ${VM_PUBLIC_IP}..."
sed -i "s/ansible_host=.*/ansible_host=${VM_PUBLIC_IP}/" "${HOSTS_FILE}"
sed -i "s/VM_PUBLIC_IP/${VM_PUBLIC_IP}/g" "${HOSTS_FILE}"

# ---- Paso 4: Exportar credenciales del ACR ----
export ACR_PASSWORD

# ---- Paso 5: Obtener kubeconfig de AKS ----
info "Obteniendo kubeconfig de AKS..."
az aks get-credentials \
    --resource-group "${RG_NAME}" \
    --name "aks-casopractico2" \
    --overwrite-existing \
    2>/dev/null || warn "No se pudo obtener el kubeconfig automáticamente. Configura KUBECONFIG manualmente."

# ---- Paso 6: Verificar conectividad SSH ----
info "Verificando conectividad SSH con la VM..."
ansible -m ping -i "${HOSTS_FILE}" vm_azure \
    || error "No se puede conectar a la VM por SSH. Comprueba que está en ejecución y la clave SSH es correcta."

# ---- Paso 7: Ejecutar el playbook Ansible ----
info "Ejecutando playbook Ansible..."
ansible-playbook \
    -i "${HOSTS_FILE}" \
    "${PLAYBOOK_FILE}" \
    -e "acr_name=${ACR_NAME}" \
    -e "acr_password=${ACR_PASSWORD}" \
    -v

info "============================================================"
info "Despliegue completado."
info "  Servidor web Podman : https://${VM_PUBLIC_IP}/ (usuario: admin / contraseña: admin123)"
info "  Jenkins en AKS      : Consulta la salida del playbook para la IP del LoadBalancer"
info "============================================================"
