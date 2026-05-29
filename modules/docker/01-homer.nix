{ config, lib, pkgs, ... }:

let
  dockerComposeBin = "/run/current-system/sw/bin/docker compose";
  composeFiles = [
    "/docker/00-docker_compose/01-homer.yml"
    "/docker/00-docker_compose/16-glance.yml"
  ];
  composeFlags = lib.concatStringsSep " \\\n  -f " (map toString composeFiles);
in {
  config = {
    systemd.services.delicate-homer = {
      description = "Docker Compose for Homer";
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

