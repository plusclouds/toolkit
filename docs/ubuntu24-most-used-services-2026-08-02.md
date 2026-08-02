# Most Used Tools & Services on Ubuntu 24.04 (2026)

Standalone catalog of the most commonly installed tools/services on Ubuntu
24.04, compiled from web research. Companion to
[`research-2026-08-02.md`](research-2026-08-02.md), which covers the same
ground but framed around scoping decisions for this repo's
`capabilities/service-roles/`. This file is the plain list.

## Desktop applications

| Tool | Category | Notes |
| --- | --- | --- |
| Firefox | Browser | Ships preinstalled |
| Brave | Browser | Privacy-first, blocks ads by default |
| Google Chrome | Browser | |
| LibreOffice | Office suite | Preinstalled, MS Office-compatible |
| VLC | Media player | Plays virtually any format |
| GIMP | Graphics/image editing | |
| Blender | 3D/animation | |
| Bitwarden | Password manager | |
| Visual Studio Code | Code editor | Largest extension ecosystem, native Wayland support |
| GDebi | .deb installer | Works around App Center's .deb install issues |

## Command-line / workstation dev tools

| Tool | Purpose |
| --- | --- |
| micro | Simple terminal text editor |
| Neovim | Full terminal-based IDE |
| tmux | Terminal multiplexer |
| htop | Interactive process/system monitor |
| fzf | Fuzzy finder |
| ripgrep | Fast recursive grep |
| bat | `cat` with syntax highlighting |
| eza | Modern `ls` replacement |
| build-essential, make, curl, ca-certificates, libssl-dev | Baseline compile/build toolchain |

One-line install for the CLI bundle:
```
sudo apt install micro neovim tmux htop fzf ripgrep bat eza -y
```

## Package managers / app stores

| Tool | Role |
| --- | --- |
| APT | Base system package manager, preinstalled |
| Snap | Preinstalled; Firefox and several Canonical-pushed apps ship as snaps |
| Flatpak | Third-party alternative, popular for sandboxed desktop apps |
| App Center | Ubuntu's newer unified GUI for snaps + debs |

## Server / sysadmin / security services

| Service | Purpose |
| --- | --- |
| htop | Process monitoring |
| Netdata | Real-time server health monitoring |
| Prometheus | Metrics collection, querying, long-term storage |
| UFW | Default deny-by-default firewall (Debian/Ubuntu) |
| Fail2ban | Auto-blocks IPs after repeated failed logins |
| AIDE | File-integrity hashing / intrusion detection |
| Lynis | Automated hardening/configuration-drift audits |
| OpenSCAP | Compliance scanning |
| unattended-upgrades | Automatic security-patch application |
| restic / duplicity | Encrypted, deduplicated backups |

## Server-side developer stack (containers, web, data)

| Service | Purpose |
| --- | --- |
| Docker Engine | Container runtime, de facto standard for local dev + CI |
| Podman | Daemonless, rootless container runtime, Docker CLI-compatible |
| containerd | Lower-level container runtime |
| Kubernetes / kubectl | Container orchestration (not in default repos) |
| Nginx | Web server / reverse proxy, lowest memory footprint |
| Caddy | Web server / reverse proxy with automatic HTTPS |
| Traefik | Cloud-native reverse proxy, auto-configures from the Docker socket |
| PostgreSQL | Relational database |
| MySQL / MariaDB | Relational database |
| Redis | In-memory cache / queue |
| Gitea | Lightweight self-hosted Git server |
| Coolify | Self-hosted, Heroku-like PaaS |
| Tailscale | Zero-config mesh VPN / remote access |

## Language runtime / version managers

| Tool | Scope |
| --- | --- |
| mise (formerly rtx) | Polyglot; 2026's default pick, replaces nvm/pyenv/rbenv/goenv/asdf |
| asdf | Polyglot, plugin-based, older |
| nvm | Node.js only |
| pyenv | Python only |
| rustup | Rust only |
| SDKMAN | JVM ecosystem |

## Sources

Same source set as `research-2026-08-02.md` — see that file for the full
annotated list of ~40 links used across both research passes.
