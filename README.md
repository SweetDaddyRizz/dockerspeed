# Docker

This directory contains Docker support for a published Linux x64 TopSpeed server bundle. Put the server release files in `app/`; the image runs the bundled self-contained .NET executable directly.

## Build

```sh
docker build -t topspeed-server:2026.4.13.2 .
```

## Run

```sh
docker run --rm -it \
  --name topspeed-server \
  -p 28630:28630/udp \
  -p 28631:28631/udp \
  -e TOPSPEED_PORT=28630 \
  -e TOPSPEED_MAX_PLAYERS=32 \
  topspeed-server:2026.4.13.2
```

Or use Compose:

```sh
docker compose up --build
```

## Configuration

The entrypoint maps common environment variables to the server's command-line options:

| Variable | Server argument |
| --- | --- |
| `TOPSPEED_PORT` | `--port` |
| `TOPSPEED_MAX_PLAYERS` | `--max-players` |
| `TOPSPEED_MOTD` | `--motd` |
| `TOPSPEED_LOG_LEVEL` | `--log-level` |

You can also pass server arguments directly:

```sh
docker run --rm -it -p 9000:9000/udp topspeed-server:2026.4.13.2 --port 9000 --max-players 16
```

The Compose file persists `/app/settings` in a named volume. If this server writes settings somewhere else, adjust the volume path to match the generated file after the first run.

## Updating

To update the server, replace the contents of `app/` with the newer `TopSpeed.Server-linux-x64` release, then rebuild and restart:

```sh
docker compose down
docker compose up --build -d
```

Keep these files at the top level:

```text
Dockerfile
docker-entrypoint.sh
.dockerignore
docker-compose.yml
README.Docker.md
```

The server's built-in updater is not the preferred update path inside Docker because updates written inside a container are lost when that container is recreated. Rebuilding the image from a fresh release keeps the running server reproducible.

## Publishing Images

This repo includes a GitHub Actions workflow at `.github/workflows/publish-container.yml` that can publish Docker images to GitHub Container Registry.

The workflow:

1. Reads the latest release from `diamondStar35/top_speed`.
2. Finds the current Linux server assets:
   - `TopSpeed.Server-linux-musl-x64-Release-v*.zip`
   - `TopSpeed.Server-linux-arm64-Release-v*.zip`
   - `TopSpeed.Server-linux-arm32-Release-v*.zip`
   - `TopSpeed.Server-linux-musl-arm64-Release-v*.zip`
3. Downloads and extracts each asset into `app/`.
4. Builds this Dockerfile with the correct base image for that target.
5. Pushes architecture-specific tags and a default multi-arch `latest` manifest.

To use it:

```sh
git init
git add .
git commit -m "Containerize TopSpeed server"
git branch -M main
git remote add origin https://github.com/YOUR_GITHUB_USERNAME/topspeed-server-container.git
git push -u origin main
```

Then open the repo in GitHub, go to **Actions**, run **Publish container**, and check the **Packages** section for the pushed image.

By default, the workflow publishes these tags:

| Tag | Release asset |
| --- | --- |
| `latest` | multi-arch manifest: musl x64, glibc arm64, glibc arm32 |
| `<version>` | versioned form of `latest` |
| `amd64-latest` | `TopSpeed.Server-linux-musl-x64-Release-v*.zip` |
| `arm64-latest` | `TopSpeed.Server-linux-arm64-Release-v*.zip` |
| `arm32-latest` | `TopSpeed.Server-linux-arm32-Release-v*.zip` |
| `musl-arm64-latest` | `TopSpeed.Server-linux-musl-arm64-Release-v*.zip` |

If the package is private, make it public in the package settings or log in to GHCR on the server host before pulling.

The workflow also runs daily, so it will publish a new `latest` image after an upstream release appears.

## Pull-Based Updates

For a server host that pulls updates like your other containers, use `docker-compose.registry.yml`:

```sh
docker compose -f docker-compose.registry.yml up -d
```

Before starting it, replace this placeholder with your actual GHCR image:

```yaml
image: ghcr.io/YOUR_GITHUB_USERNAME/topspeed-server:latest
```

Use `:latest` if you want the default architecture mapping. If you need the musl ARM64 variant specifically, use `:musl-arm64-latest` instead.

That Compose file includes Watchtower with `--label-enable`, and the TopSpeed service has the matching `com.centurylinklabs.watchtower.enable=true` label. Watchtower will poll for a new image and recreate only labeled containers when `latest` changes.

## Ports

The image exposes UDP `28630` for the game server and UDP `28631` for discovery as container defaults. On startup the server logs its effective `port` and `discoveryPort`; if those differ from the Compose file, update `TOPSPEED_PORT` and the `ports:` mappings together.
