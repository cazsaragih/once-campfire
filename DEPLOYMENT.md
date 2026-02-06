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
HTTP_PORT=${{PORT}}
SECRET_KEY_BASE=<run `openssl rand -hex 64` to generate>
VAPID_PUBLIC_KEY=<your-public-key>
VAPID_PRIVATE_KEY=<your-private-key>
```

The critical one is `HTTP_PORT=${{PORT}}` — Railway dynamically assigns a port, and Thruster (the reverse proxy) needs to bind to it.

Generate VAPID keys locally:

```bash
docker build -t campfire .
docker run --rm campfire ./script/admin/create-vapid-key
```

## 3. Add a persistent volume

1. In the service settings, go to **Volumes**
2. Mount a volume at `/rails/storage`
3. This stores the SQLite database and file uploads

## 4. Generate a domain

In the service's **Networking** tab, click **Generate Domain** to get a `*.up.railway.app` URL.

## 5. First login

Visit your Railway URL and create your admin account.

## Notes

- Redis runs embedded in the container (via Procfile) — no external Redis service needed
- Railway handles SSL termination; `DISABLE_SSL=true` tells Rails not to enforce SSL internally
- `${{PORT}}` is Railway's variable reference syntax — it injects the actual port at runtime
- SQLite means only one replica can run at a time
- The $5 trial credit is enough for initial testing; after that Railway charges based on usage
