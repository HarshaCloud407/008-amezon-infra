#!/bin/bash
set -euo pipefail

echo ">>> Adding Jenkins repo..."
# -f  : fail silently on server errors instead of saving an error page
# -s  : silent mode, no progress meter
# -S  : still show errors even in silent mode
# -L  : IMPORTANT — follow HTTP redirects (pkg.jenkins.io redirects to a CDN;
#       without this flag you save the redirect page instead of the repo file)
curl -fsSL -o /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo

echo ">>> Importing Jenkins GPG key..."
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

echo ">>> Refreshing package metadata..."
yum clean all
yum makecache

echo ">>> Installing Java, fontconfig, and Jenkins..."
yum install -y fontconfig java-17-openjdk jenkins

echo ">>> Verifying Jenkins package installed..."
rpm -q jenkins

# --- Resize disk from 20GB to 50GB ---
echo ">>> Resizing root volume..."
command -v growpart >/dev/null 2>&1 || yum install -y cloud-utils-growpart

growpart /dev/nvme0n1 4

lvextend -L +10G /dev/RootVG/rootVol
lvextend -L +10G /dev/mapper/RootVG-varVol
lvextend -l +100%FREE /dev/mapper/RootVG-varTmpVol

xfs_growfs /
xfs_growfs /var/tmp
xfs_growfs /var

echo ">>> Enabling and starting Jenkins..."
systemctl daemon-reload
systemctl enable jenkins
systemctl start jenkins

echo ">>> Jenkins status:"
systemctl status jenkins --no-pager