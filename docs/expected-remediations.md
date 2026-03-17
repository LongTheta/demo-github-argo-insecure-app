# Expected Remediations

Remediation suggestions the **ai-devsecops-policy-enforcement-agent** should produce for this demo repository.

---

## GitHub Actions

### Pin actions by full SHA

```yaml
# Before
- uses: actions/checkout@v3

# After
- uses: actions/checkout@b4ffde65f46336ab88eb53be808477a3936bae11
```

### Pin container image

```yaml
# Before
docker build -t demo-app:latest .

# After
docker build -t demo-app:sha-$(git rev-parse --short HEAD) .
# Or use digest: demo-app@sha256:...
```

### Add SBOM generation step

```yaml
- name: Generate SBOM
  uses: anchore/sbom-action@v0.14.0
  with:
    image: demo-app:latest
    format: cyclonedx-json
```

### Add environment gate for deploy

```yaml
deploy:
  environment: production
  needs: build
  # ...
```

### Remove placeholder secrets

Use GitHub Secrets or a vault; never hardcode credentials.

---

## Kubernetes Deployment

### Add resource limits

```yaml
containers:
  - name: app
    resources:
      requests:
        memory: "64Mi"
        cpu: "100m"
      limits:
        memory: "256Mi"
        cpu: "500m"
```

### Pin image by digest or tag

```yaml
# Before
image: demo-app:latest

# After
image: demo-app:v1.2.3
# Or: image: demo-app@sha256:...
```

### Add securityContext

```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
    - securityContext:
        readOnlyRootFilesystem: true
        allowPrivilegeEscalation: false
```

---

## Argo CD Application

### Disable risky automated sync

```yaml
syncPolicy:
  automated:
    prune: false
    selfHeal: false
  syncOptions:
    - CreateNamespace=true
```

Or remove `syncPolicy.automated` entirely for manual sync.

### Pin targetRevision

```yaml
source:
  targetRevision: v1.2.3
  # Or: targetRevision: abc123def (commit SHA)
```

---

## Auto-fix Support

The enforcement agent's auto-fix engine can suggest or apply patches for:

- Pinning GitHub Actions by SHA
- Pinning container images
- Adding resource limits to Deployments
- Disabling risky Argo sync (prune/selfHeal)
- Adding SBOM generation step

Run `auto-fix --mode suggest` to see proposed changes without modifying files.
