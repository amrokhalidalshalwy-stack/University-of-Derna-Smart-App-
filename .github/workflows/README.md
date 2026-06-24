## Required GitHub Secrets

Add these in: GitHub repo → Settings → Secrets → Actions

| Secret Name        | Value                                      |
|--------------------|--------------------------------------------|
| API_BASE_URL       | Your backend base URL                      |
| GOOGLE_CLIENT_ID   | From Google Cloud Console                  |
| KEYSTORE_BASE64    | base64 encoded .jks file (see below)       |
| KEYSTORE_PASSWORD  | hifzh2024 (change in production)           |
| KEY_PASSWORD       | hifzh2024 (change in production)           |
| KEY_ALIAS          | hifzh                                      |

## How to encode your keystore

On Mac/Linux:
  base64 -i android/app/hifzh_release.jks | pbcopy

On Windows (PowerShell):
  [Convert]::ToBase64String(
    [IO.File]::ReadAllBytes("android\app\hifzh_release.jks")
  ) | Set-Clipboard

Paste the result as the KEYSTORE_BASE64 secret value.
