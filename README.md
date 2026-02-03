# Pit-Wall: Homelab Observability Stack

Ansible-driven homelab infrastructure with monitoring.

## Architecture

- **Raspberry Pi** (192.168.68.58): Pi-hole DNS + Internet monitoring
- **Proxmox Host** (192.168.68.10): Virtualization host
- **Monitor LXC** (192.168.68.11): Prometheus + Grafana
- **Power LXC** (192.168.68.12): Tapo power monitoring
- **NAS** (192.168.68.12): ZFS storage (future)

## Quick Start

```bash
# Test connectivity
ansible all -m ping

# Configure Raspberry Pi
ansible-playbook playbooks/raspberry-pi.yaml

# Deploy monitoring stack
ansible-playbook playbooks/monitoring-stack.yaml

# Deploy power monitoring
ansible-playbook playbooks/power-monitoring.yaml
```

## Access

- Grafana: http://grafana.pit-wall.local:3000
- Prometheus: http://prometheus.pit-wall.local:9090
- Pi-hole: http://pihole.pit-wall.local/admin

## Screenshots

See [docs/screenshots](docs/screenshots) for visual examples of the monitoring setup:

### Grafana Dashboards

**Infrastructure Monitoring Dashboard**
![Infrastructure Monitoring](docs/screenshots/grafana-infrastructure-dashboard.jpg)

**Pit-wall Dashboards Folder**
![Dashboards Folder](docs/screenshots/grafana-dashboards-folder.jpg)

**Raspberry Pi Metrics Dashboard**
![Raspberry Pi Metrics](docs/screenshots/grafana-raspberry-pi-metrics.jpg)

### Prometheus

**Target Health Status**
![Prometheus Targets](docs/screenshots/prometheus-targets.jpg)

## Status

- [x] Ansible control plane setup
- [x] Pi-hole + DNS configuration
- [x] Monitoring stack deployment
- [x] Power monitoring
- [ ] Dashboards
