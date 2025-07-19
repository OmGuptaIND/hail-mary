# Hail Mary - OpenStack Deployment with Kolla-Ansible

[![OpenStack Release](https://img.shields.io/badge/OpenStack-2025.1-blue.svg)](https://releases.openstack.org/2025.1/)
[![Kolla-Ansible](https://img.shields.io/badge/Kolla--Ansible-20.1.0+-green.svg)](https://docs.openstack.org/kolla-ansible/)
[![Python](https://img.shields.io/badge/Python-3.12+-yellow.svg)](https://www.python.org/)

A streamlined OpenStack deployment project using Kolla-Ansible for rapid cloud infrastructure setup. This project provides a "Hail Mary" approach to quickly deploy a functional OpenStack cloud with minimal complexity.

## 🚀 Overview

**Hail Mary** is designed to deploy OpenStack using Kolla-Ansible in a simplified, production-ready configuration. It automates the entire deployment process from initial server setup to a fully functional OpenStack cloud.

### What This Project Does

- **Automated Server Setup**: Creates necessary users and network bridges
- **OpenStack Deployment**: Deploys core OpenStack services using Kolla-Ansible
- **Simplified Configuration**: Minimal, focused setup for quick deployment
- **Production-Ready**: Uses proven Kolla-Ansible technology with best practices

### Architecture

```
┌─────────────────┐    ┌─────────────────┐
│   Controller    │    │    Compute      │
│   (server1)     │    │   (server2)     │
├─────────────────┤    ├─────────────────┤
│ • Keystone      │    │ • Nova Compute  │
│ • Glance        │    │ • Neutron Agent │
│ • Nova API      │    │ • OVS           │
│ • Neutron       │    │                 │
│ • Horizon       │    │                 │
│ • MariaDB       │    │                 │
│ • RabbitMQ      │    │                 │
└─────────────────┘    └─────────────────┘
```

## 📋 Prerequisites

### System Requirements

- **Operating System**: Ubuntu 20.04+ or similar Linux distribution
- **Python**: 3.12 or higher
- **SSH Access**: Password-less SSH access to target servers
- **Network**: Public IP addresses for both controller and compute nodes
- **Hardware**: 
  - Controller: 8GB+ RAM, 4+ CPUs, 50GB+ storage
  - Compute: 8GB+ RAM, 4+ CPUs, 50GB+ storage

### Required Tools

- [uv](https://github.com/astral-sh/uv) - Python package manager
- Ansible
- SSH key pairs for server access

## 🛠️ Installation & Setup

### 1. Clone the Repository

```bash
git clone https://github.com/OmGuptaIND/hail-mary.git
cd hail-mary
```

### 2. Install Dependencies

```bash
# Install Python dependencies using uv
make install
```

This will install:
- `kolla-ansible` - OpenStack deployment tool
- `ansible` - Automation platform
- Supporting libraries (`cliff`, `stevedore`, `pbr`)

### 3. Configure SSH Keys

Ensure your SSH keys are properly set up in the `keys/` directory:

```
keys/
├── controller/
│   ├── stack          # Private key for controller
│   └── controller.pub # Public key for controller
├── compute/
│   ├── stack          # Private key for compute
│   └── compute.pub    # Public key for compute
└── stack/
    ├── stack          # Stack user private key
    └── stack.pub      # Stack user public key
```

### 4. Update Inventory

Edit `kolla-configs/inventory.ini` to match your server configuration:

```ini
[control]
server1 ansible_host=YOUR_CONTROLLER_IP ansible_user=stack ansible_ssh_private_key_file=/path/to/keys/controller/stack

[compute]
server2 ansible_host=YOUR_COMPUTE_IP ansible_user=stack ansible_ssh_private_key_file=/path/to/keys/compute/stack
```

### 5. Configure Global Settings

Update `kolla-configs/etc/kolla/globals.yml` with your network settings:

```yaml
# Update these IPs to match your environment
kolla_internal_vip_address: "YOUR_CONTROLLER_IP"
kolla_external_vip_address: "YOUR_CONTROLLER_IP"

# Network interface (usually br-ex)
network_interface: "br-ex"
neutron_external_interface: "br-ex"
```

## 🚀 Deployment Process

### Phase 1: Server Preparation

1. **Create Stack User**
   ```bash
   make create-user
   ```
   This creates the `stack` user on all servers with proper sudo privileges.

2. **Setup Network Bridge**
   ```bash
   make create-bridge
   ```
   Creates the `br-ex` bridge interface required for OpenStack networking.

3. **Test Connectivity**
   ```bash
   make ping
   ```
   Verifies Ansible can connect to all servers.

### Phase 2: OpenStack Deployment

1. **Bootstrap Servers**
   ```bash
   make bootstrap
   ```
   Prepares servers for OpenStack installation (installs Docker, configures services).

2. **Run Pre-checks**
   ```bash
   make prechecks
   ```
   Validates the environment before deployment.

3. **Deploy OpenStack**
   ```bash
   kolla-ansible deploy --configdir /path/to/hail-mary/kolla-configs/etc/kolla -i /path/to/hail-mary/kolla-configs/inventory.ini
   ```

4. **Post-deployment Setup**
   ```bash
   kolla-ansible post-deploy --configdir /path/to/hail-mary/kolla-configs/etc/kolla -i /path/to/hail-mary/kolla-configs/inventory.ini
   ```

## 🎯 What Gets Deployed

### Core Services

- **Keystone**: Identity and authentication service
- **Glance**: Image service for VM templates
- **Nova**: Compute service for virtual machines
- **Neutron**: Networking service with Open vSwitch
- **Horizon**: Web-based dashboard
- **Placement**: Resource placement service

### Database & Messaging

- **MariaDB**: Database backend (standalone mode)
- **RabbitMQ**: Message queue service

### Network Configuration

- **Provider Networks**: Disabled (using tenant networks)
- **Network Type**: VXLAN for tenant networks, flat for external
- **Bridge Interface**: `br-ex` for external connectivity

## 🔧 Configuration Details

### Network Architecture

- **Internal Network**: VXLAN-based tenant networks
- **External Network**: Flat network via `br-ex` bridge
- **VIP Address**: Single IP for both internal and external access
- **Load Balancer**: Disabled (single controller setup)

### Security Features

- SSH key-based authentication
- Passwordless sudo for stack user
- Isolated network segments
- Standard OpenStack security groups

## 📁 Project Structure

```
hail-mary/
├── README.md                 # This file
├── pyproject.toml           # Python dependencies
├── makefile                 # Automation commands
├── ansible.cfg              # Ansible configuration
├── requirements.txt         # Python requirements
├── uv.lock                  # Dependency lock file
├── keys/                    # SSH keys for servers
├── kolla-configs/           # Kolla-Ansible configuration
│   ├── inventory.ini        # Server inventory
│   └── etc/kolla/
│       └── globals.yml      # Global OpenStack settings
├── kolla-ansible/           # Kolla-Ansible source (submodule)
└── playbooks/               # Custom Ansible playbooks
    ├── create-user/         # User setup playbook
    └── create-bridge/       # Network bridge setup
```

## 🔍 Troubleshooting

### Common Issues

1. **SSH Connection Failed**
   - Verify SSH keys are in the correct location
   - Check server connectivity: `ping <server_ip>`
   - Ensure `stack` user exists and has proper permissions

2. **Bridge Creation Failed**
   - Verify the physical interface name (`eno1` by default)
   - Check if OpenVSwitch is installed
   - Ensure sufficient privileges for network operations

3. **Bootstrap Failed**
   - Check Docker installation and permissions
   - Verify internet connectivity for package downloads
   - Review `/var/log/kolla/` for detailed error logs

4. **Deployment Failed**
   - Review Ansible output for specific errors
   - Check container logs: `docker logs <container_name>`
   - Verify resource requirements (CPU, memory, disk)

### Useful Commands

```bash
# Check container status
docker ps -a

# View Kolla logs
sudo tail -f /var/log/kolla/*.log

# Restart failed containers
docker restart <container_name>

# Clean deployment (start over)
kolla-ansible destroy --yes-i-really-really-mean-it

# Generate admin credentials
kolla-ansible post-deploy
source /etc/kolla/admin-openrc.sh
```

## 🌐 Accessing OpenStack

After successful deployment:

1. **Horizon Dashboard**: `http://<controller_ip>/`
2. **Admin Credentials**: Found in `/etc/kolla/admin-openrc.sh`
3. **API Endpoints**: Listed in the deployment output

### Default Login

- **Username**: `admin`
- **Password**: Generated during deployment (check `/etc/kolla/passwords.yml`)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feature-name`
3. Make your changes and test thoroughly
4. Submit a pull request with detailed description

## 📄 License

This project is licensed under the Apache License 2.0 - see the LICENSE file for details.

## 🆘 Support

- **Issues**: Report bugs and feature requests on GitHub Issues
- **Documentation**: [Kolla-Ansible Official Docs](https://docs.openstack.org/kolla-ansible/)
- **Community**: [OpenStack Community](https://www.openstack.org/community/)

## 🔗 Related Projects

- [Kolla-Ansible](https://github.com/openstack/kolla-ansible) - Official OpenStack deployment tool
- [OpenStack](https://www.openstack.org/) - Open source cloud computing platform
- [Ansible](https://www.ansible.com/) - Automation platform

---

**Note**: This is a simplified deployment suitable for development, testing, and small production environments. For large-scale production deployments, consider additional high-availability and security configurations.
