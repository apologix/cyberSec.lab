import ipaddress

from fastapi import Request

from app.core.config import get_settings

SAFE_HEADERS = {"accept", "accept-language", "accept-encoding", "referer", "origin", "user-agent", "content-type"}


def client_ip(request: Request) -> str:
    peer = request.client.host if request.client else "unknown"
    settings = get_settings()
    try:
        trusted = any(ipaddress.ip_address(peer) in ipaddress.ip_network(cidr.strip()) for cidr in settings.trusted_proxy_cidrs.split(","))
    except ValueError:
        trusted = False
    if trusted:
        forwarded = request.headers.get("x-forwarded-for", "").split(",")[0].strip()
        try:
            return str(ipaddress.ip_address(forwarded)) if forwarded else peer
        except ValueError:
            pass
    return peer


def safe_metadata(request: Request) -> dict[str, str]:
    return {key: value[:512] for key, value in request.headers.items() if key.lower() in SAFE_HEADERS}


def declared_body_size(request: Request) -> int:
    try:
        return min(max(int(request.headers.get("content-length", "0") or 0), 0), 32_768)
    except ValueError:
        return 0
