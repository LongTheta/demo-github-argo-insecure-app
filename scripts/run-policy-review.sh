#!/usr/bin/env bash
# Run policy review against this repo (mirrors CI workflow).
# Expects ai-devsecops-policy-enforcement-agent as sibling directory.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
AGENT_REPO="${REPO_ROOT}/../ai-devsecops-policy-enforcement-agent"
ARTIFACT_DIR="${REPO_ROOT}/artifacts"

if [ ! -d "$AGENT_REPO" ]; then
  echo "Error: ai-devsecops-policy-enforcement-agent not found at $AGENT_REPO"
  echo "Clone it as a sibling: git clone ... ai-devsecops-policy-enforcement-agent"
  exit 1
fi

cd "$REPO_ROOT"
mkdir -p "$ARTIFACT_DIR"

echo "Running policy review (CI-equivalent)..."
python -m ai_devsecops_agent.cli review-all \
  --platform github \
  --pipeline .github/workflows/ci.yml \
  --gitops argo/application.yaml \
  --manifests k8s/deployment.yaml \
  --policy "$AGENT_REPO/policies/fedramp-moderate.yaml" \
  --include-comments \
  --include-remediations \
  --include-risk-score \
  --artifact-dir "$ARTIFACT_DIR/" \
  || true

echo ""
echo "Artifacts written to $ARTIFACT_DIR/"
echo "Run check-promotion-eligibility.sh to evaluate promotion gate."
