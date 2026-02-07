# Deploying Campfire to Railway

## Prerequisites

- A [Railway](https://railway.com) account (new accounts get a $5 free trial credit)

## 1. Create a new project

1. In the Railway dashboard, click **New Project** > **Deploy from GitHub Repo**
2. Select your Campfire repository
3. Railway will auto-detect the Dockerfile and start building

## 2. Configure environment variables

In the service's **Variables** tab, add:

```
RAILS_ENV=production
DISABLE_SSL=true
WEB_CONCURRENCY=2
RESQUE_WORKERS=2
SECRET_KEY_BASE=<run `openssl rand -hex 64` to generate>
VAPID_PUBLIC_KEY=<your-public-key>
VAPID_PRIVATE_KEY=<your-private-key>
```

`WEB_CONCURRENCY` and `RESQUE_WORKERS` cap process counts to avoid OOM kills on small containers.

Generate VAPID keys locally:

```bash
docker build -t campfire .
docker run --rm campfire ./script/admin/create-vapid-key
```

## 3. Add a persistent volume

Open the Command Palette (`Ctrl+K`) and type "volume", or right-click the project canvas. Mount the volume at `/rails/storage` — this stores the SQLite database and file uploads.

## 4. Configure networking

In the service's **Networking** tab:

1. Set the port to **8080**
2. Click **Generate Domain** to get a `*.up.railway.app` URL

## 5. First login

Visit your Railway URL and create your admin account.

## Notes

- Redis runs embedded in the container (via Procfile) — no external Redis service needed
- Railway handles SSL termination; `DISABLE_SSL=true` tells Rails not to enforce SSL internally
- Thruster is bypassed on Railway — Puma serves directly on PORT
- By default, Puma and Resque scale workers to the host CPU count, which is too many for small containers — set `WEB_CONCURRENCY` and `RESQUE_WORKERS` to 2 each
- SQLite means only one replica can run at a time
- The $5 trial credit is enough for initial testing; after that Railway charges based on usage
