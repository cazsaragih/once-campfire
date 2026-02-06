# Deploying Campfire to Render

This guide will walk you through deploying Campfire to Render cloud hosting with managed Redis.

## Prerequisites

- A Render account ([sign up here](https://render.com))
- Your forked Campfire repository pushed to GitHub
- Docker installed locally (for generating VAPID keys)

## Step 1: Generate VAPID Keys

VAPID keys are required for Web Push notifications. Generate them before deploying:

```bash
# Build the Docker image locally
docker build -t campfire .

# Generate VAPID keys
docker run --rm campfire ./script/admin/create-vapid-key
```

This will output something like:
```
VAPID_PUBLIC_KEY=BExamplePublicKey123...
VAPID_PRIVATE_KEY=ExamplePrivateKey456...
```

**Save these keys** - you'll need them in Step 3.

## Step 2: Prepare Your Repository

Ensure all the configuration changes are committed and pushed to GitHub:

```bash
git add .
git commit -m "Configure Campfire for Render deployment with managed Redis"
git push origin main
```

Files that were added/modified:
- ✅ `render.yaml` (new)
- ✅ `config/initializers/resque.rb` (new)
- ✅ `config/cable.yml` (modified)
- ✅ `config/environments/production.rb` (modified)
- ✅ `bin/boot` (modified)

## Step 3: Create Render Services

### 3a. Connect Your Repository

1. Log in to [Render Dashboard](https://dashboard.render.com)
2. Click **"New"** → **"Blueprint"**
3. Connect your GitHub account if you haven't already
4. Select your forked `campfire` repository
5. Render will detect the `render.yaml` file

### 3b. Review and Configure

Render will show the services defined in `render.yaml`:
- **campfire** (Web Service)
- **campfire-redis** (Redis)

Before deploying, you need to set the VAPID keys:

1. Find the **campfire** web service in the list
2. Click on **"Environment Variables"** or edit the service
3. Add the VAPID keys you generated in Step 1:
   - `VAPID_PUBLIC_KEY`: Paste your public key
   - `VAPID_PRIVATE_KEY`: Paste your private key

**Note:** `SECRET_KEY_BASE` and `REDIS_URL` are automatically generated/injected by Render.

### 3c. Deploy

1. Click **"Apply"** to create the services
2. Render will start building your Docker image
3. This may take 5-10 minutes for the first build

## Step 4: Monitor Deployment

### Watch the Build Logs

1. Click on the **campfire** web service
2. Go to **"Logs"** tab
3. You should see:
   - Docker image building
   - Dependencies installing
   - Rails starting up
   - Health check passing

### Expected Log Output

```
==> Building Dockerfile
==> Deploying...
==> Starting service...
==> Running: bin/boot
Starting process: web
Starting process: workers
==> Health check passed
==> Deploy succeeded
```

## Step 5: Access Your Application

Once deployed:

1. Find your app URL in the Render dashboard (e.g., `https://campfire-xyz.onrender.com`)
2. Open the URL in your browser
3. You'll be greeted with the **admin account setup page**
4. Create your admin account:
   - Enter email address
   - Set password
   - This email will be shown on the login page for password recovery

## Step 6: Verify Deployment

Test the following features to ensure everything works:

- [ ] **Login**: Sign in with your admin account
- [ ] **Create a room**: Create a new chat room
- [ ] **Send messages**: Send a few messages in the room
- [ ] **Real-time updates**: Open the room in two browser windows, verify messages appear in real-time
- [ ] **File uploads**: Upload an image or file, verify it's stored and displayed
- [ ] **Background jobs**: Check that async tasks work (notifications, etc.)
- [ ] **Restart persistence**: In Render dashboard, manually restart the service and verify data persists

### Check Health Endpoint

Visit `https://your-app.onrender.com/up` - should return:
```
OK
```

## Step 7: Configure Custom Domain (Optional)

To use your own domain instead of `*.onrender.com`:

1. Go to **campfire** service in Render dashboard
2. Click **"Settings"** → **"Custom Domain"**
3. Add your domain (e.g., `chat.yourcompany.com`)
4. Update your DNS records with the values Render provides
5. Render will automatically provision an SSL certificate via Let's Encrypt

## Troubleshooting

### Build Fails

- Check the build logs in Render dashboard
- Verify `render.yaml` syntax is correct
- Ensure your repository is up to date

### Application Won't Start

- Check the deployment logs
- Verify environment variables are set correctly
- Ensure `VAPID_PUBLIC_KEY` and `VAPID_PRIVATE_KEY` are set

### Database Errors

- Verify persistent disk is mounted at `/rails/storage`
- Check disk usage in Render dashboard
- Initial deploy runs `bin/rails db:prepare` automatically

### Redis Connection Errors

- Verify Redis service is running (check `campfire-redis` service)
- Ensure `REDIS_URL` is being injected from the Redis service
- Check Redis service logs

### WebSocket/Real-time Features Not Working

- Verify ActionCable is using the correct Redis URL
- Check browser console for WebSocket connection errors
- Ensure Render plan supports WebSocket connections (all plans do)

## Scaling

### Vertical Scaling (More Resources)

Upgrade your Render plan for more CPU/RAM:
- **Standard**: 2GB RAM, 1 CPU ($25/mo)
- **Pro**: 4GB RAM, 2 CPU ($85/mo)
- **Pro Plus**: 8GB RAM, 4 CPU ($185/mo)

### Horizontal Scaling

**Note:** Campfire with SQLite doesn't support multiple instances (shared database requirement). To scale horizontally:

1. Migrate to PostgreSQL (Render provides managed PostgreSQL)
2. Update `config/database.yml` to use PostgreSQL in production
3. Add PostgreSQL service to `render.yaml`
4. Scale to multiple web service instances

### Storage Scaling

Increase persistent disk size:
1. Go to **campfire** service → **"Disks"**
2. Edit `campfire-storage` disk
3. Increase size (cannot be decreased later)
4. Render will expand the disk automatically

## Backup Strategy

### Database Backups

SQLite database is at `/rails/storage/db/production.sqlite3`

**Manual backup:**
```bash
# SSH into the service (if using Render Shell)
cp /rails/storage/db/production.sqlite3 /tmp/backup.sqlite3

# Or implement automated backups via a scheduled job
```

**Recommended:** Implement a Resque job that:
1. Creates SQLite backup: `.backup` command
2. Uploads to S3/Backblaze B2
3. Runs daily via cron or Render Cron Jobs

### File Storage Backups

Files are at `/rails/storage/files/`

Consider:
- Mirroring to cloud storage (S3, GCS)
- Regular disk snapshots
- Implementing ActiveStorage with cloud provider

## Cost Overview

Based on Render pricing:

| Service | Plan | Cost |
|---------|------|------|
| Web Service | Standard (2GB RAM) | $25/month |
| Redis | Starter (25MB) | $10/month |
| Persistent Disk | 10GB | $1/month |
| **Total** | | **$36/month** |

**Free tier:** Render offers a free tier for web services (with limitations) if you want to test first.

## Next Steps

1. ✅ **Invite users**: Share your Campfire URL with your team
2. ✅ **Create rooms**: Set up public and private chat rooms
3. ✅ **Configure notifications**: Test Web Push notifications
4. ✅ **Set up monitoring**: Add Sentry DSN for error tracking (optional)
5. ✅ **Plan backups**: Implement backup strategy for database and files
6. ✅ **Custom domain**: Configure your own domain (optional)

## Support

- **Render Docs**: https://render.com/docs
- **Campfire Issues**: https://github.com/basecamp/campfire/issues
- **Your fork**: https://github.com/YOUR_USERNAME/campfire/issues

Enjoy your self-hosted Campfire chat! 🔥
