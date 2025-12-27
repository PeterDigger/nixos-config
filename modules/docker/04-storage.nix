{ config, lib, pkgs, ... }:

let
  dockerComposeBin = "/run/current-system/sw/bin/docker compose";
  composeFiles = [
    "/docker/00-docker_compose/10-immich.yml"
    "/docker/00-docker_compose/12-nextcloud.yml"
    "/docker/00-docker_compose/14-syncthing.yml"
  ];
  composeFlags = lib.concatStringsSep " \\\n  -f " (map toString composeFiles);
in {
  config = {
    systemd.services.delicate-storage = {
      description = "Docker Compose for Storage Stack";
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
	TimeoutSec = 300;
      };
    };
  };
}

