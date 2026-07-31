# Vendored Dropbox client

Source: <https://github.com/mix1009/FlutterDropbox>

Upstream commit: `b9d8000dd7571398c64f2134f5d317392514871e`

Package version: `1.2.1`

This copy is vendored temporarily because the Android implementation creates
`DbxAppInfo` with an empty secret before starting PKCE. xtracker uses Dropbox as
a public OAuth client and must not embed the app secret.

Local change:

- Android initialization uses `DbxAppInfo(key)` when no secret is supplied and
  retains `DbxAppInfo(key, secret)` for legacy callers that provide one.

Once upstream publishes this behavior, replace the path dependency in the root
`pubspec.yaml` with the fixed hosted version and remove this directory.
