#!/usr/bin/env bash
set -euo pipefail

echo "==> Installing base development tools"

# --- System packages via rpm-ostree (requires reboot to take effect) ---
# Batched into one call to avoid multiple pending deployments
rpm-ostree install --idempotent \
  postgresql \
  htop \
  neovim \
  jq \
  tree \
  unzip \
  zip \
  net-tools
echo "NOTE: rpm-ostree packages (psql, htop, neovim, etc.) will be available after next reboot."

# --- gh CLI (binary install — no rpm-ostree reboot needed) ---
if ! command -v gh >/dev/null 2>&1; then
  # Follow the releases/latest redirect to get the version tag, no jq needed
  GH_VERSION=$(curl -fsSLI -o /dev/null -w '%{url_effective}' \
    https://github.com/cli/cli/releases/latest | sed 's|.*/tag/v||')
  TMPDIR=$(mktemp -d)
  curl -fsSL "https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz" \
    | tar xz -C "$TMPDIR"
  sudo install -m 0755 "$TMPDIR/gh_${GH_VERSION}_linux_amd64/bin/gh" /usr/local/bin/gh
  rm -rf "$TMPDIR"
  echo "gh ${GH_VERSION} installed."
else
  echo "gh $(gh --version | head -1) already installed, skipping."
fi

# --- .NET 9 (user install — no rpm-ostree reboot needed) ---
DOTNET_ROOT="${DOTNET_ROOT:-$HOME/.dotnet}"
if [[ ! -x "$DOTNET_ROOT/dotnet" ]]; then
  curl -fsSL https://dot.net/v1/dotnet-install.sh | bash -s -- --channel 9.0 --install-dir "$DOTNET_ROOT"
else
  echo ".NET $("$DOTNET_ROOT/dotnet" --version) already installed, skipping."
fi

# Export for this session so sqlpackage install below can find dotnet
export DOTNET_ROOT
export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"

# Persist to shell config (idempotent)
DOTNET_EXPORT='export DOTNET_ROOT="$HOME/.dotnet" && export PATH="$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools"'
grep -qF 'DOTNET_ROOT' ~/.bashrc || echo "$DOTNET_EXPORT" >> ~/.bashrc

# sqlpackage
if ! dotnet tool list -g 2>/dev/null | grep -qi 'sqlpackage'; then
  dotnet tool install -g microsoft.sqlpackage
else
  echo "sqlpackage already installed, skipping."
fi

# --- nvm + Node LTS ---
NVM_DIR="${NVM_DIR:-$HOME/.nvm}"
if [[ ! -d "$NVM_DIR" ]]; then
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
fi

export NVM_DIR
set +u
# shellcheck disable=SC1091
\. "$NVM_DIR/nvm.sh"
if ! nvm ls lts/* &>/dev/null; then
  nvm install --lts
fi
nvm use --lts
set -u

echo "10-dev-base complete"
