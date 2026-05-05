#!/usr/bin/env bash
set -euo pipefail
exec /docker-entrypoint.sh kong docker-start
