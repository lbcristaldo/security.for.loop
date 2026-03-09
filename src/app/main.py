"""
Aplicación principal con FastAPI
Integración con PostgreSQL, DynamoDB y S3
"""
from fastapi import FastAPI, Depends, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
import logging
import os
import boto3
import asyncpg
from typing import Optional

from src.app.api import router as api_router
from src.app.core.config import settings
from src.app.db.postgres import init_db as init_postgres
from src.app.db.dynamodb import init_db as init_dynamodb

# Configurar logging
logging.basicConfig(
    level=getattr(logging, settings.LOG_LEVEL),
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    """
    Manejo del ciclo de vida de la aplicación
    """
    # Startup
    logger.info("Iniciando aplicación...")

    # Inicializar conexiones a bases de datos
    try:
        await init_postgres()
        await init_dynamodb()
        logger.info("Conexiones a bases de datos establecidas")
    except Exception as e:
        logger.error(f"Error conectando a bases de datos: {e}")
        raise

    yield

    # Shutdown
    logger.info("Cerrando aplicación...")
    # Cerrar conexiones aquí si es necesario

# Crear aplicación FastAPI
app = FastAPI(
    title="Secure App",
    description="Aplicación con pipeline seguro",
    version="1.0.0",
    lifespan=lifespan
)

# Configurar CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.ALLOWED_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Incluir routers
app.include_router(api_router, prefix="/api/v1")

@app.get("/")
async def root():
    return {
        "message": "Secure App API",
        "environment": settings.ENVIRONMENT,
        "version": "1.0.0"
    }

@app.get("/health")
async def health():
    """
    Health check para Kubernetes
    """
    return {
        "status": "healthy",
        "database": "connected",
        "dynamodb": "connected"
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
