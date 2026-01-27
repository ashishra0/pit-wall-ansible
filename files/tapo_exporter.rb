#!/usr/bin/env ruby

require 'tapo'
require 'webrick'
require 'logger'

TAPO_EMAIL = ENV['TAPO_EMAIL']
TAPO_PASSWORD = ENV['TAPO_PASSWORD']
PORT = 9200
DISCOVERY_TIMEOUT = 5
POLL_INTERVAL = 15

$logger = Logger.new(STDOUT)
$logger.level = Logger::INFO

$tapo_client = nil
$last_metrics = {}
$last_update = Time.now - POLL_INTERVAL

def discover_tapo_device
  $logger.info "Discovering Tapo devices on network..."
  devices = Tapo::Discovery.discover(timeout: DISCOVERY_TIMEOUT)
  $logger.info "Found #{devices.length} devices: #{devices.join(', ')}"

  devices.each do |ip|
    next if ip == "192.168.68.1"

    begin
      $logger.info "Attempting to connect to #{ip}..."
      client = Tapo::Client.new(ip, TAPO_EMAIL, TAPO_PASSWORD)
      client.authenticate!

      info = client.device_info
      if info["model"]&.include?("P110") || info["model"]&.include?("P115")
        $logger.info "Found Tapo energy monitoring plug at #{ip} (Model: #{info['model']})"
        return client
      else
        $logger.info "Device at #{ip} is not an energy monitoring plug (Model: #{info['model']})"
      end
    rescue => e
      $logger.debug "Failed to authenticate with #{ip}: #{e.message}"
    end
  end

  $logger.error "No Tapo energy monitoring device found on network!"
  nil
end

def update_metrics
  now = Time.now

  return if now - $last_update < POLL_INTERVAL

  if $tapo_client.nil?
    $tapo_client = discover_tapo_device
    return if $tapo_client.nil?
  end

  begin
    energy = $tapo_client.energy_usage

    $last_metrics = {
      power_w: energy["power_w"] || 0,
      power_kw: energy["power_kw"] || 0,
      voltage_v: energy["voltage_v"] || 0,
      current_a: energy["current_a"] || 0,
      today_energy_wh: energy["today_energy_wh"] || 0,
      today_energy_kwh: energy["today_energy_kwh"] || 0,
      month_energy_wh: energy["month_energy_wh"] || 0,
      month_energy_kwh: energy["month_energy_kwh"] || 0,
      today_runtime_min: energy["today_runtime_min"] || 0,
      month_runtime_min: energy["month_runtime_min"] || 0
    }

    $last_update = now
    $logger.info "Updated metrics: #{$last_metrics[:power_w]}W, #{$last_metrics[:voltage_v]}V, #{$last_metrics[:current_a]}A"
  rescue => e
    $logger.error "Failed to fetch metrics: #{e.message}"
    $tapo_client = nil
  end
end

def generate_prometheus_metrics
  update_metrics

  output = []
  output << "# HELP tapo_power_watts Current power consumption in watts"
  output << "# TYPE tapo_power_watts gauge"
  output << "tapo_power_watts #{$last_metrics[:power_w]}"
  output << ""

  output << "# HELP tapo_voltage_volts Current voltage in volts"
  output << "# TYPE tapo_voltage_volts gauge"
  output << "tapo_voltage_volts #{$last_metrics[:voltage_v]}"
  output << ""

  output << "# HELP tapo_current_amperes Current in amperes"
  output << "# TYPE tapo_current_amperes gauge"
  output << "tapo_current_amperes #{$last_metrics[:current_a]}"
  output << ""

  output << "# HELP tapo_today_energy_kwh Today's energy consumption in kilowatt-hours"
  output << "# TYPE tapo_today_energy_kwh gauge"
  output << "tapo_today_energy_kwh #{$last_metrics[:today_energy_kwh]}"
  output << ""

  output << "# HELP tapo_month_energy_kwh Month's energy consumption in kilowatt-hours"
  output << "# TYPE tapo_month_energy_kwh gauge"
  output << "tapo_month_energy_kwh #{$last_metrics[:month_energy_kwh]}"
  output << ""

  output << "# HELP tapo_today_runtime_minutes Today's runtime in minutes"
  output << "# TYPE tapo_today_runtime_minutes gauge"
  output << "tapo_today_runtime_minutes #{$last_metrics[:today_runtime_min]}"
  output << ""

  output << "# HELP tapo_month_runtime_minutes Month's runtime in minutes"
  output << "# TYPE tapo_month_runtime_minutes gauge"
  output << "tapo_month_runtime_minutes #{$last_metrics[:month_runtime_min]}"
  output << ""

  output << "# HELP tapo_up Tapo device is reachable (1) or not (0)"
  output << "# TYPE tapo_up gauge"
  output << "tapo_up #{$tapo_client.nil? ? 0 : 1}"

  output.join("\n")
end

server = WEBrick::HTTPServer.new(Port: PORT, Logger: $logger, AccessLog: [])

server.mount_proc '/metrics' do |req, res|
  res.body = generate_prometheus_metrics
  res['Content-Type'] = 'text/plain; version=0.0.4'
end

server.mount_proc '/health' do |req, res|
  res.body = "OK\n"
  res['Content-Type'] = 'text/plain'
end

trap('INT') { server.shutdown }
trap('TERM') { server.shutdown }

$logger.info "Tapo Prometheus Exporter starting on port #{PORT}"
$logger.info "Metrics available at http://0.0.0.0:#{PORT}/metrics"

discover_tapo_device

server.start
