import hmac

from fastapi import HTTPException, Request, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.http import client_ip
from app.models import CollectorEvent
from app.schemas import CollectorRequest


async def record(payload: CollectorRequest, request: Request, token: str | None, session: AsyncSession) -> dict[str, str]:
    if not token or not hmac.compare_digest(token, get_settings().collector_shared_token):
        raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Access forbidden.")
    session.add(CollectorEvent(session_id=payload.session_id, source_ip=client_ip(request), collector_version=payload.collector_version, payload=payload.model_dump()))
    await session.commit()
    return {"status": "accepted"}
