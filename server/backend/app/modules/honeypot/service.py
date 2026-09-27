import hashlib

from fastapi import Request
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.geoip import lookup
from app.core.http import client_ip, declared_body_size, safe_metadata
from app.models import HoneypotEvent


async def record(requested_path: str, request: Request, session: AsyncSession) -> None:
    source = client_ip(request)
    correlation = hashlib.sha256(f"{source}:{request.headers.get('user-agent', '')}".encode()).hexdigest()[:32]
    session.add(HoneypotEvent(correlation_id=correlation, source_ip=source, method=request.method, path=f"/honeypot/{requested_path}"[:2048], query_string=str(request.url.query)[:2048], selected_headers=safe_metadata(request), body_size=declared_body_size(request), geoip_data=lookup(source)))
    await session.commit()
