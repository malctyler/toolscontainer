# Dockerfile — Azure CLI + kubectl + Git + Helm + Terraform + Python + PowerShell (Az) + Oh My Posh + Bash
FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# ----------------------------------------------------------
# 1) Base tools
# ----------------------------------------------------------
RUN apt-get update && apt-get install -y \
    ca-certificates curl gnupg apt-transport-https lsb-release \
    git bash-completion unzip fontconfig locales \
 && rm -rf /var/lib/apt/lists/* \
 && locale-gen en_US.UTF-8 \
 && update-locale LANG=en_US.UTF-8

ENV LANG=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8

# ----------------------------------------------------------
# 2) Azure CLI
# ----------------------------------------------------------
RUN mkdir -p /etc/apt/keyrings \
 && curl -fsSL https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor -o /etc/apt/keyrings/microsoft.gpg \
 && chmod 644 /etc/apt/keyrings/microsoft.gpg \
 && echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/azure-cli/ noble main" \
    > /etc/apt/sources.list.d/azure-cli.list \
 && apt-get update && apt-get install -y azure-cli \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------
# 3) kubectl (latest stable)
# ----------------------------------------------------------
RUN set -eux; \
  KUBECTL_VERSION="$(curl -L -s https://dl.k8s.io/release/stable.txt)"; \
  curl -L -o /usr/local/bin/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"; \
  chmod +x /usr/local/bin/kubectl

# ----------------------------------------------------------
# 4) Helm
# ----------------------------------------------------------
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ----------------------------------------------------------
# 5) Terraform
# ----------------------------------------------------------
RUN curl -fsSL https://apt.releases.hashicorp.com/gpg \
    | gpg --dearmor -o /etc/apt/keyrings/hashicorp-archive-keyring.gpg \
 && chmod 644 /etc/apt/keyrings/hashicorp-archive-keyring.gpg \
 && echo "deb [signed-by=/etc/apt/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com noble main" \
    > /etc/apt/sources.list.d/hashicorp.list \
 && apt-get update && apt-get install -y terraform \
 && terraform -install-autocomplete \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------
# 6) Python 3 + pip + venv (+ symlinks)
# ----------------------------------------------------------
RUN apt-get update && apt-get install -y \
    python3 python3-pip python3-venv \
 && ln -sf /usr/bin/python3 /usr/bin/python \
 && ln -sf /usr/bin/pip3 /usr/bin/pip \
 && rm -rf /var/lib/apt/lists/*

# ----------------------------------------------------------
# 7) PowerShell (pwsh) + Az modules
# ----------------------------------------------------------
RUN set -eux; \
  curl -fsSL -o /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb; \
  dpkg -i /tmp/packages-microsoft-prod.deb; \
  rm -f /tmp/packages-microsoft-prod.deb; \
  apt-get update; \
  apt-get install -y powershell; \
  rm -rf /var/lib/apt/lists/*
RUN pwsh -NoLogo -NoProfile -Command \
  "Set-PSRepository -Name PSGallery -InstallationPolicy Trusted; \
   Install-PackageProvider -Name NuGet -Force; \
   Install-Module -Name Az -Repository PSGallery -Scope AllUsers -Force -AllowClobber"

# ----------------------------------------------------------
# 8) Oh My Posh (latest release)
# ----------------------------------------------------------
RUN curl -fsSL https://ohmyposh.dev/install.sh | bash -s -- -d /usr/local/bin \
 && mkdir -p /etc/ohmyposh/themes \
 && curl -fsSL -o /etc/ohmyposh/themes/blue-owl.omp.json https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/blue-owl.omp.json

# ----------------------------------------------------------
# 9) Non-root user (fixed quoting)
# ----------------------------------------------------------
ARG USERNAME=dev
ARG UID=1000
ARG GID=1000
RUN set -eux; \
    groupadd -g ${GID} ${USERNAME} 2>/dev/null || true; \
    if getent passwd | awk -F: -v id=${UID} '$3==id {found=1} END{exit !found}'; then \
        useradd -m -s /bin/bash -g ${GID} ${USERNAME}; \
    else \
        useradd -m -s /bin/bash -u ${UID} -g ${GID} ${USERNAME}; \
    fi

# ----------------------------------------------------------
# 10) Shell QoL + Oh My Posh prompt config
# ----------------------------------------------------------
USER $USERNAME
WORKDIR /home/$USERNAME

# Bash: enable completion and Oh My Posh
RUN echo 'source /usr/share/bash-completion/bash_completion' >> ~/.bashrc \
 && echo 'eval "$(oh-my-posh init bash --config /etc/ohmyposh/themes/blue-owl.omp.json)"' >> ~/.bashrc \
 && kubectl completion bash >> ~/.kubectl-completion \
 && echo 'source ~/.kubectl-completion' >> ~/.bashrc \
 && helm completion bash >> ~/.helm-completion \
 && echo 'source ~/.helm-completion' >> ~/.bashrc \
 && echo 'alias k=kubectl' >> ~/.bashrc \
 && echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

# PowerShell: configure Oh My Posh profile
RUN mkdir -p ~/.config/powershell \
 && echo 'oh-my-posh init pwsh --config "/etc/ohmyposh/themes/blue-owl.omp.json" | Invoke-Expression' >> ~/.config/powershell/Microsoft.PowerShell_profile.ps1

CMD ["/bin/bash"]
