{ config, lib, pkgs, ... }:


{
  config = {
    systemd.services.delicate-homer = {
      description = "Docker Compose for Homer";
      after = [ "network.target" "docker.service" ];
      requires = [ "docker.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
	Type = "exec";

	# Pull the latest image before running
	#ExecStartPre = "/run/current-system/sw/bin/docker compose -f /docker/00-docker_compose/01-homer.yml pull";

	# Bring the service up
	ExecStart = "/run/current-system/sw/bin/docker compose -f /docker/00-docker_compose/01-homer.yml up";

	# Take it down gracefully
	ExecStop = "/run/current-system/sw/bin/docker compose -f /docker/00-docker_compose/01-homer.yml down";

	WorkingDirectory = "/docker/00-docker_compose";
	Restart = "on-failure";
	RestartSec = 5;
      };
    };
  };
}
