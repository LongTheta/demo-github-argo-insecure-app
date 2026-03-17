#!/usr/bin/env bash
# Run policy review against this demo repo using the enforcement agent.
# Expects ai-devsecops-policy-enforcement-agent as sibling directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENT_REPO="${REPO_ROOT}/../ai-devsecops-policy-enforcement-agent"

if [ ! -d "$AGENT_REPO" ]; then
  echo "Error: ai-devsecops-policy-enforcement-agent not found at $AGENT_REPO"
  echo "Clone it as a sibling: git clone ... ai-devsecops-policy-enforcement-agent"
  exit 1
fi

cd "$REPO_ROOT"
mkdir -p artifacts

echo "Running policy review..."
python -m ai_devsecops_agent.cli review-all \
  --platform github \
  --pipeline .github/workflows/ci.yml \
  --gitops argo/application.yaml \
  --manifests k8s/deployment.yaml \
  --policy "$AGENT_REPO/policies/fedramp-moderate.yaml" \
  --artifact-dir artifacts/

echo ""
echo "Artifacts written to artifacts/"
echo "Run auto-fix suggest: python -m ai_devsecops_agent.cli auto-fix --input artifacts/review-result.json --mode suggest"
