set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod talos      "talos"
mod kubernetes "kubernetes"

oci_region      := "us-ashburn-1"
oci_profile     := "DEFAULT"
oci_auth_type   := "security_token"

[private]
default:
  just -l --list-submodules

# Bootstrap infrastructure
bootstrap:
  just talos
  just kubernetes

# Oracle Cloud Token Auth
[private]
oci-auth:
  #!/usr/bin/env bash
  set -euo pipefail

  if oci session validate --region "{{oci_region}}" --profile "{{oci_profile}}" --auth "{{oci_auth_type}}"; then
    echo "OCI session token re-authenticated or still valid"
  else
    echo "Validation failed — starting interactive browser authentication..."
    oci session authenticate --region "{{oci_region}}" --profile-name "{{oci_profile}}"
  fi

