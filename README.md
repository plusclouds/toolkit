# PlusClouds Toolkit

Shared, versioned repository of cross-platform automation scripts used across PlusClouds services (IAAS VM guest agent, S3 backup-agent/storaged, and any future consumer). Every release is a signed, checksummed GitHub Release — consumers pin to a specific tag, never to a branch.

## Layout

- `capabilities/<name>/{linux.yml, windows.ps1, macos.sh}` — the actual guest-facing operations (change password, change hostname, apply SSH keys, disk resize, etc.), one directory per capability, OS variants side by side so they get reviewed and versioned together instead of drifting apart.
- `capabilities/service-roles/<name>/linux.yml` — service roles (mysql, postgresql, tailscale, ...) a VM can opt into. Each directory's name is the catalog key `NextDeveloper/IAAS`'s `iaas_ansible_roles` table syncs against 1:1 — see `meta.yml` below and `AnsibleRolesService::syncFromToolkit()`.
- `capabilities/service-roles/<name>/meta.yml` — a one-line `description:` for that role, synced into `iaas_ansible_roles.description` by the same job. Required for every service role (not just cosmetic — the sync job reads it).
- `capabilities/service-roles/<name>/defaults.yml` — every `service_roles.<name>.config.*` key the role's `linux.yml` reads, mapped to its default value, synced into `iaas_ansible_roles.config`. Optional (omit it for a role that takes no config), but keep it in lockstep with whatever `linux.yml` actually reads via `| default(...)` — this is the only way a customer can discover what to put in `service_roles.<name>.config` short of reading this repo.
- `agents/<agent>/` — bootstrap/installer material for a specific agent (install scripts, systemd units, config templates). Not a "capability" a customer triggers directly — this is what gets an agent running on a host in the first place.
- `manifest.json` — generated at release time by `scripts/generate-manifest.sh`: every file's sha256, so consumers can verify integrity before executing anything pulled from a release asset.

## Consuming this repo

Never fetch from a branch (`main`/`master`) at runtime. Pin to a release tag:

```
https://github.com/plusclouds/toolkit/releases/download/v1.0.0/toolkit-v1.0.0.tar.gz
https://github.com/plusclouds/toolkit/releases/download/v1.0.0/manifest.json
```

Verify each file you use against `manifest.json` before executing it.

## Origin

This repo consolidates:
- `NextDeveloper/IAAS`'s in-package `scripts/vm-service` and `scripts/windows-vm-service` (canonical source for capabilities that existed in both places — see `agents/vm-service` and the `capabilities/` linux/windows split)
- `plusclouds/vm-services` (superseded by this repo; a few capabilities here — e.g. `client-monitoring`, `zabbix-client` — only existed there)

`agents/backup-agent` and `agents/storaged` are placeholders for S3's backup-agent and storaged installers, which had no script infrastructure prior to this repo.
