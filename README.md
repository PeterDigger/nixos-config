# nixos-config

What can you do with this system?
1. You can perform manual update to the docker to make sure all the docker image are update to date.
2. You can perform long smartctl test to all the disks for every month
3. You can perform the snapraid check to make all the parity data snapshots are up-to-update 
4. You can perform the Lazydocker to check the health of all the services.
5. You can check temps of all the crucial hardware components

### Directory:
    /docker/00-docker_compose - stores all the docker compose files
    /docker/[01-99] - stores all the configuration file.
    /etc/nixos/modules/docker - stores nix config for docker related files
    /etc/nixos/modules/tools - stores nix scripts for custom programs

### List of services
    delicate-homer
    delicate-arr
    delciate-media
    delicate-storage
    delicate-tools
    docker-pull-latest
    snapraid-scrub
    snapraid-sync

### Services Timer
    docker-pull-latest.timer - 10 mins after the boot
    snapraid-sync.timer - 1 hour after the boot
    snapraid-scrub.timer - 2 hours after the boot

### Tools
    core-temp   - (custom) Prints out current all the hardware components temperature
    dockerpull  - (custom) Pulls the latest docker images
    lazydocker  - list of docker
    #scrub      - (custom) Prints out current SnapRaid status
    smarttest   - (custom) Runs long test with the disks/partition and log a date in /var/log/smartctl_test.log
        Example usage: sudo smarttest /dev/sdx1

### Alias
    readme = "nvim /etc/nixos/README.md"
    snapdiff = "sudo snapraid diff";
    snapsync = "sudo snapraid sync";
    snapscrub = "sudo snapraid scrub -p 10 -o 10";
    snapstatus = "sudo snapraid status";

### Timer
    10 mins after boot runs dockerpull
    1 hours after boot runs snapraid sync weekly
    2 hours after boot runs snapraid scrub monthly
    Everytime boots/session runs the reminder on last run smartctl long test 
        for all the hard disks.
