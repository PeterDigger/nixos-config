{ config, pkgs, ... }:

{
 virtualisation.docker.enable = true;

 # For more isolation, you can use systemd cgroups and enable layers if needed

  ############################
  ## Docker auto pull latest image
  ############################

  systemd.services.docker-pull-latest = {
    description = "Pull latest docker images from compose files";
    after = [ "docker.service" "network.target" ];
    wants = [ "docker.service" ];
    serviceConfig = {
	ExecStart = "${pkgs.writeShellScriptBin "dockerpull-run-wrapper" ''
	  exec /run/current-system/sw/bin/dockerpull
    	''}/bin/dockerpull-run-wrapper";
    	Type = "oneshot";
    };
  };

  systemd.timers.docker-pull-latest = {
    description = "Run docker pull 10 minutes after boot";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnBootSec = "10min";
      Persistent = true;
    };
  };
}
