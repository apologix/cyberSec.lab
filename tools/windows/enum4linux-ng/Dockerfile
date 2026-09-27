FROM python:3.12-slim-bookworm AS source

ARG ENUM4LINUX_NG_VERSION=v1.3.10

RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates git \
    && rm -rf /var/lib/apt/lists/* \
    && git clone --depth 1 --branch "${ENUM4LINUX_NG_VERSION}" \
       https://github.com/cddmp/enum4linux-ng.git /opt/enum4linux-ng

FROM python:3.12-slim-bookworm

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    NO_COLOR=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       dnsutils \
       ldap-utils \
       samba-common-bin \
       smbclient \
    && rm -rf /var/lib/apt/lists/*

COPY --from=source /opt/enum4linux-ng /opt/enum4linux-ng

RUN pip install --no-cache-dir --disable-pip-version-check \
    -r /opt/enum4linux-ng/requirements.txt

WORKDIR /work
ENTRYPOINT ["python3", "/opt/enum4linux-ng/enum4linux-ng.py"]
