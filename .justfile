set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod talos "talos"
mod kubernetes "kubernetes"

[private]
default:
  just -l --list-submodules

# Bootstrap infrastructure
bootstrap:
  doppler setup --no-interactive
  just talos
  just kubernetes
