#!/usr/bin/env python3

import argparse
import json
from truenas_api_client import Client


def get_client(url, insecure):
  return Client(uri=url, verify_ssl=not insecure)


def main():
  parser = argparse.ArgumentParser(description="Manage TrueNAS ZFS pools")
  parser.add_argument("--url", required=True, help="WebSocket URL")
  parser.add_argument("--username", required=True)
  parser.add_argument("--password", required=True)
  parser.add_argument("--insecure", action="store_true", help="Disable SSL verification")
  parser.add_argument("--pools", required=True, help="Path to JSON file containing pool definitions")
  args = parser.parse_args()

  with open(args.pools) as f:
    pool_definitions = json.load(f)

  with get_client(args.url, args.insecure) as c:
    c.call("auth.login", args.username, args.password)

    importable = c.call("pool.import_find", job=True)
    importable_by_name = {p["name"]: p for p in importable}

    existing = c.call("pool.query")
    existing_names = {p["name"] for p in existing}

    for pool in pool_definitions:
      name = pool["name"]

      if name in existing_names:
        print(f"Pool '{name}' is already imported, skipping.")
        continue

      if name in importable_by_name:
        guid = importable_by_name[name]["guid"]
        c.call("pool.import_pool", {"guid": guid}, job=True)
        print(f"Pool '{name}' imported successfully.")
      else:
        c.call("pool.create", pool, job=True)

if __name__ == "__main__":
    main()
