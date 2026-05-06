ARG BASE_IMAGE=mcr.microsoft.com/dotnet/runtime-deps:10.0
FROM ${BASE_IMAGE}

WORKDIR /app

RUN groupadd --system topspeed \
    && useradd --system --gid topspeed --home-dir /app --shell /usr/sbin/nologin topspeed

COPY --chown=topspeed:topspeed app/ ./
COPY --chown=topspeed:topspeed docker-entrypoint.sh ./

RUN mkdir -p /app/settings \
    && chown topspeed:topspeed /app/settings \
    && chmod +x /app/TopSpeed.Server /app/Updater /app/createdump /app/docker-entrypoint.sh

USER topspeed

EXPOSE 28630/udp
EXPOSE 28631/udp

ENTRYPOINT ["/app/docker-entrypoint.sh"]
