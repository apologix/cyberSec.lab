$data = [ordered]@{
  session_id = [guid]::NewGuid().ToString('N')
  collector_version = '1.0.0'
  platform = 'windows'
  hostname = $env:COMPUTERNAME
  os = (Get-CimInstance Win32_OperatingSystem).Caption
  architecture = $env:PROCESSOR_ARCHITECTURE
  network_data = @{ interfaces = @(Get-NetIPConfiguration | ForEach-Object {@{alias=$_.InterfaceAlias; ipv4=@($_.IPv4Address.IPAddress); gateway=@($_.IPv4DefaultGateway.NextHop); dns=@($_.DNSServer.ServerAddresses)}}) }
  uptime_seconds = [int]((Get-Date) - (Get-CimInstance Win32_OperatingSystem).LastBootUpTime).TotalSeconds
}
$json = $data | ConvertTo-Json -Depth 6
if ($env:CYBERLAB_COLLECTOR_URL -and $env:CYBERLAB_COLLECTOR_TOKEN) {
  Invoke-RestMethod -Method Post -Uri $env:CYBERLAB_COLLECTOR_URL -ContentType 'application/json' -Headers @{'X-Collector-Token'=$env:CYBERLAB_COLLECTOR_TOKEN} -Body $json | Out-Null
} else { $json }
