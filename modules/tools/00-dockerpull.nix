{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "dockerpull" ''
      updated_count=0
      total_count=0

      for compose_file in /docker/00-docker_compose/*.yml; do
        if [[ -e "$compose_file" ]]; then
          ((total_count++))
          output=$(docker compose -f "$compose_file" pull 2>&1)
          if echo "$output" | grep -qi "Downloaded newer image"; then
            ((updated_count++))
          fi
        fi
      done

      /run/current-system/sw/bin/wall "===== Docker Pull Latest Image =====
      
      Summary: $updated_count out of $total_count stacks had updates.
      
      Event: Triggers after 10 minutes after boot
      Service Name: \"delicate-docker-pull-latest\"
      Service Description: \"Pull latest docker images from compose files\"
      
      ====================================

      Note 1: No containers were restarted automatically.
              Run 'docker compose down && docker compose up -d' for
              services you want to refresh.

      Note 2: To view full detail of the service log, run
         'journalctl -u docker-pull-latest.service'
      
      ===================================="
    '')
  ];
}
