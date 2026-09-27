from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.modules.admin import service
from app.modules.auth.users import current_active_user

router = APIRouter(prefix="/api/admin", tags=["admin"], dependencies=[Depends(current_active_user)])


def bounded(limit: int) -> int:
    return min(max(limit, 1), 200)


@router.get("/overview")
async def overview(session: AsyncSession = Depends(get_session)) -> dict[str, object]:
    return await service.overview(session)


@router.get("/events")
async def events(limit: int = 100, session: AsyncSession = Depends(get_session)) -> dict[str, list[dict[str, object]]]:
    return await service.events(session, bounded(limit))


@router.get("/recon")
async def recon(limit: int = 100, session: AsyncSession = Depends(get_session)) -> dict[str, list[dict[str, object]]]:
    return await service.recon_sessions(session, bounded(limit))


@router.get("/collectors")
async def collectors(limit: int = 100, session: AsyncSession = Depends(get_session)) -> dict[str, list[dict[str, object]]]:
    return await service.collectors(session, bounded(limit))


@router.get("/scripts")
async def scripts() -> dict[str, list[dict[str, str]]]:
    return service.scripts()
