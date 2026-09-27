from datetime import datetime
from uuid import UUID, uuid4

from fastapi_users.db import SQLAlchemyBaseUserTableUUID
from sqlalchemy import DateTime, Integer, String, Text, func
from sqlalchemy.dialects.postgresql import JSONB, UUID as PG_UUID
from sqlalchemy.orm import DeclarativeBase, Mapped, mapped_column


class Base(DeclarativeBase):
    pass


class User(SQLAlchemyBaseUserTableUUID, Base):
    __tablename__ = "users"


class ReconSession(Base):
    __tablename__ = "recon_sessions"

    id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    session_id: Mapped[str] = mapped_column(String(64), index=True)
    source_ip: Mapped[str] = mapped_column(String(45), index=True)
    http_metadata: Mapped[dict] = mapped_column(JSONB, default=dict)
    browser_data: Mapped[dict] = mapped_column(JSONB, default=dict)
    browser_location: Mapped[dict | None] = mapped_column(JSONB, nullable=True)
    geoip_data: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)


class HoneypotEvent(Base):
    __tablename__ = "honeypot_events"

    id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    correlation_id: Mapped[str] = mapped_column(String(128), index=True)
    source_ip: Mapped[str] = mapped_column(String(45), index=True)
    method: Mapped[str] = mapped_column(String(10))
    path: Mapped[str] = mapped_column(Text)
    query_string: Mapped[str] = mapped_column(Text, default="")
    selected_headers: Mapped[dict] = mapped_column(JSONB, default=dict)
    body_size: Mapped[int] = mapped_column(Integer, default=0)
    response_status: Mapped[int] = mapped_column(Integer, default=404)
    geoip_data: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)


class CollectorEvent(Base):
    __tablename__ = "collector_events"

    id: Mapped[UUID] = mapped_column(PG_UUID(as_uuid=True), primary_key=True, default=uuid4)
    session_id: Mapped[str] = mapped_column(String(64), index=True)
    source_ip: Mapped[str] = mapped_column(String(45), index=True)
    collector_version: Mapped[str] = mapped_column(String(32))
    payload: Mapped[dict] = mapped_column(JSONB, default=dict)
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), server_default=func.now(), index=True)
