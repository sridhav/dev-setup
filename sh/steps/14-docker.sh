#!/usr/bin/env bash
# Docker. Linux: native Docker Engine from Docker's apt repo. macOS: Docker runs
# in a colima VM (installed in step 03).
. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/../lib.sh"
parse_flags "$@"

step "Docker"
if is_macos; then
  skip "Docker on macOS runs via colima (step 03). Start it with: colima start"
  exit 0
fi

if apt_installed docker-ce; then
  skip "Docker Engine"
else
  if apt_installed docker.io; then
    warn "Ubuntu's docker.io package is installed. Remove it first (sudo apt-get remove docker.io), then re-run."
    exit 1
  fi
  info "adding Docker's apt repository"
  # Linux Mint sets UBUNTU_CODENAME to the Ubuntu release it's built on.
  codename="$(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}")"
  run as_root install -m 0755 -d /etc/apt/keyrings
  run as_root curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  run as_root chmod a+r /etc/apt/keyrings/docker.asc
  run as_root sh -c "printf '%s\n' 'Types: deb' 'URIs: https://download.docker.com/linux/ubuntu' 'Suites: $codename' 'Components: stable' 'Signed-By: /etc/apt/keyrings/docker.asc' > /etc/apt/sources.list.d/docker.sources"
  run as_root apt-get update
  run as_root env DEBIAN_FRONTEND=noninteractive apt-get install -y \
    docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  ok "Docker Engine"
fi

# Start now and at boot (skipped where there's no systemd, e.g. containers).
if command -v systemctl >/dev/null 2>&1 && [[ -d /run/systemd/system ]]; then
  if systemctl is-enabled --quiet docker 2>/dev/null; then skip "docker service enabled"; else run as_root systemctl enable --now docker; ok "docker service enabled"; fi
fi

# Lets you run docker without sudo. Takes effect at next login.
if id -nG "$USER" | tr ' ' '\n' | grep -qx docker; then
  skip "$USER in docker group"
else
  run as_root usermod -aG docker "$USER"
  ok "$USER added to docker group (log out and back in to use docker without sudo)"
fi
