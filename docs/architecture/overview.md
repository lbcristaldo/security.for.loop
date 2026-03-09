# Secure App - Arquitectura

## Visión General
Aplicación con pipeline CI/CD seguro implementando:
- **Checkov**: Análisis de IaC
- **Trivy**: Escaneo de vulnerabilidades en imágenes
- **SBOM**: Generación de Software Bill of Materials
- **Cosign**: Firmado de imágenes
- **Falco**: Runtime security
- **HPA/VPA**: Escalamiento automático

## Componentes AWS
- **EKS**: Orquestación de contenedores
- **RDS PostgreSQL**: Base de datos transaccional
- **DynamoDB**: Almacenamiento de sesiones y eventos
- **S3**: Almacenamiento de objetos

## Seguridad
- **Vault**: Gestión de secretos dinámicos
- **Sealed Secrets**: Configuración encriptada en git
- **IRSA**: IAM Roles for Service Accounts
- **KMS**: Encriptación de datos en reposo

## Flujo de Datos
1. Cliente → API Gateway → Service (K8s) → App Pod
2. App Pod → RDS (PostgreSQL) para datos transaccionales
3. App Pod → DynamoDB para sesiones/estado
4. App Pod → S3 para archivos estáticos
