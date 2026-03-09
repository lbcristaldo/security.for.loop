# Secure App Project

## Descripción
Proyecto demo de pipeline CI/CD seguro con Tekton, integrando herramientas de seguridad y despliegue en AWS.

## Estructura del Proyecto

```
.
├── docker/          # Configuración Docker y docker-compose
├── docs/            # Documentación
├── iac/             # Terraform para infraestructura AWS
├── k8s/             # Manifiestos Kubernetes
├── monitoring/      # Configuración de monitoreo
├── security/        # Configuraciones de seguridad
├── src/             # Código fuente de la aplicación
└── tekton/          # Pipelines Tekton
```

## Despliegue Rápido

```bash
# 1. Configurar infraestructura
cd iac/terraform/environments/dev
terraform init
terraform apply

# 2. Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name dev-app-cluster

# 3. Instalar Tekton
kubectl apply -f https://storage.googleapis.com/tekton-releases/pipeline/latest/release.yaml

# 4. Aplicar pipelines
kubectl apply -f tekton/tasks/
kubectl apply -f tekton/pipelines/

# 5. Ejecutar pipeline
kubectl apply -f tekton/runs/pipeline-run.yaml
```

## Gestión de Secretos
- Vault: Credenciales de DB (rotación automática)
- Sealed Secrets: Configuración AWS en git
- IRSA: Permisos AWS para pods
- CSI Secrets Store: Montaje seguro de secretos

## Monitoreo
- Prometheus + Grafana para métricas
- CloudWatch para logs
- Falco para alertas de seguridad

## Entornos
- dev: Desarrollo local con docker-compose
- staging: Simulación en AWS (instancias pequeñas)
- prod: Producción completa con HA
