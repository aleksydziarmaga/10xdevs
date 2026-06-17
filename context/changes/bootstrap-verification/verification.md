---
bootstrapped_at: 2026-06-17T20:27:06Z
starter_id: 10x-astro-starter
starter_name: 10x Astro Starter (Astro + Supabase + Cloudflare)
project_name: home-wallet
language_family: js
package_manager: npm
cwd_strategy: git-clone
bootstrapper_confidence: first-class
phase_3_status: ok
audit_command: "npm audit --json"
---

## Hand-off

**Starter:** 10x-astro-starter — 10x Astro Starter (Astro + Supabase + Cloudflare)
**Project name:** home-wallet
**Package manager:** npm
**Language:** js
**Confidence:** first-class
**Path taken:** standard
**Deployment target:** cloudflare-pages
**Feature flags:** none

### Why this stack

HomeWallet is a small, after-hours web MVP with a short three-week timeline, so a convention-first starter that already aligns frontend, data, and deployment is the safest path. 10x Astro Starter fits this profile with TypeScript across the project, built-in database and auth capabilities through Supabase, and a straightforward Cloudflare-first deployment path. The setup keeps early implementation focused on budgeting workflows instead of stack assembly, while still allowing growth into richer features later. GitHub Actions with auto-deploy on merge matches a fast solo delivery loop.

## Pre-scaffold verification

| Signal             | Value                              | Severity | Notes                              |
| ------------------ | ---------------------------------- | -------- | ---------------------------------- |
| npm package        | create-astro v5.0.6 published 2026-04-22 | fresh | resolved from cmd_template         |
| GitHub repo        | prepared with git-clone strategy   | fresh    | github.com/przeprogramowani/10x-astro-starter |

## Scaffold log

**Resolved invocation**: `git clone https://github.com/przeprogramowani/10x-astro-starter .bootstrap-scaffold && cd .bootstrap-scaffold && npm install`

**Strategy**: git-clone

**Exit code**: 0

**Files moved**: 18

**Conflicts (.scaffold siblings)**: .github

**.gitignore handling**: append-merged

**.bootstrap-scaffold cleanup**: deleted

## Post-scaffold audit

**Tool**: `npm audit --json`

**Summary**: 0 CRITICAL, 4 HIGH, 11 MODERATE, 3 LOW

**Direct vs transitive**: not distinguished by npm audit

### CRITICAL findings

None.

### HIGH findings

- **Package**: astro
  **Severity**: HIGH
  **Advisory**: Reflected XSS via unescaped slot name
  **Status**: Upstream fix pending or available in newer version

- **Package**: devalue
  **Severity**: HIGH
  **Advisory**: DoS via sparse array deserialization
  **Status**: Upstream fix pending or available in newer version

- **Package**: vite
  **Severity**: HIGH
  **Advisory**: NTLMv2 hash disclosure via UNC path handling on Windows
  **Status**: Windows-specific; low risk for typical deployments

- **Package**: ws
  **Severity**: HIGH
  **Advisory**: Uninitialized memory disclosure
  **Status**: Upstream fix pending or available in newer version

### MODERATE findings

11 MODERATE severity findings detected. Most relate to transitive dependencies and may be addressed by upstream package updates. Review with `npm audit` for the full list.

### LOW / INFO findings

3 LOW severity findings detected. Typically non-critical and safe to defer.

## Hints recorded but not acted on

| Hint                       | Value                              |
| -------------------------- | ---------------------------------- |
| bootstrapper_confidence    | first-class                        |
| quality_override           | false                              |
| path_taken                 | standard                           |
| self_check_answers         | null                               |
| team_size                  | solo                               |
| deployment_target          | cloudflare-pages                   |
| ci_provider                | github-actions                     |
| ci_default_flow            | auto-deploy-on-merge               |
| has_auth                   | false                              |
| has_payments               | false                              |
| has_realtime               | false                              |
| has_ai                     | false                              |
| has_background_jobs        | false                              |

## Next steps

Your project is scaffolded and verified — happy hacking.

Useful manual steps in the meantime:
- `git init` (if you have not already) to start your own repo history.
- Review `.github.scaffold` (conflict from existing .github/) and decide which version to keep or merge.
- Address HIGH audit findings per your project's risk tolerance — the 4 HIGH vulnerabilities above should be monitored for upstream fixes.
- A future skill will set up agent context (CLAUDE.md, AGENTS.md).
