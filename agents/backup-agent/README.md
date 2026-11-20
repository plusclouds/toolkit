# backup-agent (Stash)

Stash is the PlusClouds backup agent ([plusclouds/backup.agent](https://github.com/plusclouds/backup.agent)).

## Linux virtual machines

Stash is installed through the `stash` service role, not through a script in this directory: see `capabilities/service-roles/stash/`.

What the role does on each boot:

1. Downloads the `stash.linux` release pinned in the role to `/usr/local/bin/stash`, unless that exact build is already there. The download is verified against the SHA-256 pinned next to the version.
2. If the machine has no `/etc/plusclouds/stash.yaml` yet and the platform supplied a registration token, runs `stash register`. Registration writes the config and installs and starts the `stash` systemd unit.
3. Does nothing else on a machine that is already registered, apart from upgrading the binary when the pinned release changes.

A failure in the role never fails the boot playbook.

### Role config

| Key | Set by | Meaning |
| --- | --- | --- |
| `bucket` | customer | Name of the S3 bucket in their account to back up to. Empty = install only. |
| `registration_token` | platform | One-time, short-lived token created when the machine's metadata is built. Not a customer key, not listed in `defaults.yml`. |
| `register_endpoint` | platform | API base URL passed to `stash register --endpoint`. |

The platform resolves `bucket` inside the customer's own account and only then adds the token. The S3 secret never travels through the metadata: Stash receives it from the registration call.

### Moving to a newer Stash release

Change `stash_version` and `stash_sha256` together in `capabilities/service-roles/stash/linux.yml`, taking the checksum of `stash.linux` from the release page, then regenerate the manifest.

## Windows and macOS

Not covered yet. Stash is installed and registered by hand there (`stash register --endpoint <url> --token <token>`).
