set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export SOPS_AGE_KEY := `doppler secrets get SOPS_AGE_KEY --plain`
export SOPS_AGE_RECIPIENTS := `doppler secrets get SOPS_AGE_RECIPIENTS --plain`

[private]
default: apply-config talosconfig kubeconfig

# Apply talos machine configs
apply-config:
  SCHEMATIC_ID="$(curl -sX POST --data-binary @schematic.yaml https://factory.talos.dev/schematics | yq -r '.id')" \
    doppler run --mount secrets.yaml --mount-template secrets.yaml.tmpl -- \
    topf apply --confirm=false --auto-bootstrap=true --allow-not-ready=true

# Create kubeconfig
kubeconfig:
  if [ ! -f "{{ justfile_dir() }}/kubeconfig" ]; then \
    doppler run --mount secrets.yaml --mount-template secrets.yaml.tmpl -- \
    topf kubeconfig --validity=8760h > {{ justfile_dir() }}/kubeconfig; \
  fi

# Create talosconfig
talosconfig:
  if [ ! -f "{{ justfile_dir() }}/talosconfig" ]; then \
    doppler run --mount secrets.yaml --mount-template secrets.yaml.tmpl -- \
    topf talosconfig > {{ justfile_dir() }}/talosconfig; \
  fi

# Reset nodes
reset-nodes:
  doppler run --mount secrets.yaml --mount-template secrets.yaml.tmpl -- \
  topf reset --full=false --wait-for-maintenance=true
