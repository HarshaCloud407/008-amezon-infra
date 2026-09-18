#!/bin/bash
set -uo pipefail
# NOTE: intentionally NOT using -e — the disk resize steps near the end
# can legitimately "fail" (e.g. "no size change" if already at target size)
# and we don't want that to skip installing/starting Jenkins.

echo ">>> Adding Jenkins repo..."

curl -fsSL -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

echo ">>> Importing Jenkins GPG key..."
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo ">>> Refreshing package metadata..."
yum clean all
yum makecache

echo ">>> Installing Java 21, fontconfig, and Jenkins..."
# Current Jenkins releases require Java 21 or 25 — Java 17 will install fine
# but crash the service immediately at startup ("older than the minimum
# required version"). Use java-21-openjdk, not java-17-openjdk.
yum install -y fontconfig java-21-openjdk jenkins

echo ">>> Confirming Jenkins package is present..."
if ! rpm -q jenkins >/dev/null 2>&1; then
  echo "ERROR: Jenkins package failed to install. Stopping here."
  exit 1
fi

echo ">>> Ensuring Java 21 is the active 'java' alternative..."
JAVA21_PATH=$(alternatives --list 2>/dev/null | awk '/^java /{print $3}' | grep -i 'java-21' | head -n1)
if [ -z "$JAVA21_PATH" ]; then
  # Fall back to locating it directly if 'alternatives --list' output format differs
  JAVA21_PATH=$(find /usr/lib/jvm -maxdepth 1 -iname 'java-21-openjdk*' -exec sh -c 'echo "{}/bin/java"' \; | head -n1)
fi

if [ -n "$JAVA21_PATH" ] && [ -x "$JAVA21_PATH" ]; then
  alternatives --set java "$JAVA21_PATH" || echo "WARNING: could not auto-set java alternative, please run 'alternatives --config java' manually"
else
  echo "WARNING: could not locate java-21-openjdk binary automatically, please run 'alternatives --config java' manually"
fi

echo ">>> Active Java version:"
java -version

echo ">>> Ensuring correct ownership of Jenkins home..."
chown -R jenkins:jenkins /var/lib/jenkins

echo ">>> Enabling and starting Jenkins..."
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

sleep 10
systemctl status jenkins --no-pager || true

echo ">>> Resizing root volume (best-effort, won't block Jenkins)..."
command -v growpart >/dev/null 2>&1 || yum install -y cloud-utils-growpart

growpart /dev/nvme0n1 4 || echo "growpart: nothing to grow or already at target size, continuing"

lvextend -L +10G /dev/RootVG/rootVol || echo "rootVol: already sized, continuing"
lvextend -L +10G /dev/mapper/RootVG-varVol || echo "varVol: already sized, continuing"
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol || echo "varTmpVol: already sized, continuing"

xfs_growfs / || true
xfs_growfs /var/tmp || true
xfs_growfs /var || true

echo ">>> Final Jenkins status:"
systemctl status jenkins --no-pager

echo ">>> Listening ports check:"
ss -tulpn | grep 8080 || echo "WARNING: Jenkins is not listening on 8080 yet — check 'journalctl -u jenkins -n 100' if this persists"

echo ">>> Initial admin password (save this to log into Jenkins):"
cat /var/lib/jenkins/secrets/initialAdminPassword 2>/dev/null || echo "(not found yet — Jenkins may still be starting up, wait a bit and re-check)"
