#!/bin/bash
# Usage: AndroidAutoIdrive_SpotifyApiKey=<your spotify client id> docker/build-apk.sh
# Produces docker/out/*.apk. Everything (SDK, Gradle cache, signing key) lives in docker volumes.
set -euo pipefail
cd "$(dirname "$0")/.."
docker build -t aaidrive-builder docker
mkdir -p docker/out
docker run --rm \
    -v "$PWD":/src:ro \
    -v "$PWD/docker/out":/out \
    -v aaidrive-work:/work \
    -v aaidrive-gradle:/root/.gradle \
    -v aaidrive-android:/root/.android \
    -e HOST_UID="$(id -u)" -e HOST_GID="$(id -g)" \
    -e AndroidAutoIdrive_SpotifyApiKey="${AndroidAutoIdrive_SpotifyApiKey:-unset}" \
    -e GRADLE_TASK="${GRADLE_TASK:-assembleNomapNonalyticsFullDebug}" \
    aaidrive-builder
