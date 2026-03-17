# Expected Review Summary

Example output when the **ai-devsecops-policy-enforcement-agent** reviews this demo repo with `fedramp-moderate` policy.

---

## Verdict

**FAIL** (or high-risk)

---

## Severity Breakdown (typical)

| Severity | Count | Examples |
|----------|-------|----------|
| Critical | 1 | Plaintext/placeholder secrets |
| High | 4–6 | Unpinned actions, unpinned images, missing SBOM, risky Argo sync, no promotion gate |
| Medium | 2–4 | Missing resource limits, no securityContext, deploy without environment |
| Low | 0–1 | Minimal labels |

---

## Sample Findings (abbreviated)

1. **Unpinned GitHub Actions** — `actions/checkout@v3`, `actions/setup-python@v4`; pin by full SHA
2. **Unpinned container image** — `demo-app:latest`, `python:latest`; pin by digest or tag
3. **Missing SBOM** — No SBOM generation step in pipeline
4. **Risky Argo sync** — `prune: true`, `selfHeal: true`; consider manual sync
5. **Missing resource limits** — Deployment has no `resources.requests`/`limits`
6. **Placeholder secrets** — `API_KEY` in env; use vault or managed secrets
7. **Deploy without environment** — No `environment: production` or approval gate

---

## Artifacts Produced

| File | Purpose |
|------|---------|
| `review-result.json` | Full review result; input for auto-fix |
| `policy-summary.json` | Verdict, severity counts, compliance summary |
| `report.md` | Human-readable Markdown report |
| `comments.json` | PR/MR review comments (generic) |
| `github-comments.json` | GitHub PR comment format |
| `remediations.json` | Step-by-step remediation suggestions |
| `workflow-status.json` | CI integration status |

---

## Auto-fix Suggestions (typical)

- Pin `actions/checkout@v3` → `actions/checkout@<full-40-char-sha>`
- Pin `actions/setup-python@v4` → `actions/setup-python@<full-40-char-sha>`
- Pin `demo-app:latest` → `demo-app@sha256:...` or `demo-app:v1.0.0`
- Add `resources.requests` and `resources.limits` to Deployment
- Add SBOM generation step to pipeline
- Disable `prune` and `selfHeal` in Argo Application
