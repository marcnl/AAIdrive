#!/bin/bash
# Source is mounted read-only at /src; build happens in /work (a persistent volume, so
# incremental builds are fast and the host checkout never gets root-owned build output).
set -euo pipefail
TASK="${GRADLE_TASK:-assembleNomapNonalyticsFullDebug}"

rsync -a --delete --exclude 'external' --exclude 'app/build' --exclude '.gradle' --exclude 'docker/out' /src/ /work/
cd /work
git config --global --add safe.directory /work

# Reference APKs the build extracts UI resources from (same download step as upstream CI); cached in the work volume
mkdir -p external
bash .github/actions/download-externals-action/download.sh

# Stable signing key, so Spotify's registered fingerprint keeps matching and updates install over each other
mkdir -p /root/.android
[ -f /root/.android/debug.keystore ] || keytool -genkey -v -keystore /root/.android/debug.keystore \
    -storepass android -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 \
    -validity 36500 -dname "CN=Android Debug,O=Android,C=US" >/dev/null 2>&1

echo "=== Signing fingerprint (register this SHA1 at developer.spotify.com) ==="
keytool -list -v -keystore /root/.android/debug.keystore -storepass android -alias androiddebugkey | grep -E "SHA1|SHA256"
echo "==="

./gradlew --no-daemon "$TASK" --stacktrace

mkdir -p /out
find app/build/outputs/apk -name '*.apk' -exec cp -v {} /out/ \;
[ -n "${HOST_UID:-}" ] && chown -R "$HOST_UID:${HOST_GID:-$HOST_UID}" /out || true
