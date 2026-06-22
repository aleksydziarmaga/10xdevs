# Deployment Plan for HomeWallet MVP
**Approved and finalized on 2026-06-22**

## Executive Summary
Deploy HomeWallet (Astro 6 SSR + Supabase) to Cloudflare Workers + Pages. Supports both manual CLI deployment (`wrangler deploy`) and automatic deployment on push to main via Cloudflare Pages native GitHub integration. Single production environment backed by the infrastructure decision documented in `context/foundation/infrastructure.md`.

---

## Deployment Architecture

| Component | Decision |
|-----------|----------|
| **Platform** | Cloudflare Workers + Pages (SSR adapter: `@astrojs/cloudflare@13.5.0`) |
| **Build** | `npm run build` → `dist/` directory |
| **Manual Deploy** | `npx wrangler deploy` (authenticated with Cloudflare account) |
| **Auto-Deploy** | Cloudflare Pages GitHub integration on push to main |
| **Environments** | Production only (main branch) |
| **Secrets** | Cloudflare Pages environment variables (SUPABASE_URL, SUPABASE_KEY) |
| **Observability** | Enabled in wrangler.jsonc; logs via `npx wrangler tail` |

---

## Pre-Deployment Checklist

### ✅ Local Setup & Verification
- [ ] **Node.js version**: Use v22.14.0 (specified in `.nvmrc`)
- [ ] **Dependencies installed**: `npm install` (already done)
- [ ] **Local build succeeds**: `npm run build` produces `dist/` with no errors
- [ ] **Preview works**: `npm run preview` starts and app is accessible locally
- [ ] **Supabase config**: `.env` file has `SUPABASE_URL` and `SUPABASE_KEY` (for local dev)

### ✅ Cloudflare Account & Project Setup
- [ ] **Cloudflare account**: Exists and verified
- [ ] **Wrangler CLI authenticated**: `wrangler login` succeeds
- [ ] **Cloudflare Pages project created**: Dashboard shows Pages project linked to this repo
- [ ] **Project name in wrangler.jsonc**: Matches Cloudflare Pages project name (currently: `10x-astro-starter`)

---

## Deployment Steps

### Phase 1: Manual Deployment (For First Deploy)

1. **Authenticate with Cloudflare**
   ```bash
   wrangler login
   ```
   Opens browser for OAuth. Confirm account and return to terminal.

2. **Configure Runtime Secrets**
   ```bash
   wrangler secret put SUPABASE_URL
   # Paste your Supabase project URL, then Ctrl+D
   
   wrangler secret put SUPABASE_KEY
   # Paste your Supabase anon key, then Ctrl+D
   ```
   Verify secrets were stored:
   ```bash
   wrangler secret list
   ```
   Output should show both `SUPABASE_URL` and `SUPABASE_KEY`.

3. **Build the Application**
   ```bash
   npm run build
   ```
   Confirms `dist/` directory is created with:
   - `.wrangler/` (build artifacts for Workers)
   - Static assets in `/`
   - No TS/lint errors

4. **Deploy to Production**
   ```bash
   npx wrangler deploy
   ```
   Output includes:
   - `Uploading...` with file count
   - Final URL: `https://<project-name>.<account-subdomain>.pages.dev`

5. **Verification**
   - Visit the deployed URL in browser
   - Test sign-in flow (verify Supabase auth works)
   - Check Network tab for 200 responses
   - Confirm no 500 errors in console

### Phase 2: Enable Cloudflare Pages Auto-Deploy

**One-time setup in Cloudflare Dashboard:**

1. Go to **Cloudflare Pages** → select project
2. **Settings** → **Git** tab
3. Verify GitHub repository is connected (should show `aleksydziarmaga/10xdevs`)
4. **Build settings**:
   - Build command: `npm run build`
   - Build output directory: `dist/`
   - Node.js version: `22.14.0`
5. **Environment variables**:
   - Add `SUPABASE_URL` = your Supabase project URL
   - Add `SUPABASE_KEY` = your Supabase anon key
