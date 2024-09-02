# miniserver24 server for mba
{ modulesPath, config, pkgs, username, ... }:

{
  # Import necessary configuration modules
  imports = [
    ./hardware-configuration.nix
    ../../modules/mixins/server-local.nix
    ../../modules/mixins/server-mba.nix
    ./disk-config.zfs.nix
  ];

  # Bootloader configuration
  boot = {
    supportedFilesystems = [ "zfs" ];
    kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
    loader.grub = {
      enable = true;
      zfsSupport = true;
      efiSupport = true;
      efiInstallAsRemovable = true;
      mirroredBoots = [
        { devices = [ "nodev" ]; path = "/boot"; }
      ];
    };
    initrd.network = {
      enable = true;
      postCommands = ''
        sleep 2
        zpool import -a;
      '';
    };
  };

  # ZFS configuration
  services.zfs.autoScrub.enable = true;

  # Networking configuration
  networking = {
    hostId = "dabfdb01";  # Needed for ZFS
    hostName = "miniserver24";
    networkmanager.enable = true;
    nameservers = ["192.168.1.100"];
    defaultGateway = "192.168.1.5";
    interfaces.enp3s0f0 = {
      ipv4.addresses = [{ address = "192.168.1.101"; prefixLength = 24; }];
    };
    # Firewall configuration
    firewall = {
      enable = false;  # Firewall is disabled
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

  # Disable fail2ban since firewall is turned off
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

  # Additional system packages
  environment.systemPackages = with pkgs; [
    samba  # Needed for net command to remotely shut down the Windows PC from Node-RED and finally via HomeKit voice command
    wol    # Needed for wake-on-LAN of the Windows 10 PC in Node-RED - for a HomeKit voice command
  ];

  # Home Manager configuration for custom Zellij keybindings and themes
  home-manager.users.${username} = {
    home.file."/home/mba/.config/zellij/config.kdl".text = ''

      /***********************************************
       *    WARNING: CRITICAL INDENTATION SECTION    *
       * KDL config below MUST be properly indented. *
       ***********************************************/

      // Zellij keybindings configuration
      keybinds {
          unbind "Ctrl o"
          normal {
              bind "Ctrl a" { MoveTab "Left"; }
              bind "Ctrl e" { SwitchToMode "Session"; }
          }
          session {
              bind "Ctrl e" { SwitchToMode "Normal"; }
          }
          tab {
              bind "c" {
                  NewTab {
                      cwd "~"
                  }
              }
          }
      }

      // Zellij themes configuration
      themes {
          catppuccin-latte {
              bg "#acb0be" // Surface2
              fg "#acb0be" // Surface2
              red "#d20f39"
              green "#40a02b"
              blue "#1e66f5"
              yellow "#df8e1d"
              magenta "#ea76cb" // Pink
              orange "#fe640b" // Peach
              cyan "#04a5e5" // Sky
              black "#dce0e8" // Crust
              white "#4c4f69" // Text
          }

          catppuccin-frappe {
              bg "#626880" // Surface2
              fg "#c6d0f5"
              red "#e78284"
              green "#a6d189"
              blue "#8caaee"
              yellow "#e5c890"
              magenta "#f4b8e4" // Pink
              orange "#ef9f76" // Peach
              cyan "#99d1db" // Sky
              black "#292c3c" // Mantle
              white "#c6d0f5"
          }

          catppuccin-macchiato {
              bg "#5b6078" // Surface2
              fg "#cad3f5"
              red "#ed8796"
              green "#a6da95"
              blue "#8aadf4"
              yellow "#eed49f"
              magenta "#f5bde6" // Pink
              orange "#f5a97f" // Peach
              cyan "#91d7e3" // Sky
              black "#1e2030" // Mantle
              white "#cad3f5"
          }

          catppuccin-mocha {
              bg "#585b70" // Surface2
              fg "#cdd6f4"
              red "#f38ba8"
              green "#a6e3a1"
              blue "#89b4fa"
              yellow "#f9e2af"
              magenta "#f5c2e7" // Pink
              orange "#fab387" // Peach
              cyan "#89dceb" // Sky
              black "#181825" // Mantle
              white "#cdd6f4"
          }

          // cloud server csb0 theme
          csb0 {
              bg "#9999ff"  // + Text Selection
              fg "#6666af"  // + Footer Buttons
              red "#f0f0f0" // + Shortcuts in Buttons (best: white)
              green "#9999ff" // + Frame
              blue "#00d9e3" // Electric Blue
              yellow "#aae600" // Neon Yellow
              magenta "#aa00ff" // Neon Purple
              orange "#006611" // Retro Red
              cyan "#00e5e5" // Cyan
              black "#00000f" // + Header and Footer bg (Black)
              white "#ffffff" // White
          }

          // miniserver24 theme
          ms24 {
              bg "#585b70" // Surface2
              fg "#d5f4cd" // pastell green
              red "#2a9e00" // dark green
              green "#a6e3a1"
              blue "#89b4fa"
              yellow "#f9e2af"
              magenta "#f5c2e7" // Pink
              orange "#fab387" // Peach
              cyan "#89dceb" // Sky
              black "#181825" // Mantle
              white "#cdd6f4"
          }

          // miniserver theme
          ms {
              bg "#9f9f9f"  // + Text Selection
              fg "#6f6f6f"  // + Footer Buttons
              red "#f0f0f0" // + Shortcuts in Buttons (best: white)
              green "#9f9f9f" // + Frame
              blue "#00d9e3" // Electric Blue
              yellow "#aae600" // Neon Yellow
              magenta "#aa00ff" // Neon Purple
              orange "#006611" // Retro Red
              cyan "#00e5e5" // Cyan
              black "#00000f" // + Header and Footer bg (Black)
              white "#ffffff" // White
          }
      }

      // Session configuration (optionally restores terminated sessions on start)
      session_serialization true

      // Theme to be used
      theme "ms24"
    '';
  };
}
