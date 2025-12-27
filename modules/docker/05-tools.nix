{ config, lib, pkgs, ... }:

let
  dockerComposeBin = "/run/current-system/sw/bin/docker compose";
  composeFiles = [
    "/docker/00-docker_compose/02-scrutiny.yml"
    #"/docker/00-docker_compose/11-immich_duplicate_finder.yml"
    "/docker/00-docker_compose/13-stirling-pdf.yml"
  ];
  composeFlags = lib.concatStringsSep " \\\n  -f " (map toString composeFiles);
in {
  config = {
    systemd.services.delicate-tools = {
      description = "Docker Compose for Tools Stack";
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

