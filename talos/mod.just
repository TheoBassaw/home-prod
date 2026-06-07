set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

[private]
default: apply-config talosconfig kubeconfig

# Apply talos machine configs
apply-config:
  topf apply --confirm=false --auto-bootstrap=true --allow-not-ready=true --submit-to-factory

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
