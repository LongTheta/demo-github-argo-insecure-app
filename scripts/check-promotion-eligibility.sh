#!/usr/bin/env bash
# Read policy review artifacts and evaluate promotion eligibility.
# Mirrors the promotion_check job logic in CI.

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ARTIFACT_DIR="${REPO_ROOT}/artifacts"

VERDICT="UNKNOWN"
RISK="unknown"

if [ -f "$ARTIFACT_DIR/policy-summary.json" ]; then
  VERDICT=$(jq -r '.verdict // .policy_verdict // "UNKNOWN"' "$ARTIFACT_DIR/policy-summary.json")
  RISK=$(jq -r '.risk_level // .riskLevel // "unknown"' "$ARTIFACT_DIR/policy-summary.json" 2>/dev/null || echo "unknown")
fi
if [ -f "$ARTIFACT_DIR/review-result.json" ]; then
  VERDICT=$(jq -r '.verdict // .policy_verdict // .policyVerdict // "'"$VERDICT"'"' "$ARTIFACT_DIR/review-result.json")
  RISK=$(jq -r '.risk_level // .riskLevel // "'"$RISK"'"' "$ARTIFACT_DIR/review-result.json" 2>/dev/null || echo "$RISK")
fi

APPROVED=false
if [ "$VERDICT" = "PASS" ] || [ "$VERDICT" = "pass" ]; then
  APPROVED=true
elif [ "$VERDICT" = "PASS_WITH_WARNINGS" ] || [ "$VERDICT" = "pass_with_warnings" ]; then
  APPROVED=true
fi
if [ "$RISK" = "critical" ] || [ "$RISK" = "high" ]; then
  APPROVED=false
fi

echo ""
echo "=========================================="
echo "  Policy Verdict: $VERDICT"
echo "  Risk Score: $RISK"
echo "  Promotion Eligible: $([ "$APPROVED" = "true" ] && echo "Yes" || echo "No")"
echo "=========================================="
echo ""

if [ "$APPROVED" = "false" ]; then
  echo "Promotion BLOCKED. Fix policy violations before promoting to GitOps platform."
  exit 1
fi

echo "Promotion ALLOWED. Artifacts ready for GitOps platform handoff."
exit 0
