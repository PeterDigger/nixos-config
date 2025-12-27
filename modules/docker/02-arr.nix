{ config, lib, pkgs, ... }:

let
  dockerComposeBin = "/run/current-system/sw/bin/docker compose";
  composeFiles = [
    "/docker/00-docker_compose/03-flaresolverr.yml"
    "/docker/00-docker_compose/04-jackett.yml"
    "/docker/00-docker_compose/05-radarr.yml"
    "/docker/00-docker_compose/06-sonarr.yml"
    "/docker/00-docker_compose/07-lidarr.yml"
    "/docker/00-docker_compose/09-deluge.yml"
  ];
  composeFlags = lib.concatStringsSep " \\\n  -f " (map toString composeFiles);
in {
  config = {
    systemd.services.delicate-arr = {
      description = "Docker Compose for *ARR Stack";
      after = [ "network.target" "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "exec";

        #ExecStartPre = ''
        #  ${dockerComposeBin} \
        #    -f ${composeFlags} \
        #    pull
        #'';

        ExecStart = ''
          ${dockerComposeBin} \
            -f ${composeFlags} \
            up
        '';

        ExecStop = ''
          ${dockerComposeBin} \
            -f ${composeFlags} \
            down
        '';

        WorkingDirectory = "/docker/00-docker_compose";
        Restart = "on-failure";
        RestartSec = 5;
      };
    };
  };
}

