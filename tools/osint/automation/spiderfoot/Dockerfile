FROM python:3.12-alpine
ARG SPIDERFOOT_REF=v4.0
RUN apk add --no-cache git build-base libffi-dev openssl-dev libxml2-dev libxslt-dev jpeg-dev zlib-dev
RUN git clone --depth 1 --branch "${SPIDERFOOT_REF}" https://github.com/smicallef/spiderfoot.git /opt/spiderfoot \
    && pip install --no-cache-dir -r /opt/spiderfoot/requirements.txt
WORKDIR /opt/spiderfoot
RUN adduser -D -h /var/lib/spiderfoot spiderfoot \
    && mkdir -p /var/lib/spiderfoot \
    && chown -R spiderfoot:spiderfoot /opt/spiderfoot /var/lib/spiderfoot
USER spiderfoot
ENTRYPOINT ["python3", "sf.py"]
CMD ["-l", "0.0.0.0:5001"]
