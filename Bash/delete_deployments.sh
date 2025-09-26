#!/usr/bin/env bash
set -euo pipefail

OWNER="MathisTRD"
REPO="LetsGoDeeperV2"
ENVIRONMENT=""   # optional, set to e.g. "production" or leave empty

command -v gh >/dev/null || { echo "Missing: gh"; exit 1; }
command -v jq >/dev/null || { echo "Missing: jq"; exit 1; }

base="repos/$OWNER/$REPO/deployments"
params="per_page=100"

if [[ -n "$ENVIRONMENT" ]]; then
  env_q=$(printf '%s' "$ENVIRONMENT" | jq -s -R -r '@uri')
  params="${params}&environment=${env_q}"
fi

echo "Fetching deployments..."
deployments_json=$(gh api -H "Accept: application/vnd.github+json" "$base?$params" --paginate)

count=$(printf '%s' "$deployments_json" | jq 'length')
if [[ "$count" -eq 0 ]]; then
  echo "No deployments found."
  exit 0
fi

latest_id=$(printf '%s' "$deployments_json" | jq '.[0].id // empty')
if [[ -z "$latest_id" ]]; then
  echo "Could not determine latest deployment id."
  exit 1
fi
echo "Keeping latest deployment: $latest_id"

ids=$(printf '%s' "$deployments_json" | jq '.[].id' | tail -n +2 || true)
if [[ -z "${ids:-}" ]]; then
  echo "Only one deployment present—nothing to delete."
  exit 0
fi

while read -r id; do
  [[ -z "$id" ]] && continue
  echo "Deactivating $id..."
  gh api -H "Accept: application/vnd.github+json" \
    -X POST "$base/$id/statuses" -f state=inactive >/dev/null || true

  echo "Deleting $id..."
  if ! gh api -H "Accept: application/vnd.github+json" -X DELETE "$base/$id"; then
    echo "Failed to delete deployment $id"
  fi
done <<< "$ids"

echo "Done."
