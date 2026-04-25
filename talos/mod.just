set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export SOPS_AGE_KEY := `bw get item sops-age-talos | yq -e '.fields[] | select(.name == "private-key").value'`
export SOPS_AGE_RECIPIENTS := `bw get item sops-age-talos | yq -e '.fields[] | select(.name == "public-key").value'`

[private]
default: gen-installer-image apply-config talosconfig kubeconfig

# Create installer image
[arg("version", help="Talos linux version")]
gen-installer-image version = "1.12.6":
  export SCHEMATIC_ID="$(curl -sX POST --data-binary @schematic.yaml https://factory.talos.dev/schematics | yq -r '.id')"; \
    yq -n '.machine.install.image = "'factory.talos.dev/metal-installer-secureboot/${SCHEMATIC_ID}:v{{ version }}'"' > all/02-image.yaml

# Apply talos machine configs
apply-config:
  topf apply --confirm=false --auto-bootstrap=true --allow-not-ready=true

# Create kubeconfig
kubeconfig:
  topf kubeconfig --validity=8760h > {{ justfile_dir() }}/kubeconfig

# Create talosconfig
talosconfig:
  topf talosconfig > {{ justfile_dir() }}/kubeconfig

# Reset nodes
reset-nodes:
  topf reset --full=false --wait-for-maintenance=true
