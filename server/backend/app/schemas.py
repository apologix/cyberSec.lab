from typing import Literal

from pydantic import BaseModel, ConfigDict, Field


class ReconRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", str_max_length=512)

    session_id: str = Field(min_length=16, max_length=64, pattern=r"^[A-Za-z0-9_-]+$")
    browser: dict[str, object] = Field(default_factory=dict, max_length=80)
    location: "BrowserLocation | None" = None


class BrowserLocation(BaseModel):
    model_config = ConfigDict(extra="forbid")

    latitude: float | None = Field(default=None, ge=-90, le=90)
    longitude: float | None = Field(default=None, ge=-180, le=180)
    accuracy: float | None = Field(default=None, ge=0, le=100_000)
    timestamp: int | None = Field(default=None, ge=0)
    permission_state: str = Field(max_length=32)


class CollectorRequest(BaseModel):
    model_config = ConfigDict(extra="forbid", str_max_length=512)

    session_id: str = Field(min_length=16, max_length=64, pattern=r"^[A-Za-z0-9_-]+$")
    collector_version: str = Field(min_length=1, max_length=32)
    platform: Literal["windows", "linux"]
    hostname: str = Field(min_length=1, max_length=255)
    os: str = Field(min_length=1, max_length=255)
    architecture: str = Field(min_length=1, max_length=64)
    network_data: dict[str, object] = Field(default_factory=dict, max_length=20)
    uptime_seconds: int | None = Field(default=None, ge=0)
