from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(case_sensitive=True, extra="ignore")

    environment: str = Field(default="development", validation_alias="CYBERLAB_ENVIRONMENT")
    database_url: str = Field(validation_alias="DATABASE_URL")
    first_superuser_email: str = Field(validation_alias="FIRST_SUPERUSER_EMAIL")
    first_superuser_password: str = Field(validation_alias="FIRST_SUPERUSER_PASSWORD")
    session_secret: str = Field(min_length=32, validation_alias="SESSION_SECRET")
    cookie_secure: bool = Field(default=True, validation_alias="COOKIE_SECURE")
    collector_shared_token: str = Field(min_length=24, validation_alias="COLLECTOR_SHARED_TOKEN")
    trusted_proxy_cidrs: str = Field(default="172.16.0.0/12", validation_alias="TRUSTED_PROXY_CIDRS")
    database_auto_create: bool = Field(default=False, validation_alias="DATABASE_AUTO_CREATE")
    geoip_database_path: str = Field(default="", validation_alias="GEOIP_DATABASE_PATH")
    data_retention_recon_days: int = Field(default=30, validation_alias="DATA_RETENTION_RECON_DAYS")
    data_retention_precise_location_days: int = Field(default=7, validation_alias="DATA_RETENTION_PRECISE_LOCATION_DAYS")
    data_retention_honeypot_days: int = Field(default=90, validation_alias="DATA_RETENTION_HONEYPOT_DAYS")


@lru_cache
def get_settings() -> Settings:
    return Settings()
