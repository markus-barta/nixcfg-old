  # miniserver24 server for mba
{ modulesPath, config, pkgs, username, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/mixins/server-local.nix
      ../../modules/mixins/server-mba.nix
      ./disk-config.zfs.nix
    ];

  # Bootloader.
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  services.zfs.autoScrub.enable = true;

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev"]; path = "/boot"; }
    ];
  };

  boot.initrd.network = {
    enable = true;
    postCommands = ''
      sleep 2
      zpool import -a;
    '';
  };

  networking = {
    hostId = "dabfdb01";  # needed for ZFS
    hostName = "miniserver24";
    networkmanager.enable = true;

    nameservers = ["192.168.1.100"];
    defaultGateway = "192.168.1.5";

    interfaces.enp3s0f0 = {
      ipv4.addresses = [{ address = "192.168.1.101"; prefixLength = 24; }];
    };

    # SSH is already enabled by the server-common mixin
    firewall = {
      # Disable the firewall if not needed
      enable = false;
      allowedTCPPorts = [
        80    # HTTP
        443   # HTTPS
        1880  # Node-RED Web UI
        1883  # MQTT
        9000  # Portainer web
        51827 # HomeKit accessory communication
        554   # HomeKit Secure Video RTSP
        5223  # HomeKit notifications (APNS, Apple Push Notification Service)
      ];
      allowedUDPPorts = [
        443  # HTTPS
        5353 # mDNS for HomeKit: Bonjour discovery and CIAO
      ];
    };
  };


  # Turn off fail2ban, because firewall is turned off
  services.fail2ban.enable = false;

  # Increase ulimit for influxdb
  security.pam.loginLimits = [{
    domain = "*";
    type = "soft";
    item = "nofile";
    value = "8192";
  }];

  # Enable Fwupd
  # https://nixos.wiki/wiki/Fwupd
  services.fwupd.enable = true;

  environment.systemPackages = with pkgs; [
    samba  # Needed for net command to remotely shut down the windows pc from node red and finall via homekit voice command
    wol    # Needed for wake on lan of the windows 10 pc in node red - for a homekit voice command
  ];

  # Custom Zellij Keybinds
  home-manager.users.${username} = {
    home.file."/home/mba/.config/zellij/config.kdl".text = ''
      keybinds {
        unbind "Ctrl o"
        normal {
            bind "Ctrl e" { SwitchToMode "Session"; }
        }
        session {
          bind "Ctrl e" { SwitchToMode "Normal"; }
        }
      }
      session_serialization false;
    '';
  };

}
