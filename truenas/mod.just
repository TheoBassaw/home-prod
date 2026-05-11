set quiet := true
set shell := ['bash', '-euo', 'pipefail', '-c']

export SOPS_AGE_KEY := `doppler secrets get SOPS_AGE_KEY --plain`
export SOPS_AGE_RECIPIENTS := `doppler secrets get SOPS_AGE_RECIPIENTS --plain`
export TRUENAS_USERNAME := `doppler secrets get TRUENAS_USERNAME --plain`
export TRUENAS_PASSWORD := `doppler secrets get TRUENAS_PASSWORD --plain`

[private]
default: pool-setup

# Create or import pool
[arg('flags', pattern='--insecure')]
pool-setup *flags:
  python3 ./scripts/pool.py --url wss://truenas.paradisenetworkz.com/api/current \
    --username $(doppler secrets get TRUENAS_USERNAME --plain) \
    --password $(doppler secrets get TRUENAS_PASSWORD --plain) \
    --pools ./data/pools.json {{flags}}

bootstrap:
  just truenas::pool-setup --insecure
