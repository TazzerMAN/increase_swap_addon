ARG BUILD_FROM=ghcr.io/home-assistant/base:3.24-2026.11.0
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Bashio logs only the time by default; the date helps when reading older logs.
ENV LOG_TIMESTAMP="%H:%M:%S %d/%m/%Y"

COPY run.sh /
RUN chmod a+x /run.sh

LABEL \
    org.opencontainers.image.title="Home Assistant App: Increase Swap" \
    org.opencontainers.image.description="Adds a swap file to Home Assistant OS." \
    org.opencontainers.image.source="https://github.com/TazzerMAN/increase_swap_addon" \
    org.opencontainers.image.licenses="GPL-3.0"

CMD [ "/run.sh" ]
