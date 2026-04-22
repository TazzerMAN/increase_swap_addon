ARG BUILD_FROM=ghcr.io/hassio-addons/base:20.1.0
FROM ${BUILD_FROM}

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Copy data for add-on
COPY run.sh /
RUN chmod a+x /run.sh

LABEL \
    org.opencontainers.image.title="Home Assistant Add-on: Increase Swap" \
    org.opencontainers.image.description="Increases the swap space on your system." \
    org.opencontainers.image.source="https://github.com/TazzerMAN/increase_swap_addon" \
    org.opencontainers.image.licenses="GPL-3.0"

CMD [ "/run.sh" ]
