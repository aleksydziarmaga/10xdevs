---
starter_id: 10x-astro-starter
package_manager: npm
project_name: home-wallet
hints:
  language_family: js
  team_size: solo
  deployment_target: cloudflare-pages
  ci_provider: github-actions
  ci_default_flow: auto-deploy-on-merge
  bootstrapper_confidence: first-class
  path_taken: standard
  quality_override: false
  self_check_answers: null
  has_auth: false
  has_payments: false
  has_realtime: false
  has_ai: false
  has_background_jobs: false
---

## Why this stack

HomeWallet is a small, after-hours web MVP with a short three-week timeline, so a convention-first starter that already aligns frontend, data, and deployment is the safest path. 10x Astro Starter fits this profile with TypeScript across the project, built-in database and auth capabilities through Supabase, and a straightforward Cloudflare-first deployment path. The setup keeps early implementation focused on budgeting workflows instead of stack assembly, while still allowing growth into richer features later. GitHub Actions with auto-deploy on merge matches a fast solo delivery loop.
