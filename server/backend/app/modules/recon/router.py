from fastapi import APIRouter, Depends, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.modules.recon import service
from app.schemas import ReconRequest

router = APIRouter(prefix="/api/recon", tags=["recon"])


@router.post("", status_code=status.HTTP_201_CREATED)
async def create(payload: ReconRequest, request: Request, session: AsyncSession = Depends(get_session)) -> dict[str, str]:
    return await service.record(payload, request, session)
