# demo-github-argo-insecure-app

**An intentionally insecure GitHub Actions + Argo CD demo repository** for proving the [ai-devsecops-policy-enforcement-agent](https://github.com/LongTheta/ai-devsecops-policy-enforcement-agent) in a realistic CI/CD + GitOps workflow.

---

## What This Repo Is

A small, realistic demo application that:

- Uses **GitHub Actions** for CI/CD
- Deploys via **Argo CD** to Kubernetes
- Is **intentionally misconfigured** with policy violations
- Serves as a target for the enforcement agent to detect findings, generate verdicts, produce remediations, and demonstrate auto-fix

**This repo is for demonstration only — not production.**

---

## What Is Intentionally Wrong

### GitHub Actions (`.github/workflows/ci.yml`)

- Unpinned GitHub Actions (`actions/checkout@v4`, `docker/login-action@v3`, `docker/build-push-action@v6`)
- Container images using `latest` (`alpine:latest`, `bitnami/kubectl:latest`)
- No SBOM generation step
- No provenance/signing step
- Deploy job without `environment: production` or approval gate
- CI stages: Build (GHCR push) → Test (placeholder) → Deploy (kubectl dry-run validation)

### Kubernetes (`k8s/deployment.yaml`)

- Missing resource requests/limits
- Placeholder image `registry.example.com/demo-gitlab-argo-insecure-app:latest` (replaced at deploy time)
- Minimal labels/traceability metadata
- No `securityContext`

### Argo CD (`argo/application.yaml`)

- Automated sync enabled without safeguards
- `prune` and `selfHeal` enabled
- `targetRevision: HEAD` (no version pinning)
- Direct deployment pattern without promotion

### Dockerfile

- Base image uses `python:latest`

---

## What the Enforcement Agent Should Detect

| Category | Examples |
|----------|----------|
| Unpinned GitHub Actions | `actions/checkout@v3` → pin by full SHA |
| Unpinned container image | `alpine:latest`, `bitnami/kubectl:latest`, `python:latest` |
| Missing SBOM generation | No SBOM step in pipeline |
| Risky Argo sync | `prune: true`, `selfHeal: true` |
| Missing resource limits | No `resources.requests`/`limits` in Deployment |
| Plaintext/placeholder secrets | `API_KEY` in env |
| No promotion gate | Deploy without `environment: production` |

---

## Expected Outcome

- **Verdict:** FAIL or high-risk
- **Remediation suggestions** in `artifacts/remediations.json`
- **PR review comments** in `artifacts/comments.json` / `artifacts/github-comments.json`
- **Auto-fix suggestions** for pinning actions, images, adding resource limits, etc.

---

## How to Test with the Enforcement Agent

### Prerequisites

- Clone both repos as siblings (e.g. `Learning_Path/ai-devsecops-policy-enforcement-agent` and `Learning_Path/demo-github-argo-insecure-app`)
- Install the agent: `cd ai-devsecops-policy-enforcement-agent && pip install -e .`

### Full review

From this repo root:

```bash
python -m ai_devsecops_agent.cli review-all \
  --platform github \
  --pipeline .github/workflows/ci.yml \
  --gitops argo/application.yaml \
  --manifests k8s/deployment.yaml \
  --policy ../ai-devsecops-policy-enforcement-agent/policies/fedramp-moderate.yaml \
  --artifact-dir artifacts/
```

Or use the `review` command with full options:

```bash
python -m ai_devsecops_agent.cli review \
  --platform github \
  --pipeline .github/workflows/ci.yml \
  --gitops argo/application.yaml \
  --manifests k8s/deployment.yaml \
  --policy ../ai-devsecops-policy-enforcement-agent/policies/fedramp-moderate.yaml \
  --include-comments \
  --include-remediations \
  --artifact-dir artifacts/
```

### Auto-fix suggest

After running review (creates `artifacts/review-result.json`):

```bash
python -m ai_devsecops_agent.cli auto-fix \
  --input artifacts/review-result.json \
  --mode suggest
```

### Auto-fix patch (write to output dir)

```bash
python -m ai_devsecops_agent.cli auto-fix \
  --input artifacts/review-result.json \
  --mode patch \
  --output-dir artifacts/fixes
```

Inspect `artifacts/fixes/` for patched files.

### Quick local check script

```bash
./scripts/run-local-check.sh
```

On Windows (PowerShell):

```powershell
.\scripts\run-local-check.ps1
```

---

## Repository Structure

```
demo-github-argo-insecure-app/
├── README.md
├── .gitignore
├── Dockerfile
├── app/
│   ├── app.py
│   └── requirements.txt
├── .github/
│   └── workflows/
│       └── ci.yml
├── k8s/
│   ├── deployment.yaml
│   ├── service.yaml
│   └── namespace.yaml
├── argo/
│   └── application.yaml
├── docs/
│   ├── expected-findings.md
│   ├── expected-remediations.md
│   └── demo-flow.md
├── scripts/
│   ├── run-local-check.sh
│   └── run-local-check.ps1
├── examples/
│   └── expected-review-summary.md
└── artifacts/
    └── .gitkeep
```

---

## Run the App Locally

```bash
cd app
pip install -r requirements.txt
python app.py
```

Visit http://localhost:8080/ or http://localhost:8080/health

---

## Build Container

```bash
docker build -t demo-app:latest .
```

The CI workflow builds and pushes to GitHub Container Registry as `ghcr.io/<owner>/<repo>:latest`.

---

## Related Repositories

| Repository | Purpose |
|------------|---------|
| [ai-devsecops-policy-enforcement-agent](https://github.com/LongTheta/ai-devsecops-policy-enforcement-agent) | Policy enforcement engine |
| demo-gitlab-argo-insecure-app | GitLab CI + Argo CD variant |
| demo-supply-chain-broken-build | Supply chain policy demo |

---

## License

MIT (demo only)
