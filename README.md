# TopSpeed Server Docker

This repo exists so you can run a TopSpeed dedicated server as a normal Docker container and update it like the rest of your stack.

The published image is expected at:

```text
ghcr.io/sweetdaddyrizz/topspeed-server
```

## Quick start

1. Install Docker and Docker Compose on your Linux host.
2. Make sure UDP `28630` and `28631` are allowed through your firewall.
3. Use [docker-compose.registry.yml](C:/Users/Matthew/code/TopSpeed.Server-linux-x64-Release-v-2026.4.13.2/docker-compose.registry.yml) as your starting point.
4. Start the container:

```sh
docker compose -f docker-compose.registry.yml up -d
```

5. Watch the logs:

```sh
docker compose -f docker-compose.registry.yml logs -f topspeed-server
```

If the package is private, log in first:

```sh
docker login ghcr.io
```

## Which image tag to use

Most hosts should use:

```yaml
image: ghcr.io/sweetdaddyrizz/topspeed-server:latest
```

That `latest` tag is a multi-arch manifest with this mapping:

| Host architecture | Pulled image |
| --- | --- |
| `amd64` | `linux-musl-x64` |
| `arm64` | `linux-arm64` |
| `arm32` | `linux-arm32` |

If you want a specific variant instead of the default mapping, use one of these tags:

| Tag | Upstream release asset |
| --- | --- |
| `amd64-latest` | `TopSpeed.Server-linux-musl-x64-Release-v*.zip` |
| `arm64-latest` | `TopSpeed.Server-linux-arm64-Release-v*.zip` |
| `arm32-latest` | `TopSpeed.Server-linux-arm32-Release-v*.zip` |
| `musl-arm64-latest` | `TopSpeed.Server-linux-musl-arm64-Release-v*.zip` |

Example for a host that specifically needs the musl ARM64 build:

```yaml
image: ghcr.io/sweetdaddyrizz/topspeed-server:musl-arm64-latest
```

## Default ports

The container defaults to:

- UDP `28630` for the main server
- UDP `28631` for discovery

The Compose example maps both:

```yaml
ports:
  - "28630:28630/udp"
  - "28631:28631/udp"
```

If the server logs show different effective values for `port` or `discoveryPort`, update both the environment and the port mapping together.

## Basic configuration

The container entrypoint maps a few common environment variables to the server's CLI arguments:

| Variable | Server argument |
| --- | --- |
| `TOPSPEED_PORT` | `--port` |
| `TOPSPEED_MAX_PLAYERS` | `--max-players` |
| `TOPSPEED_MOTD` | `--motd` |
| `TOPSPEED_LOG_LEVEL` | `--log-level` |

Example:

```yaml
environment:
  TOPSPEED_PORT: "28630"
  TOPSPEED_MAX_PLAYERS: "32"
  TOPSPEED_LOG_LEVEL: "info"
  TOPSPEED_MOTD: "Welcome to TopSpeed"
```

You can also pass server arguments directly:

```sh
docker run --rm -it \
  -p 28630:28630/udp \
  -p 28631:28631/udp \
  ghcr.io/sweetdaddyrizz/topspeed-server:latest \
  --max-players 16
```

## Persistent data

The registry Compose file stores settings in a named volume:

```yaml
volumes:
  - topspeed-data:/app/settings
```

That keeps server settings across container recreations.

## Updating

If you are using the published GHCR image, the normal update path is:

```sh
docker compose -f docker-compose.registry.yml pull
docker compose -f docker-compose.registry.yml up -d
```

If you leave the `watchtower` service enabled in [docker-compose.registry.yml](C:/Users/Matthew/code/TopSpeed.Server-linux-x64-Release-v-2026.4.13.2/docker-compose.registry.yml), it will watch for a newer image and recreate the TopSpeed container automatically.

Watchtower is configured with `--label-enable`, so it only updates containers that carry:

```yaml
labels:
  com.centurylinklabs.watchtower.enable: "true"
```

## First deployment checklist

Use this when you bring up the server for the first time:

1. Confirm the container starts without crashing:
   ```sh
   docker compose -f docker-compose.registry.yml ps
   ```
2. Confirm the logs show the expected server port and discovery port:
   ```sh
   docker compose -f docker-compose.registry.yml logs topspeed-server
   ```
3. Confirm your firewall/NAT forwards UDP `28630` and `28631`.
4. Confirm clients can see or join the server.
5. Only after that, decide whether you want Watchtower left on for automatic updates.

## If you want to build locally instead

This repo can still build a local image from a downloaded TopSpeed release, but that is mainly for development or testing.

If you do that, put the extracted server bundle in `app/` and build with:

```sh
docker build -t topspeed-server:test .
```

Then run it with:

```sh
docker compose up --build
```

The built-in TopSpeed updater is not the preferred Docker update path. It updates files inside a container, and those changes disappear when the container is replaced. Pulling a newer image is the cleaner model.

## How this image gets published

The GitHub Actions workflow at [.github/workflows/publish-container.yml](C:/Users/Matthew/code/TopSpeed.Server-linux-x64-Release-v-2026.4.13.2/.github/workflows/publish-container.yml):

1. Reads the latest release from `diamondStar35/top_speed`
2. Finds the current Linux server assets
3. Downloads and extracts them into `app/`
4. Builds the Docker image for each supported target
5. Pushes the images to GHCR

The workflow runs daily and can also be triggered manually from GitHub Actions.
