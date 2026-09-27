from fastapi import APIRouter, Depends, Request, Response, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.database import get_session
from app.modules.honeypot import service

router = APIRouter(prefix="/honeypot", tags=["honeypot"])


@router.api_route("/{requested_path:path}", methods=["GET", "POST", "PUT", "PATCH", "DELETE", "HEAD", "OPTIONS"])
async def capture(requested_path: str, request: Request, session: AsyncSession = Depends(get_session)) -> Response:
    await service.record(requested_path, request, session)
    return Response(status_code=status.HTTP_404_NOT_FOUND)
