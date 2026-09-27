FROM debian:bookworm-slim
RUN apt-get update \
    && apt-get install -y --no-install-recommends bind9-dnsutils dnsutils dnsrecon whois ca-certificates \
    && rm -rf /var/lib/apt/lists/*
WORKDIR /case
CMD ["/bin/bash"]
