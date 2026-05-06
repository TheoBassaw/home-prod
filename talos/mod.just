set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default: apply-config talosconfig kubeconfig

# Apply talos machine configs
apply-config:
  SCHEMATIC_ID="$(curl -sX POST --data-binary @schematic.yaml https://factory.talos.dev/schematics | yq -r '.id')" \
    topf apply --confirm=false --auto-bootstrap=true --allow-not-ready=true

# Create kubeconfig
kubeconfig:
  if [ ! -f "{{ justfile_dir() }}/kubeconfig" ]; then \
    topf kubeconfig --validity=8760h > {{ justfile_dir() }}/kubeconfig; \
  fi

# Create talosconfig
talosconfig:
  if [ ! -f "{{ justfile_dir() }}/talosconfig" ]; then \
    topf talosconfig > {{ justfile_dir() }}/talosconfig; \
  fi

# Reset nodes
reset-nodes:
  topf reset --full=false --wait-for-maintenance=true
