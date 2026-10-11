set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

mod compute-cluster "compute-cluster"

[private]
default:
  just -l --list-submodules

# Bootstrap infrastructure
bootstrap:
  just compute-cluster talos
  just compute-cluster kubernetes
