{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "smarttest" ''
      #!/usr/bin/env bash
      logfile="/var/log/smartctl_tests.log"

      # Check argument
      if [[ $# -ne 1 ]]; then
        echo "Usage: smarttest /dev/sdX"
        exit 1
      fi

      dev="$1"
      if [[ ! -b "$dev" ]]; then
        echo "Error: $dev is not a valid block device"
        exit 1
      fi

      echo "=== Starting SMART long test for $dev ==="
      /run/current-system/sw/bin/smartctl -t long "$dev"

      # Wait for smartctl to acknowledge the test start
      if [[ $? -eq 0 ]]; then
        now="$(date '+%Y-%m-%d %H:%M:%S')"
        echo "$dev  $now" >> "$logfile"
        echo "Logged: $dev  $now to $logfile"
      else
        echo "Failed to start SMART test for $dev"
      fi
    '')
  ];
}
