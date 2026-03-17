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
  V=$(jq -r '.verdict // .policy_verdict // .policyVerdict // .result.verdict // "UNKNOWN"' "$ARTIFACT_DIR/policy-summary.json" 2>/dev/null)
  [ "$V" != "null" ] && [ -n "$V" ] && VERDICT="$V"
  R=$(jq -r '.risk_level // .riskLevel // .risk // "unknown"' "$ARTIFACT_DIR/policy-summary.json" 2>/dev/null)
  [ "$R" != "null" ] && [ -n "$R" ] && RISK="$R"
  if [ "$RISK" = "unknown" ] || [ "$RISK" = "null" ]; then
    CRIT=$(jq -r '.severity_counts.critical // 0' "$ARTIFACT_DIR/policy-summary.json" 2>/dev/null || echo 0)
    HIGH=$(jq -r '.severity_counts.high // 0' "$ARTIFACT_DIR/policy-summary.json" 2>/dev/null || echo 0)
    [ "${CRIT:-0}" -gt 0 ] && RISK="critical"
    [ "${HIGH:-0}" -gt 0 ] && [ "$RISK" = "unknown" ] && RISK="high"
  fi
fi
if [ -f "$ARTIFACT_DIR/review-result.json" ]; then
  V=$(jq -r '.verdict // .policy_verdict // .policyVerdict // .result.verdict // "'"$VERDICT"'"' "$ARTIFACT_DIR/review-result.json" 2>/dev/null)
  [ "$V" != "null" ] && [ -n "$V" ] && VERDICT="$V"
  R=$(jq -r '.risk_level // .riskLevel // .risk // "'"$RISK"'"' "$ARTIFACT_DIR/review-result.json" 2>/dev/null)
  [ "$R" != "null" ] && [ -n "$R" ] && RISK="$R"
fi
case "$VERDICT" in
  fail|FAIL) VERDICT="FAIL" ;;
  pass|PASS) VERDICT="PASS" ;;
  pass_with_warnings|PASS_WITH_WARNINGS) VERDICT="PASS_WITH_WARNINGS" ;;
esac

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
