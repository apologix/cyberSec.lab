import asyncio
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, Request
from fastapi.responses import JSONResponse

from app.core.config import get_settings
from app.core.database import engine
from app.core.retention import purge_expired_data, retention_loop
from app.models import Base
from app.modules.admin.router import router as admin_router
from app.modules.auth.router import router as auth_router
from app.modules.collectors.router import router as collectors_router
from app.modules.honeypot.router import router as honeypot_router
from app.modules.recon.router import router as recon_router
from app.modules.auth.users import bootstrap_superuser


@asynccontextmanager
async def lifespan(_: FastAPI):
    if get_settings().database_auto_create:
        async with engine.begin() as connection:
            await connection.run_sync(Base.metadata.create_all)
        await bootstrap_superuser()
    await purge_expired_data()
    task = asyncio.create_task(retention_loop())
    yield
    task.cancel()
    await engine.dispose()


app = FastAPI(docs_url=None, redoc_url=None, openapi_url=None, debug=False, lifespan=lifespan)


@app.exception_handler(HTTPException)
async def safe_http_error(_: Request, exc: HTTPException):
    message = exc.detail if exc.status_code in {403, 404, 429} else "Request could not be processed."
    return JSONResponse(status_code=exc.status_code, content={"detail": message})


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


app.include_router(auth_router)
app.include_router(recon_router)
app.include_router(honeypot_router)
app.include_router(collectors_router)
app.include_router(admin_router)
