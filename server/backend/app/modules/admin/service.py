import hashlib
from collections import Counter
from pathlib import Path

from sqlalchemy import desc, func, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.models import CollectorEvent, HoneypotEvent, ReconSession

SCRIPT_ROOT = Path("/app/static-scripts")


async def overview(session: AsyncSession) -> dict[str, object]:
    async def count(model) -> int:
        return int((await session.scalar(select(func.count()).select_from(model))) or 0)
    paths = await session.execute(select(HoneypotEvent.path, func.count().label("hits")).group_by(HoneypotEvent.path).order_by(desc("hits")).limit(8))
    geoips = (await session.scalars(select(HoneypotEvent.geoip_data))).all()
    countries = Counter((entry or {}).get("country") or "Unknown" for entry in geoips).most_common(8)
    return {"recon_sessions": await count(ReconSession), "honeypot_events": await count(HoneypotEvent), "collector_events": await count(CollectorEvent), "top_paths": [{"path": path, "hits": hits} for path, hits in paths], "countries": [{"country": country, "hits": hits} for country, hits in countries]}


async def events(session: AsyncSession, limit: int) -> dict[str, list[dict[str, object]]]:
    rows = (await session.scalars(select(HoneypotEvent).order_by(desc(HoneypotEvent.created_at)).limit(limit))).all()
    return {"events": [{"id": str(row.id), "timestamp": row.created_at.isoformat(), "source_ip": row.source_ip, "method": row.method, "path": row.path, "geoip": row.geoip_data} for row in rows]}


async def recon_sessions(session: AsyncSession, limit: int) -> dict[str, list[dict[str, object]]]:
    rows = (await session.scalars(select(ReconSession).order_by(desc(ReconSession.created_at)).limit(limit))).all()
    return {"sessions": [{"id": str(row.id), "session_id": row.session_id, "timestamp": row.created_at.isoformat(), "source_ip": row.source_ip, "geoip": row.geoip_data, "browser": row.browser_data} for row in rows]}


async def collectors(session: AsyncSession, limit: int) -> dict[str, list[dict[str, object]]]:
    rows = (await session.scalars(select(CollectorEvent).order_by(desc(CollectorEvent.created_at)).limit(limit))).all()
    return {"collectors": [{"id": str(row.id), "timestamp": row.created_at.isoformat(), "source_ip": row.source_ip, "payload": row.payload} for row in rows]}


def scripts() -> dict[str, list[dict[str, str]]]:
    files = [{"name": str(path.relative_to(SCRIPT_ROOT)), "sha256": hashlib.sha256(path.read_bytes()).hexdigest()} for path in SCRIPT_ROOT.rglob("*") if path.is_file() and not path.name.endswith(".sha256")]
    return {"scripts": sorted(files, key=lambda item: item["name"])}
