# Expected Findings

This document lists the policy violations the **ai-devsecops-policy-enforcement-agent** should detect when reviewing this demo repository.

---

## GitHub Actions (`.github/workflows/ci.yml`)

| Finding | Rule / ID | Why |
|--------|-----------|-----|
| Unpinned GitHub Actions | `github-001` | `actions/checkout@v3`, `actions/setup-python@v4` use tags instead of full commit SHA |
| Unpinned container image | `pipeline-002` | `demo-app:latest` and `python:latest` (in Dockerfile) use mutable tags |
| Missing SBOM generation | `require_sbom` | No step to generate Software Bill of Materials |
| Missing provenance/signing | `require_signed_artifacts` | No cosign or attestation step |
| Placeholder/plaintext secrets | `no_plaintext_secrets` | `API_KEY: "placeholder-key-for-demo"` in env |
| Overly broad permissions | Governance | `permissions: write-all` |
| Deploy without environment gate | `github-006` | Deploy job has no `environment: production` or approval |
| Minimal security checks | Supply chain | No dependency scan, no image scanning |

---

## Kubernetes (`k8s/deployment.yaml`)

| Finding | Rule / ID | Why |
|---------|-----------|-----|
| Image uses `latest` | `gitops-003` / `pipeline-002` | `image: demo-app:latest` |
| Missing resource requests/limits | `gitops-003` | No `resources.requests` or `resources.limits` |
| No securityContext | Security | No `runAsNonRoot`, `readOnlyRootFilesystem`, etc. |
| Minimal labels | Traceability | Missing version, git-sha, component metadata |

---

## Argo CD (`argo/application.yaml`)

| Finding | Rule / ID | Why |
|---------|-----------|-----|
| Automated sync with prune | `argo-001` / `gitops-001` | `prune: true` can delete resources unexpectedly |
| Automated sync with selfHeal | `argo-001` | `selfHeal: true` auto-reverts manual changes |
| targetRevision: HEAD | Governance | No version pinning; deploys latest commit |
| No manual promotion gate | `require_manual_promotion_gate` | Direct deploy without approval |
| Weak environment separation | Governance | Single application, no staging→prod promotion |

---

## Dockerfile

| Finding | Rule / ID | Why |
|---------|-----------|-----|
| Base image uses `latest` | `pipeline-002` | `FROM python:latest` |

---

## Severity Summary

- **Critical:** Plaintext/placeholder secrets
- **High:** Unpinned actions, unpinned images, missing SBOM, risky Argo sync, missing promotion gate
- **Medium:** Missing resource limits, no securityContext, deploy without environment

**Expected verdict:** FAIL or high-risk
