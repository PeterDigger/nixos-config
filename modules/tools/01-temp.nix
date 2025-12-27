{ pkgs, ... }:

{
  environment.systemPackages = [
    pkgs.lm_sensors
    (pkgs.writeShellScriptBin "core-temp" ''
#!/usr/bin/env/bash

  echo "=== System Temperature Summary ==="

  # CPU temperature (best-effort)
  cpu_temp=$(sensors 2>/dev/null | awk -F'[:+°]' '/Package id 0:/ { print $3; exit }')

  if [ -n "$cpu_temp" ]; then
    echo "CPU Temp : $cpu_temp °C"
  else
    echo "CPU Temp : N/A"
  fi


      #echo "=== System Temperature Summary ==="

      # CPU temperature
       # cpu_temp=$(sensors 2>/dev/null | awk -F'[:+°]' '/Package id 0:/ { print $3; exit }')


  #if [ -n "$cpu_temp" ]; then
  #  echo "CPU Temp : $cpu_temp°C"
  #else
  #  echo "CPU Temp : N/A"
  #fi


  echo
  echo "=== Drive Summary ==="

  for dev in sda sdb sdd sde sdc; do
    disk="/dev/''${dev}"
    model=$(lsblk -ndo MODEL "''$disk")
    mount=$(lsblk -ndo MOUNTPOINT "''${disk}1")
    temp=$(hddtemp -n "''$disk" 2>/dev/null || echo "?")
    fstype=$(lsblk -ndo FSTYPE "''${disk}"* | grep -m1 .)
    if [ -n "''$mount" ]; then
      used=$(df -h "''$mount" | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}')
    else
      used="N/A"
    fi
    printf "%-5s | %-25s | %-5s | %-6s | %s\n" "''$dev" "''$model" "''$temp °C" "''$fstype" "$used"
  done
    '')
  ];

  environment.shellAliases = {
    core-temp = "sudo core-temp";
  };
}

