# Screenshots

This folder contains screenshots showing the Prometheus and Grafana monitoring setup.

## Grafana Dashboards

### Infrastructure Monitoring Dashboard
**File:** `grafana-infrastructure-dashboard.jpg`

Shows the main infrastructure monitoring dashboard with:
- System health status indicators (Raspberry Pi, Thinkcentre, Monitor LXC)
- CPU usage gauges and time-series graphs
- Memory usage across all monitored systems
- Disk usage for root filesystems
- Network traffic monitoring

### Dashboards Folder
**File:** `grafana-dashboards-folder.jpg`

The Pit-wall folder in Grafana containing all available dashboards:
- Infrastructure Monitoring
- Internet connection
- Power Monitoring
- Raspberry Pi metrics

### Raspberry Pi Metrics Dashboard
**File:** `grafana-raspberry-pi-metrics.jpg`

Detailed metrics for the Raspberry Pi including:
- Quick CPU/Memory/Disk overview gauges
- System load and pressure metrics
- RAM and SWAP usage
- Network traffic (basic view)
- Disk space utilization

## Prometheus

### Target Health Status
**File:** `prometheus-targets.jpg`

Prometheus service discovery and target health showing:
- **blackbox-http**: HTTP monitoring endpoints for external services
- **file-sd**: File-based service discovery targets
  - Monitor LXC
  - Raspberry Pi (blackbox-exporter and node-exporter)
  - Tapo power monitoring
  - Prometheus itself
  - Network core monitoring
  - Proxmox host

All targets show their endpoint URLs, labels, last scrape time, and current state.
