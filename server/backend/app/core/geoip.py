from pathlib import Path

from geoip2.database import Reader
from geoip2.errors import AddressNotFoundError

from app.core.config import get_settings


def lookup(ip_address: str) -> dict[str, object]:
    """Return only approximate GeoIP fields; an absent local database is valid."""
    database_path = get_settings().geoip_database_path
    if not database_path or not Path(database_path).is_file():
        return {}
    try:
        with Reader(database_path) as reader:
            response = reader.city(ip_address)
            return {
                "country": response.country.name,
                "country_code": response.country.iso_code,
                "region": response.subdivisions.most_specific.name,
                "city": response.city.name,
                "latitude": response.location.latitude,
                "longitude": response.location.longitude,
                "accuracy_radius_km": response.location.accuracy_radius,
            }
    except (AddressNotFoundError, ValueError):
        return {}
