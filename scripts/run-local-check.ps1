# Run policy review against this demo repo using the enforcement agent.
# Expects ai-devsecops-policy-enforcement-agent as sibling directory.

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
$AgentRepo = Join-Path (Split-Path -Parent $RepoRoot) "ai-devsecops-policy-enforcement-agent"

if (-not (Test-Path $AgentRepo)) {
    Write-Error "ai-devsecops-policy-enforcement-agent not found at $AgentRepo"
    Write-Host "Clone it as a sibling: git clone ... ai-devsecops-policy-enforcement-agent"
    exit 1
}

Set-Location $RepoRoot
New-Item -ItemType Directory -Force -Path artifacts | Out-Null

Write-Host "Running policy review..."
python -m ai_devsecops_agent.cli review-all `
    --platform github `
    --pipeline .github/workflows/ci.yml `
    --gitops argo/application.yaml `
    --manifests k8s/deployment.yaml `
    --policy (Join-Path $AgentRepo "policies/fedramp-moderate.yaml") `
    --artifact-dir artifacts/

Write-Host ""
Write-Host "Artifacts written to artifacts/"
Write-Host "Run auto-fix suggest: python -m ai_devsecops_agent.cli auto-fix --input artifacts/review-result.json --mode suggest"
