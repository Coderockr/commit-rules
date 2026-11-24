#!/bin/sh
# Valida a mensagem de commit. Uso: conventional-commit.sh <arquivo-da-mensagem>
# Escopos: COMMIT_SCOPES (separados por |) ou .commit-scopes na raiz do repositório (um por linha).
types="build|chore|ci|docs|feat|fix|perf|refactor|revert|style|test"
unscoped_types="build|chore|ci|docs"

scopes=${COMMIT_SCOPES:-}
if [ -z "$scopes" ] && [ -f .commit-scopes ]; then
  scopes=$(grep -vE '^[[:space:]]*(#|$)' .commit-scopes | tr -d '[:blank:]' | paste -sd '|' -)
fi
if [ -z "$scopes" ]; then
  echo "No commit scopes defined: create .commit-scopes (one scope per line) or set COMMIT_SCOPES."
  exit 1
fi

message=$(grep -v '^#' "$1")
header=$(printf '%s\n' "$message" | head -n 1)

case "$header" in
  "Merge "*|"Revert "*|"fixup! "*|"squash! "*|"amend! "*) exit 0 ;;
esac

if ! printf '%s\n' "$header" | grep -qE "^($types)\(($scopes)\)!?: .+" &&
  ! printf '%s\n' "$header" | grep -qE "^($unscoped_types)!?: .+"; then
  echo "Invalid commit header: $header"
  echo "Expected: <type>(<scope>): <subject>"
  echo "Types: $types"
  echo "Scopes: $scopes (optional for $unscoped_types)"
  exit 1
fi

if [ -n "$(printf '%s\n' "$message" | sed -n 2p)" ]; then
  echo "Leave a blank line between the header and the body."
  exit 1
fi
