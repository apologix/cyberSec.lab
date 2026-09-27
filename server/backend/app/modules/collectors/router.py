from fastapi import APIRouter, Depends, Header, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.modules.collectors import service
from app.schemas import CollectorRequest

router = APIRouter(prefix="/api/collector", tags=["collectors"])


@router.post("", status_code=status.HTTP_202_ACCEPTED)
async def create(payload: CollectorRequest, request: Request, x_collector_token: str | None = Header(default=None), session: AsyncSession = Depends(get_session)) -> dict[str, str]:
    return await service.record(payload, request, x_collector_token, session)
