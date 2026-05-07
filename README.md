# TopSpeed Server Docker

This repo exists so you can run a TopSpeed dedicated server as a normal Docker container and update it like the rest of your stack.

The published image is expected at ghcr.io/sweetdaddyrizz/topspeed-server

## Quick start

1. Install Docker and Docker Compose on your Linux host.
2. Make sure UDP `28630` and `28631` are allowed through your firewall.
3. Use the example below or docker-compose.registry.yml as your starting point.
4. Start the container:

```sh
docker compose up -d
```

5. Watch the logs:

```sh
docker compose logs
```

## Important Note

The built-in TopSpeed updater is not the preferred Docker update path. It updates files inside a container, and those changes may disappear when the container is replaced. Pulling a newer image is the cleaner model.

## Full Docker Compose Example

```yaml
services:
  topspeed-server:
    image: ghcr.io/sweetdaddyrizz/topspeed-server:latest
    restart: unless-stopped
    environment:
      TOPSPEED_PORT: "28630"
      TOPSPEED_MAX_PLAYERS: "32"
      TOPSPEED_LOG_LEVEL: "info"
       TOPSPEED_MOTD: "Welcome to TopSpeed"
    ports:
      - "28630:28630/udp"
      - "28631:28631/udp"
    volumes:
      - ./topspeed-data:/app/settings
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

The registry Compose file stores settings in a bind mount volume at ./topspeed-data:

```yaml
volumes:
  - ./topspeed-data:/app/settings
```

That keeps server settings across container recreations.

## Updating

If you are using the published GHCR image, the normal update path is:

```sh
docker compose pull
docker compose up -d
```

Also consider deploying this server with Watchtower, which will automatically update your instance when a new server version is released. Example provided in docker-compose.registry.yml

## Important Note

The built-in TopSpeed updater is not the preferred Docker update path. It updates files inside a container, and those changes disappear when the container is replaced. Pulling a newer image is the cleaner model.

## How this image gets published

The GitHub Actions workflow at .github/workflows/publish-container.yml:

1. Reads the latest release from `diamondStar35/top_speed`
2. Finds the current Linux server assets
3. Downloads and extracts them into `app/`
4. Builds the Docker image for each supported target
5. Pushes the images to GHCR

The workflow runs daily.