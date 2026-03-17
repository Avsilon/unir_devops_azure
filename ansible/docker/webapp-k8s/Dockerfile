# ============================================================
# Dockerfile — webapp-k8s (Jenkins LTS)
# Caso Práctico 2 — UNIR DevOps Azure
# ============================================================

FROM docker.io/jenkins/jenkins:lts-jdk17

# Instalación de dependencias adicionales
USER root

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        apt-transport-https \
        gnupg && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

USER jenkins

EXPOSE 8080
EXPOSE 50000

# Directorio de datos de Jenkins (se monta como PVC en AKS)
VOLUME /var/jenkins_home
