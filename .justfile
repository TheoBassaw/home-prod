set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod talos "talos"
mod kubernetes "kubernetes"

[private]
default:
  just -l --list-submodules

bootstrap:
  just talos
  just kubernetes
