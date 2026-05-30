# notifications

An Ansible playbook that deploys a self-hosted [ntfy](https://ntfy.sh) notification server behind [Caddy](https://caddyserver.com) on Ubuntu 26.04.

## Prerequisites

- An Ubuntu 26.04 Endpoint
- Preconfigured DNS A Record

## Setup

```sh
./setup.sh
```

This installs [uv](https://github.com/astral-sh/uv), sets up the Python environment, and installs Ansible Galaxy collections.

## Usage

```sh
uv run ansible-playbook playbook.yml -e domain=notifications.example.com
```

The `domain` variable defaults to `ntfy.example.com`. Override it with `-e` or in a host vars file.

## Post-Deployment

After the playbook completes, create an ntfy admin user on the target host:

```sh
sudo ntfy user add --role=admin <username>
```

## File Structure

```
playbook.yml              Main playbook
requirements.yml          Ansible Galaxy collections
setup.sh                  Environment setup script
templates/
  Caddyfile.j2            Caddy reverse proxy configuration
  server.yml.j2           ntfy server configuration
```
