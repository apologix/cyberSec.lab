FROM python:3.12-slim-bookworm

ARG IMPACKET_VERSION=0.13.1

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    NO_COLOR=1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       ca-certificates \
       krb5-user \
       libgssapi-krb5-2 \
       libsasl2-modules-gssapi-mit \
       ldap-utils \
       ntpdate \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir --disable-pip-version-check \
       "impacket==${IMPACKET_VERSION}"

WORKDIR /work
ENTRYPOINT ["python3"]
