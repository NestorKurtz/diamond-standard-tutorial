#!/usr/bin/env bash
# install-security-tools.sh
# Installs and performs initial configuration of host-level security auditing tools.
# Run as root or with sudo.

set -euo pipefail

echo "==> Updating package index..."
apt-get update -qq

echo "==> Installing rkhunter, chkrootkit, and logwatch..."
apt-get install -y rkhunter chkrootkit logwatch

# ---------------------------------------------------------------------------
# rkhunter – rootkit / backdoor scanner
# ---------------------------------------------------------------------------
echo "==> Updating rkhunter file-property database..."
rkhunter --update || true      # update signature database (may fail offline)
rkhunter --propupd             # record current file properties as baseline

# ---------------------------------------------------------------------------
# chkrootkit – lightweight rootkit detector
# ---------------------------------------------------------------------------
echo "==> Running initial chkrootkit scan..."
chkrootkit || true             # exit code != 0 does not always mean infection

# ---------------------------------------------------------------------------
# logwatch – log analysis and reporting
# ---------------------------------------------------------------------------
echo "==> Verifying logwatch installation..."
logwatch --version

echo ""
echo "Security tools installed successfully."
echo "  rkhunter   – run: sudo rkhunter --check"
echo "  chkrootkit – run: sudo chkrootkit"
echo "  logwatch   – run: sudo logwatch --detail High --range today"
