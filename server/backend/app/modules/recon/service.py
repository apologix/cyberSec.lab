from fastapi import Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.geoip import lookup
from app.core.http import client_ip, safe_metadata
from app.models import ReconSession
from app.schemas import ReconRequest


async def record(payload: ReconRequest, request: Request, session: AsyncSession) -> dict[str, str]:
    source = client_ip(request)
    event = ReconSession(session_id=payload.session_id, source_ip=source, http_metadata=safe_metadata(request), browser_data=payload.browser, browser_location=payload.location.model_dump() if payload.location else None, geoip_data=lookup(source))
    session.add(event)
    await session.commit()
    return {"session_id": payload.session_id, "status": "recorded"}
