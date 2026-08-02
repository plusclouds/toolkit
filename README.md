# PlusClouds Toolkit

Shared, versioned repository of cross-platform automation scripts used across PlusClouds services (IAAS VM guest agent, S3 backup-agent/storaged, and any future consumer). Every release is a signed, checksummed GitHub Release — consumers pin to a specific tag, never to a branch.

## Layout

- `capabilities/<name>/{linux.yml, windows.ps1, macos.sh}` — the actual guest-facing operations (change password, change hostname, apply SSH keys, disk resize, etc.), one directory per capability, OS variants side by side so they get reviewed and versioned together instead of drifting apart.
- `capabilities/service-roles/<name>/linux.yml` — service roles (mysql, postgresql, tailscale, ...) a VM can opt into. Each directory's name is the catalog key `NextDeveloper/IAAS`'s `iaas_ansible_roles` table syncs against 1:1 — see `meta.yml` below and `AnsibleRolesService::syncFromToolkit()`.
- `capabilities/service-roles/<name>/meta.yml` — a one-line `description:` for that role, synced into `iaas_ansible_roles.description` by the same job. Required for every service role (not just cosmetic — the sync job reads it). Also carries `supported_os:`, the list of distro/version combinations the role's `linux.yml` has been written and tested against — keep it in sync with whatever `ansible_facts.os_family`/`ansible_facts.distribution` branches (or their absence) actually cover.
- `capabilities/service-roles/<name>/defaults.yml` — every `service_roles.<name>.config.*` key the role's `linux.yml` reads. Each key maps to `{default: ..., description: ...}`, synced verbatim into `iaas_ansible_roles.config` in that nested shape — the customer panel's service-role picker reads `config[key].default`/`config[key].description` straight off it, and `AnsibleRolesService::resolveForVirtualMachine()` flattens it to plain `{key: default}` before it ever reaches a VM. Optional (omit it for a role that takes no config), but keep it in lockstep with whatever `linux.yml` actually reads via `| default(...)` — this is the only way a customer can discover what to put in `service_roles.<name>.config` short of reading this repo.
- `agents/<agent>/` — bootstrap/installer material for a specific agent (install scripts, systemd units, config templates). Not a "capability" a customer triggers directly — this is what gets an agent running on a host in the first place.
- `manifest.json` — generated at release time by `scripts/generate-manifest.sh`: every file's sha256, so consumers can verify integrity before executing anything pulled from a release asset.

## Capabilities

Guest-facing operations, triggered directly against a running VM.

| Capability | Linux | Windows | What it does |
| --- | :---: | :---: | --- |
| `change-password` | ✅ | ✅ | Sets a local user's password, creating the account first if it doesn't exist. |
| `change-hostname` | ✅ | ✅ | Sets the guest's hostname. |
| `apply-ssh-keys` | ✅ | ✅ | Installs authorized SSH public keys for a user. |
| `apply-env-vars` | ✅ | ✅ | Writes system-wide environment variables. |
| `apply-locale` | ✅ | — | Installs and activates the `en_US.UTF-8` locale (Debian family). |
| `apply-configuration` | ✅ | ✅ | First-boot orchestrator: reads `pc-meta-data.json` and drives password, hostname, disk-resize, env vars, SSH keys, service deployment, and startup/post-boot scripts in one pass. |
| `disk-resize` | ✅ | — | Grows the root filesystem to fill the disk. Per-distro playbooks: Ubuntu 22.04/24.04, Debian 12, AlmaLinux. |
| `run-post-boot-script` / `run-startup-script` | ✅ | — | Runs a customer-supplied script once at first boot / on every boot. |
| `update` | ✅ | — | Updates all OS packages (Ubuntu, Debian, Fedora, CentOS, AlmaLinux, RedHat), with an optional reboot. |
| `client-monitoring` / `zabbix-client` | ✅ | — | Bootstraps the Zabbix agent with auto-registration. |

## Service roles

