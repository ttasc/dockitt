[![Documentation](https://img.shields.io/badge/docs-available-blue?logo=readthedocs)](./DOC.md)

# 🐳 Dockitt – Self-Hosted DevOps Platform

> A fully automated self-hosted development ecosystem powered by Docker — integrating source control, CI/CD, monitoring, documentation, and internal networking into a single unified platform.

---

## 📖 Overview

**Dockitt** is a turnkey DevOps platform designed to help individuals or small teams quickly set up a complete development environment on a single Linux server.

Instead of manually configuring each service, Dockitt provides:
- 🔄 Automated setup via a single script
- 🌐 Internal DNS-based service discovery
- 🔐 Secure service communication
- 🧩 Pre-integrated DevOps toolchain

---

## 📚 Documentation
For detailed setup and deployment instructions, please refer to: **[Full Deployment Guide](./DOC.md)**

---

## ✨ Included Services

#### 🔧 Core DevOps Stack
- **Source Control:** Gitea
- **CI/CD Pipeline:** Drone CI

#### 📚 Knowledge & Documentation
- **Wiki / Docs:** BookStack

#### 📊 Monitoring & Observability
- **Uptime Monitoring:** Uptime Kuma

#### 🗄️ Database Management
- **DB Admin Tool:** Adminer

#### 🧰 Utilities
- **Developer Tools:** IT-Tools

#### 🌐 Networking Layer
- **Internal DNS:** dnsmasq
- **Reverse Proxy:** Nginx Proxy Manager

#### 🧪 Optional Extensions
- Project Management: Plane
- Communication: Mattermost

## 🏗️ Architecture Overview

Dockitt is built around a **self-contained internal network**:

```text
Client Device
    ↓ (DNS request *.dockitt.local)
dnsmasq (internal DNS)
    ↓
Nginx Proxy Manager
    ↓
Docker Services
    ├── Gitea
    ├── Drone CI
    ├── BookStack
    ├── Adminer
    ├── Uptime Kuma
    └── IT Tools
````

---

### Key Design Concepts

#### 🌐 Internal Domain System

* All services are accessed via:

  ```text
  *.dockitt.local
  ```
* Example:

  * `git.dockitt.local`
  * `drone.dockitt.local`
  * `docs.dockitt.local`

---

#### 🧩 Isolated Docker Network

* Network name: `dockitt_network`
* Subnet: `10.0.0.0/24`
* All containers communicate internally

---

#### 🔐 Reverse Proxy Gateway

* Central entry point via Nginx Proxy Manager
* Handles routing and domain mapping

---

#### ⚙️ Automated Provisioning

* Entire system is bootstrapped via:

  ```bash
  ./setup.sh
  ```

---

## 🚀 Quick Start

### ⚙️ Requirements

* Linux Server (recommended: Debian)
* Docker + Docker Compose
* Bash
* OpenSSL

---

### ⚡ Installation

```bash id="dock1"
git clone https://github.com/ttasc/dockitt.git
cd dockitt
chmod +x setup.sh
./setup.sh
```

---

### 🧠 What the Setup Script Does

The `setup.sh` script automates:

* Detects server IP
* Generates `.env` configuration
* Sets correct file permissions (PUID/PGID)
* Creates internal Docker network
* Generates secure secrets (e.g. Drone RPC)
* Deploys selected services
* Distributes configuration across containers

---

## 🌐 Accessing Services

After setup, services are available via:

| Service     | URL                                                        |
| ----------- | ---------------------------------------------------------- |
| Gitea       | [http://git.dockitt.local](http://git.dockitt.local)       |
| Drone CI    | [http://drone.dockitt.local](http://drone.dockitt.local)   |
| BookStack   | [http://docs.dockitt.local](http://docs.dockitt.local)     |
| Adminer     | [http://db.dockitt.local](http://db.dockitt.local)         |
| Uptime Kuma | [http://status.dockitt.local](http://status.dockitt.local) |
| IT Tools    | [http://tools.dockitt.local](http://tools.dockitt.local)   |

---

## 🖥️ Client Configuration

To access the system from other devices:

👉 Set your **Primary DNS** to the server IP

This allows:

```text
*.dockitt.local → resolved automatically
```

No need to edit `/etc/hosts`.

---

## 🔐 Security Notes

* Internal-only domain (`.local`)
* Isolated Docker network
* Auto-generated secrets (Drone)
* Reverse proxy entrypoint

---

## ⚡ Why Dockitt?

This project demonstrates:

* 🧠 System design thinking (multi-service orchestration)
* 🐳 Docker-based infrastructure design
* 🌐 Internal networking & DNS routing
* 🔄 CI/CD pipeline integration
* 🔐 Secure service communication

---

## 📌 Use Cases

* Homelab DevOps environment
* Internal team development platform
* Learning DevOps & infrastructure
* Self-hosted alternative to cloud services

---

## 🙌 Acknowledgements

* Gitea
* Drone CI
* BookStack
* Uptime Kuma
* Adminer
* IT Tools
* Nginx Proxy Manager
* dnsmasq

---

> 💡 Dockitt is not just a setup script — it's a blueprint for building your own self-hosted DevOps ecosystem.
