# Building the APK with Docker

    AndroidAutoIdrive_SpotifyApiKey=<spotify client id> docker/build-apk.sh

Output lands in `docker/out/`. First run takes a few minutes (Android SDK, Gradle, reference APKs);
later runs reuse the `aaidrive-*` volumes. The signing key lives in the `aaidrive-android` volume and
its SHA1 is printed at the start of every build -- register that, the package name
`me.hufman.androidautoidrive` and the redirect URIs in your own Spotify developer app, otherwise
Spotify refuses the connection (it only trusts the upstream maintainer's signature for their client id).
