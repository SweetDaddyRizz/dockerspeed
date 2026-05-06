#!/bin/sh
set -eu

has_arg() {
  wanted="$1"
  shift

  for arg do
    if [ "$arg" = "$wanted" ]; then
      return 0
    fi
  done

  return 1
}

if [ "${TOPSPEED_PORT:-}" != "" ] && ! has_arg "--port" "$@"; then
  set -- "$@" --port "$TOPSPEED_PORT"
fi

if [ "${TOPSPEED_MAX_PLAYERS:-}" != "" ] && ! has_arg "--max-players" "$@"; then
  set -- "$@" --max-players "$TOPSPEED_MAX_PLAYERS"
fi

if [ "${TOPSPEED_MOTD:-}" != "" ] && ! has_arg "--motd" "$@"; then
  set -- "$@" --motd "$TOPSPEED_MOTD"
fi

if [ "${TOPSPEED_LOG_LEVEL:-}" != "" ] && ! has_arg "--log-level" "$@"; then
  set -- "$@" --log-level "$TOPSPEED_LOG_LEVEL"
fi

exec /app/TopSpeed.Server "$@"
