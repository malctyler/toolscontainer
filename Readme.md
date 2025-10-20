# 🧰 Kubernetes + Azure Dev Container Environment

<a href="vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/malctyler/toolscontainer">
  <img alt="Open in Dev Containers" src="https://img.shields.io/badge/Open%20in-Dev%20Containers-2ea44f?logo=visualstudiocode">
</a>
---

## 📦 Overview

This repository defines a full-featured **development container** that provides a ready-to-use Linux-based cloud engineering environment — ideal for working with **Azure**, **Kubernetes**, **Terraform**, and **PowerShell** tooling inside **Visual Studio Code**.

It’s based on Ubuntu 24.04 and can run on:

- 🪟 **Windows** (via WSL + Docker Desktop)  
- 💻 **macOS / Linux** (with Docker installed)  
- ☁️ **GitHub Codespaces** (optional cloud development)

---

## ⚙️ What’s Inside

| Tool | Description |
|------|--------------|
| 🧠 **Azure CLI** | Manage Azure resources via `az` |
| ☸️ **kubectl** | Kubernetes CLI (latest stable) |
| ⛵ **Helm 3** | Kubernetes package manager |
| 🌍 **Terraform** | Infrastructure as Code (HashiCorp) |
| 🐍 **Python 3** | Includes pip + venv |
| 💻 **PowerShell 7** | Cross-platform shell with Azure `Az` modules preinstalled |
| 💡 **Oh My Posh** | Beautiful shell theming (Bash + PowerShell) |
| 🧩 **Git** | Source control |
| 🧠 **Bash completions** | For kubectl, helm, git, etc. |

Everything runs as a **non-root developer user** for realistic, secure workflows.

---

## 🧭 How to Use (Local VS Code)

### Prerequisites

1. Install [Docker Desktop](https://www.docker.com/products/docker-desktop)  
2. Install [Windows Subsystem for Linux (WSL2)](https://learn.microsoft.com/en-us/windows/wsl/install) (if on Windows)  
3. Install [Visual Studio Code](https://code.visualstudio.com/)  
4. Install the **Dev Containers** extension:
