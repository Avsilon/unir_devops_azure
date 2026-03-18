# Caso Práctico 2 — UNIR DevOps Azure

Automatización completa del despliegue de infraestructura y aplicaciones en **Microsoft Azure** usando **Terraform** para el aprovisionamiento y **Ansible** para la configuración y despliegue.

El proyecto despliega dos aplicaciones:
- Un **servidor web Nginx** con HTTPS y autenticación básica, ejecutado con **Podman** sobre una VM Linux.
- **Jenkins** corriendo en un clúster **AKS** (Kubernetes), con almacenamiento persistente en disco gestionado de Azure.

Ambas imágenes se construyen localmente y se publican en un **Azure Container Registry (ACR)** privado.

---

## Arquitectura

```
Nodo de control (local)
 ├── Terraform  →  Azure: Resource Group, ACR, VNet, NSG, VM Linux, AKS
 └── Ansible    →  Build & push imágenes al ACR
                →  Configura VM: instala Podman, despliega contenedor Nginx como servicio systemd
                →  Despliega Jenkins en AKS: Namespace, Secret, PVC, Deployment, LoadBalancer
```

## Estructura del repositorio

```
.
├── terraform/             # Infraestructura como código
│   ├── main.tf            # Proveedor AzureRM y Resource Group
│   ├── vars.tf            # Variables
│   ├── recursos.tf        # ACR, VM, red, AKS e integración RBAC
│   └── outputs.tf         # Salidas usadas por Ansible
├── ansible/
│   ├── playbook.yml       # 3 plays: build imágenes, configurar VM, desplegar AKS
│   ├── deploy.sh          # Script orquestador (lee outputs Terraform y lanza el playbook)
│   ├── hosts              # Inventario (FQDN de la VM)
│   └── docker/
│       ├── webapp-podman/ # Imagen Nginx + TLS autofirmado + htpasswd
│       └── webapp-k8s/    # Imagen Jenkins LTS
├── LICENSE
└── README.md
```

---

## Requisitos previos

| Herramienta | Versión usada |
|---|---|
| Terraform | 1.14.7 |
| Azure CLI | 2.63.0 |
| Ansible Core | 2.16.14 |
| Podman | 5.6.2 |
| Python | 3.13.9 |
| `containers.podman` | 1.19.0 |
| `kubernetes.core` | 6.3.0 |
| `community.general` | 12.4.0 |
| `ansible.posix` | 2.1.0 |

Además:
- Sesión activa en Azure: `az login`
- Clave SSH RSA generada en `~/.ssh/casopractico2` (Azure no admite ed25519)

---

## Despliegue

### 1. Infraestructura con Terraform

```bash
cd terraform
terraform init
terraform apply
```

Crea en Azure (región `spaincentral`): Resource Group, ACR, VNet, Subnet, NSG, IP pública, NIC, VM Linux (AlmaLinux 9) y clúster AKS con integración RBAC al ACR.

### 2. Aplicaciones con Ansible

```bash
cd ansible
chmod +x deploy.sh
./deploy.sh
```

El script lee automáticamente los outputs de Terraform, actualiza el inventario con la IP de la VM, obtiene el kubeconfig de AKS y ejecuta el playbook completo.

### 3. Destruir la infraestructura

```bash
cd terraform
terraform destroy
```

---

## Acceso a las aplicaciones

Las URLs son estables entre despliegues gracias a los DNS labels de Azure:

| Aplicación | URL | Credenciales |
|---|---|---|
| Nginx (VM + Podman) | `https://casopractico2vm700768.spaincentral.cloudapp.azure.com/` | admin / admin123 |
| Jenkins (AKS) | `http://casopractico2jenkins700768.spaincentral.cloudapp.azure.com/` | contraseña inicial en `/var/jenkins_home/secrets/initialAdminPassword` |

---

## Notas

- La región `spaincentral` es la única permitida por la suscripción Azure for Students.
- Azure no admite claves SSH ed25519: se requiere RSA 4096 (`ssh-keygen -t rsa -b 4096 -f ~/.ssh/casopractico2`).
- El DNS label de Jenkins se asigna automáticamente por el playbook tras crear el LoadBalancer.
