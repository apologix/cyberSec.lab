import uuid

from fastapi import Depends
from fastapi_users import BaseUserManager, FastAPIUsers, UUIDIDMixin, schemas
from fastapi_users.authentication import AuthenticationBackend, CookieTransport, JWTStrategy
from fastapi_users.db import SQLAlchemyUserDatabase
from sqlalchemy.ext.asyncio import AsyncSession

from app.core.config import get_settings
from app.core.database import SessionLocal, get_session
from app.models import User


class UserRead(schemas.BaseUser[uuid.UUID]):
    pass


class UserCreate(schemas.BaseUserCreate):
    pass


async def get_user_db(session: AsyncSession = Depends(get_session)):
    yield SQLAlchemyUserDatabase(session, User)


class UserManager(UUIDIDMixin, BaseUserManager[User, uuid.UUID]):
    @property
    def reset_password_token_secret(self) -> str:
        return get_settings().session_secret

    @property
    def verification_token_secret(self) -> str:
        return get_settings().session_secret


async def get_user_manager(user_db: SQLAlchemyUserDatabase = Depends(get_user_db)):
    yield UserManager(user_db)


cookie_transport = CookieTransport(
    cookie_name="cyberlab_auth",
    cookie_max_age=28_800,
    cookie_secure=get_settings().cookie_secure,
    cookie_samesite="strict",
)
auth_backend = AuthenticationBackend(
    name="cookie",
    transport=cookie_transport,
    get_strategy=lambda: JWTStrategy(
        secret=get_settings().session_secret,
        lifetime_seconds=28_800,
    ),
)
fastapi_users = FastAPIUsers[User, uuid.UUID](get_user_manager, [auth_backend])
current_active_user = fastapi_users.current_user(active=True, superuser=True)


async def bootstrap_superuser() -> None:
    from sqlalchemy import select

    settings = get_settings()
    async with SessionLocal() as session:
        existing = await session.scalar(
            select(User).where(User.email == settings.first_superuser_email)
        )
        if not existing:
            manager = UserManager(SQLAlchemyUserDatabase(session, User))
            await manager.create(
                UserCreate(
                    email=settings.first_superuser_email,
                    password=settings.first_superuser_password,
                    is_superuser=True,
                    is_active=True,
                )
            )
