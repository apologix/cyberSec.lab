import asyncio
from datetime import datetime, timedelta, timezone

from sqlalchemy import delete, update

from app.core.config import get_settings
from app.core.database import SessionLocal
from app.models import HoneypotEvent, ReconSession


async def purge_expired_data() -> None:
    settings = get_settings()
    now = datetime.now(timezone.utc)
    async with SessionLocal() as session:
        await session.execute(delete(ReconSession).where(ReconSession.created_at < now - timedelta(days=settings.data_retention_recon_days)))
        await session.execute(delete(HoneypotEvent).where(HoneypotEvent.created_at < now - timedelta(days=settings.data_retention_honeypot_days)))
        await session.execute(update(ReconSession).where(ReconSession.created_at < now - timedelta(days=settings.data_retention_precise_location_days)).values(browser_location=None))
        await session.commit()


async def retention_loop() -> None:
    while True:
        await asyncio.sleep(86_400)
        await purge_expired_data()
