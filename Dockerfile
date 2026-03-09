# syntax=docker/dockerfile:1.4
FROM python:3.11-slim AS builder

WORKDIR /app

# Cache de dependencias
COPY src/requirements.txt .
RUN pip install --user -r requirements.txt && \
    pip install --user gunicorn uvloop httptools

FROM python:3.11-slim AS runtime

# Variables de entorno no sensibles
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    ENVIRONMENT=production \
    LOG_LEVEL=info \
    PORT=8000

WORKDIR /app

# Crear usuario no-root
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 appuser && \
    mkdir -p /app/src && \
    chown -R appuser:appgroup /app

# Copiar dependencias del builder
COPY --from=builder --chown=appuser:appgroup /root/.local /home/appuser/.local

# Copiar código de la aplicación
COPY --chown=appuser:appgroup src/app /app/src/
COPY --chown=appuser:appgroup src/scripts /app/scripts/

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health')" || exit 1

USER appuser

# Asegurar que las rutas de usuario estén en PATH
ENV PATH="/home/appuser/.local/bin:${PATH}"

EXPOSE 8000

CMD ["gunicorn", "src.main:app", "--workers", "4", "--worker-class", "uvicorn.workers.UvicornWorker", "--bind", "0.0.0.0:8000"]
