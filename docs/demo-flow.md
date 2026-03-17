# Demo Flow (3–5 minutes)

A short, demo-friendly walkthrough for proving the **ai-devsecops-policy-enforcement-agent** against this repo.

---

## Prerequisites

- Python 3.10+
- `ai-devsecops-policy-enforcement-agent` installed (`pip install -e .` from that repo)
- This repo and the agent repo as siblings, e.g.:

```
Learning_Path/
├── ai-devsecops-policy-enforcement-agent/
└── demo-github-argo-insecure-app/
```

---

## Step 1 — Run review-all

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

Or from the agent repo:

```bash
cd ai-devsecops-policy-enforcement-agent
python -m ai_devsecops_agent.cli review-all \
  --platform github \
  --pipeline ../demo-github-argo-insecure-app/.github/workflows/ci.yml \
  --gitops ../demo-github-argo-insecure-app/argo/application.yaml \
  --manifests ../demo-github-argo-insecure-app/k8s/deployment.yaml \
  --policy policies/fedramp-moderate.yaml \
  --artifact-dir ../demo-github-argo-insecure-app/artifacts/
```

---

## Step 2 — Show findings

- **Console:** Markdown report with findings, severity, and verdict
- **Artifacts:** `artifacts/review-result.json`, `artifacts/policy-summary.json`, `artifacts/report.md`

Expected: **FAIL** or **high-risk** verdict with multiple critical/high findings.

---

## Step 3 — Show risk score

Open `artifacts/policy-summary.json`:

```json
{
  "verdict": "fail",
  "severity_counts": {
    "critical": 1,
    "high": 5,
    "medium": 3,
    "low": 0
  },
  ...
}
```

---

## Step 4 — Show PR comment output

```bash
python -m ai_devsecops_agent.cli comments \
  --platform github \
  --pipeline .github/workflows/ci.yml \
  --gitops argo/application.yaml \
  --manifests k8s/deployment.yaml \
  --policy ../ai-devsecops-policy-enforcement-agent/policies/fedramp-moderate.yaml \
  --format github \
  --out artifacts/github-comments.md
```

Or use `artifacts/comments.json` / `artifacts/github-comments.json` from the review run.

---

## Step 5 — Run auto-fix suggest

```bash
python -m ai_devsecops_agent.cli auto-fix \
  --input artifacts/review-result.json \
  --mode suggest
```

Shows proposed patches (no file changes).

---

## Step 6 — Show diff (patch mode)

```bash
python -m ai_devsecops_agent.cli auto-fix \
  --input artifacts/review-result.json \
  --mode patch \
  --output-dir artifacts/fixes
```

Inspect `artifacts/fixes/` for patched files. Compare with originals to show the diff.

---

## Talking Points

1. **Intentional violations** — This repo is built to fail policy checks.
2. **End-to-end** — CI (GitHub Actions) → GitOps (Argo CD) → K8s manifests.
3. **Actionable output** — Findings, remediations, PR comments, and auto-fix suggestions.
4. **Demo-friendly** — Runs in under 5 minutes with no external services.
