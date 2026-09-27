from fastapi import APIRouter, Depends

from app.models import User
from app.modules.auth.users import UserRead, auth_backend, current_active_user, fastapi_users

router = APIRouter(prefix="/api/auth", tags=["auth"])
router.include_router(fastapi_users.get_auth_router(auth_backend), prefix="")


@router.get("/me", response_model=UserRead)
async def me(user: User = Depends(current_active_user)) -> User:
    return user