6. **Deployments** → ensure **Auto-deploy** is enabled for the main branch
7. **Save** and wait for dashboard to confirm settings

**Verification:**
- Push a test commit to main branch
- Watch **Deployments** tab for build starting automatically
- Build should complete in ~2–3 minutes
- Verify new deployment is live (check timestamp)

---

## Rollback Procedure

### Code Rollback (Fast)
```bash
wrangler rollback
```
- Lists previous 10 deployments
- User selects which to restore
- Typically completes in seconds
- **Does NOT affect database** (schema/data remain unchanged)

### Database Rollback (Manual)
If a migration caused issues:
1. Identify which migration introduced the problem
2. Write backward-compatible migration (e.g., add column before removing another)
3. Test locally first
4. Deploy fix or revert code to before the problematic migration
5. Handle data cleanup/restoration via Supabase dashboard if needed

---

## Production Runbook

### Accessing Logs
```bash
wrangler tail --format pretty
```
- Real-time logs from all function invocations
- Includes errors, warnings, and console output
- Filter by status: `wrangler tail --status error`

### Checking Deployment Status
- **Dashboard**: https://dash.cloudflare.com → Pages → project
- **CLI**: `wrangler deployments list`

### Emergency Rollback
```bash
wrangler rollback --message "Emergency rollback due to X issue"
```
Specify a previous deployment ID to revert to immediately.

### Database Inspection
- **Supabase Dashboard**: https://app.supabase.com → select project
- Check `authentication`, `public` schema, and any custom tables for data anomalies
- Do NOT make destructive changes in dashboard (coordinate with team)

---

## Common Issues & Fixes

| Issue | Cause | Fix |
|-------|-------|-----|
| `Error: Unauthorized` during `wrangler login` | Not authenticated with Cloudflare | Run `wrangler logout` then `wrangler login` again |
| Build fails with `Node.js compatibility` | Dependency uses Node.js API incompatible with workerd | Add flag to `wrangler.jsonc`: `"compatibility_flags": ["nodejs_compat"]` (already set) |
| `SUPABASE_URL` is undefined in runtime | Secret not set in Cloudflare Pages env vars | Verify in Pages dashboard Settings → Environment variables |
| Deployment succeeds but app shows 404 | Build output directory is wrong | Check Pages build settings: output directory must be `dist/` |
| Auto-deploy not triggering on push | Repository not linked or branch mismatch | Verify GitHub repo is connected in Pages Settings → Git; check branch is `main` |

---

## Security & Permissions

- **Cloudflare Token**: Stored locally in `~/.wrangler/config.toml` (gitignored)
- **Supabase Keys**: Never commit `.env` file; use environment variables in Cloudflare Pages only
- **Who Can Deploy**: Anyone with `wrangler login` credentials to the Cloudflare account
- **Recommended**: Restrict deployments via Cloudflare Access or branch protection rules (out of scope for MVP)

---

## Success Criteria

✅ **Deploy is successful when:**
1. `wrangler deploy` exits with status 0
2. Deployed URL is accessible and returns 200 OK
3. Supabase authentication flows work (sign-up, sign-in, sign-out)
4. `wrangler tail` shows no error logs on home page load
5. Previous deployment can be restored via `wrangler rollback`

---

## Related Docs
- **Infrastructure decision**: `context/foundation/infrastructure.md`
- **Tech stack**: `context/foundation/tech-stack.md`
- **Wrangler config**: `wrangler.jsonc` (build command, compatibility settings)
- **Astro config**: `astro.config.mjs` (SSR adapter, environment schema)
- **Node.js version**: `.nvmrc` (locked to v22.14.0)

---

## Next Steps (Post-MVP)
- Add branch protection rule to main (require approval before auto-deploy)
- Set up Cloudflare Analytics for performance monitoring
- Create `context/deployment/manual-deploy.md` with team-specific runbook
- Configure `wrangler tail` to stream logs to external observability tool
- Plan multi-region failover strategy (currently out of scope)