Optional daemons a VM can opt into via `service_roles.<name>.config` — see `capabilities/service-roles/<name>/defaults.yml` for each role's config keys. All Linux-only.

| Role | Description | Supported OS |
| --- | --- | --- |
| `mysql` | Installs and enables MySQL, optionally setting the root password. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `mariadb` | Installs and enables MariaDB, optionally setting the root password. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `postgresql` | Installs and configures PostgreSQL, optionally setting the superuser password. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `redis` | Installs and enables Redis, optionally setting a password and binding to all interfaces. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `nginx` | Installs and enables Nginx, optionally setting the default site's `server_name`. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `caddy` | Installs Caddy from its official repo, optionally configuring a domain with automatic HTTPS and a reverse-proxy target. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `traefik` | Installs Traefik as a systemd service from its official release binary, optionally enabling the dashboard and Let's Encrypt via ACME. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `docker` | Installs Docker Engine from its official repo, optionally adding users to the `docker` group. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `tailscale` | Installs Tailscale, optionally joining your tailnet automatically when an auth key is provided. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `fail2ban` | Installs and enables Fail2ban, optionally overriding the default ban time and retry threshold. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `ufw` | Installs and enables UFW, applying default incoming/outgoing policies and a port allowlist before enabling. | Ubuntu 22.04/24.04, Debian 12 (not packaged for RedHat family) |
| `grafana` | Installs and enables Grafana from its official repo, optionally setting the admin password and root URL. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `prometheus` | Installs Prometheus from its official release binary, optionally scraping extra targets and setting retention. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `alertmanager` | Installs Alertmanager from its official release binary, optionally routing alerts to a webhook. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `loki` | Installs Loki from its official release binary, using local filesystem storage. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `gitlab-runner` | Installs GitLab Runner from its official repo, optionally registering it against a GitLab instance. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `php-fpm` | Installs and enables PHP-FPM, optionally overriding memory_limit and upload_max_filesize. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `node_exporter` | Installs node_exporter from its official release binary, for Prometheus to scrape host metrics. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `alloy` | Installs Grafana Alloy from its official repo, shipping local log files to Loki (Promtail's supported replacement). | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `rabbitmq` | Installs and enables RabbitMQ, optionally enabling the management UI and creating an administrator user. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `mosquitto` | Installs and enables the Mosquitto MQTT broker, configuring its listener bind address and anonymous-access policy. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `nats-server` | Installs NATS Server from its official release binary, optionally enabling JetStream persistence. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `haproxy` | Installs and enables HAProxy, optionally load-balancing a frontend port across a list of backend servers. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `vault` | Installs and enables HashiCorp Vault from its official repo, with file storage and TLS disabled for internal-network use. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `minio` | Installs and enables MinIO object storage from its official package, configuring the data volume and console port. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `jenkins` | Installs and enables Jenkins from its official repo (plus its Java prerequisite), optionally changing the HTTP port. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `mongodb` | Installs and enables MongoDB Community Edition from its official repo, optionally binding to all interfaces. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `elasticsearch` | Installs and enables Elasticsearch from its official repo, applying the required vm.max_map_count sysctl. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `opensearch` | Installs and enables OpenSearch from its official repo, applying the required vm.max_map_count sysctl. Requires admin_password. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `influxdb` | Installs and enables InfluxDB 2.x from its official repo, optionally binding to all interfaces. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `coredns` | Installs CoreDNS from its official release binary, forwarding queries to configurable upstream resolvers. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `bind9` | Installs and enables BIND9 as a caching/forwarding DNS resolver, configuring upstream forwarders and the query allowlist. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `kafka` | Installs Apache Kafka (KRaft mode, no ZooKeeper) from its official release tarball, as a single combined broker+controller node. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |
| `keycloak` | Installs Keycloak from its official release tarball. Runs in dev mode unless db_url is set, which switches to optimized production mode. | Ubuntu 22.04/24.04, Debian 12, AlmaLinux |

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
