{ config, lib, pkgs, ... }:

let
  dockerComposeBin = "/run/current-system/sw/bin/docker compose";
  composeFiles = [
    "/docker/00-docker_compose/08-jellyfin.yml"
    "/docker/00-docker_compose/15-navidrome.yml"
  ];
  composeFlags = lib.concatStringsSep " \\\n  -f " (map toString composeFiles);
in {
  config = {
    systemd.services.delicate-media = {
      description = "Docker Compose for Media Stack";
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

