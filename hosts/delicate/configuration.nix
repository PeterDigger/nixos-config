{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/tools/00-dockerpull.nix
      ./modules/tools/01-temp.nix
      ./modules/tools/02-smartctl.nix
      ./modules/tools/03-smartctl-status.nix
      ./modules/tools/04-rebuild.nix
    ];
  
  environment.shellAliases = {
    readme = "nvim /etc/nixos/README.md";
  };

  # for beep
   boot.kernelModules = [ "pcspkr" ];

    # Example NixOS configuration for udev rule
    services.udev.extraRules = ''
      KERNEL=="platform-pcspkr-event-spkr", MODE="0660", GROUP="beep"
    '';

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  # Kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;
  
  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      addresses = true;
      workstation = true;
    };
    nssmdns = true;
  };

  services.samba = {
    enable = true;
    securityType = "user";
    openFirewall = true;
    shares = {
      delicate = {
        path = "/mnt/storage";
        browseable = "yes";
          "read only" = "no";
          "valid users" = "delicate";
      };
    };
  };

  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };

  # Network
  networking.hostName = "delicate"; # Define your hostname.

  # Enable WoL
  # networking.interfaces.enp2s0.wakeOnLan.policy =  [ "broadcast"];
  # networking.interfaces.enp2s0.wakeOnLan.enable = true;

  # Enable Message of the Day
  programs.bash.loginShellInit = ''
    #usage=$(df -h /dev/sda1 | awk 'NR==2 {print $5}')
    #echo "Current /dev/sda1 usage: $usage"
    echo " ";
    /run/current-system/sw/bin/smartctl-status
  '';

  # Enable SSD Trim
  services.fstrim.enable = true;

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Kuching";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.delicate = {
    isNormalUser = true;
    description = "delicate";
    extraGroups = [ "networkmanager" "docker" "wheel" "input"];
    packages = with pkgs; [];
  };

  # Enable automatic login for the user.
  services.getty.autologinUser = "delicate";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
    btop-rocm
    lazydocker
    hddtemp
    btrfs-progs
    xfsprogs
    pkgs.libxfs
    smartmontools
    beep
  ];

  # List services that you want to enable:
  programs.neovim = {
    enable = true;
    defaultEditor = true;
  };

  # Enable the Git
  programs.git = {
    enable = true;
    config = {
      user.name = "Peter";
      user.email = "chongherng99@gmail.com";
      init.defaultBranch = "main";
      pull.rebase = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
    # settings.PasswordAuthentication = false;
    ports = [ 22 ];
  };

  networking.firewall = {
    enable = true;
    extraCommands = "
     iptables -I nixos-fw 1 -i br+ -j ACCEPT
    ";
    extraStopCommands = "
     iptables -D nixos-fw -i br+ -j ACCEPT
   ";
   allowPing = true;
  };

  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

}
