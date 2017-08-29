#!/bin/bash

set -eu

current_hash() {
  CURRENT_GIT_HASH="$(git rev-parse HEAD)"

  cat <<EOF > current_git_hash.tf.json
{
  "variable": {
    "current_git_hash": {
      "value": "$CURRENT_GIT_HASH"
    }
  }
}
EOF
}

# Execute only for commands `plan` and `apply`
case "$TF_COMMAND" in
  plan|apply)
    current_hash
    ;;
  *)
    ;;
esac
