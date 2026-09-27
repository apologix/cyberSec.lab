import asyncio

from app.core.database import engine
from app.models import Base
from app.modules.auth.users import bootstrap_superuser


async def main() -> None:
    async with engine.begin() as connection:
        await connection.run_sync(Base.metadata.create_all)
    await bootstrap_superuser()
    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())
