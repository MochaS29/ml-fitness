# Meal Scan Proxy — API Contract

Both apps' Meal Scanner feature calls a Vercel-hosted proxy instead of the Anthropic API directly. The Anthropic key exists **only** in the proxy's Vercel env vars — it must never appear in either app binary or this repo.

## Endpoint

```
POST https://mochasmindlab.com/api/v1/meal-scan
```

## Auth headers (required)

| Header | Value |
|---|---|
| `X-App-Secret` | App secret — iOS reads it from `ios/HealthTracker/Configuration/Secrets.plist` (gitignored) |
| `X-Install-Id` | Per-install UUID, generated on first launch |
| `X-Platform` | `ios` or `android` |

## Notes

- Deployed live since iOS v2.4.1 (May 2026); proxy code/env managed in the Vercel project for mochasmindlab.com, not in this repo.
- If the contract changes (headers, endpoint, response shape), update this file and **both** apps' clients in the same PR.
- iOS client reference: see the meal scanner service in `ios/HealthTracker/` (the old direct-Anthropic config `APIConfiguration.Anthropic` / `SecretsManager.anthropicAPIKey` was removed in `59b8e21`).
