#!/usr/bin/env bash
set -euo pipefail

# Usage: ci-find-changed-exercises.sh [base-ref]
# If base-ref is not provided, defaults to origin/main

BASE_REF=${1:-origin/main}

# Ensure we have the base branch fetched
git fetch origin +refs/heads/*:refs/remotes/origin/* || true

# Compute changed files between base ref and HEAD
CHANGED_FILES=$(git diff --name-only $BASE_REF...HEAD || true)

EXERCISES=()
while IFS= read -r line; do
  # Normalize path
  case "$line" in
    exercises/*|tests/*|solutions/*)
      # Extract the exercise directory name (e.g. exercises/exercise-001-intro/...)
      # We want exercise-001-intro
      # For path like tests/exercise-001-intro/request-0001.json -> exercise-001-intro
      EX=$(echo "$line" | cut -d'/' -f2)
      if [[ ! " ${EXERCISES[*]} " =~ " ${EX} " ]]; then
        EXERCISES+=("$EX")
      fi
      ;;
    *)
      ;;
  esac
done <<< "$CHANGED_FILES"

# Join by comma for easy CLI usage
if [ ${#EXERCISES[@]} -eq 0 ]; then
  echo ""
  exit 0
fi
(IFS=","; echo "${EXERCISES[*]}")
