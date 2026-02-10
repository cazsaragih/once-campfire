# Campfire

## Workflow Rules
- Before committing, always run `bin/rubocop -a` to auto-fix lint offenses, then fix any remaining offenses manually
- After pushing, check CI status with `gh run watch` and if it fails, investigate and fix the failures
- Run `bin/rails test` before committing to catch regressions early

# Deployment Memory

## Railway Deployment (current)
- App deployed at: https://once-campfire-production.up.railway.app/
- Platform: Railway (Docker)
- Thruster (reverse proxy) causes 502 on Railway — bypassed in bin/boot when PORT is set
- Puma serves directly on Railway's PORT (set to 8080 in networking tab)
- Railway needs explicit port set in Networking tab for Docker services
- Volume mounted at `/rails/storage` for SQLite + uploads
- docker-entrypoint.sh runs as root to fix volume permissions, then drops to rails user via `su`
- `config.hosts.clear` needed in production.rb (Rails 7+ blocks unknown hosts; /up is exempt)

## Key env vars for Railway
- RAILS_ENV=production
- DISABLE_SSL=true
- WEB_CONCURRENCY=2 (prevents OOM from auto-detecting host CPUs)
- RESQUE_WORKERS=2 (same reason)
- SECRET_KEY_BASE (generate with openssl rand -hex 64)
- VAPID_PUBLIC_KEY / VAPID_PRIVATE_KEY (for push notifications)
- PORT set to 8080 in Railway Networking tab

## Call/Huddle Feature (LiveKit)
- Uses LiveKit (open-source WebRTC SFU) for audio calls
- Gem: `livekit-server-sdk ~> 0.8` (Ruby SDK for tokens/API)
- JS: `livekit-client` pinned via CDN in importmap
- LiveKit SDK API: `token.video_grant =` (not `add_grant`), `VideoGrant.new(roomJoin:, room:, canPublish:, canSubscribe:)`
- No `WebhookReceiver` in Ruby SDK — use `TokenVerifier` instead
- HuddleManager singleton in JS persists across Turbo navigations
- Call broadcasts piggyback on existing `room, :messages` Turbo Stream
- New env vars: LIVEKIT_API_KEY, LIVEKIT_API_SECRET, LIVEKIT_WS_URL, LIVEKIT_HTTP_URL
- Recommend LiveKit Cloud over self-hosting (Railway may not support UDP for media server)

## Lessons learned
- Railway volumes mount as root-owned empty dirs — need entrypoint to chown + mkdir
- EXPOSE in Dockerfile can mislead Railway's port routing
- Resque pool + Puma auto-scale to host CPU count — always cap on small containers
- `${{PORT}}` Railway variable reference syntax may not resolve reliably; prefer reading PORT directly in code
- Rails /up health check bypasses host authorization — can mask config.hosts issues
