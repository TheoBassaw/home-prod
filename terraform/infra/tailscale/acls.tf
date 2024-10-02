resource "tailscale_acl" "acl" {
  overwrite_existing_content = true

  acl = jsonencode({
    "tagOwners": {
      "tag:oci": [],
      "tag:nas": []
    }
    "acls": [
      {
        // Allow all users access to all ports.
        "action": "accept",
        "users": ["*"],
        "ports": ["*:*"],
      }
    ]
  })
}