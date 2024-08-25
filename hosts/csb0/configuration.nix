# Configuration for csb0 (legacy name: onlineserver01) Netcup server mba
{ modulesPath, config, pkgs, username, ... }:

{
  # Import necessary configuration modules
  imports = [
    ./hardware-configuration.nix
    ../../modules/mixins/server-remote.nix
    ../../modules/mixins/server-mba.nix
    ./disk-config.zfs.nix
  ];

  # Bootloader configuration
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  services.zfs.autoScrub.enable = true;

  boot.loader.grub = {
    enable = true;
    zfsSupport = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    mirroredBoots = [
      { devices = [ "nodev" ]; path = "/boot"; }
    ];
  };

  # Network settings for the initial RAM disk (initrd)
  boot.initrd.network = {
    enable = true;
    postCommands = ''
      sleep 2
      zpool import -a;
    '';
  };

  # Networking configuration
  networking = {
    hostId = "dabfdc01";  # Needed for ZFS
    hostName = "csb0";
    networkmanager.enable = true;

    # Firewall configuration
    firewall = {
      # allowedTCPPorts = [ 25 ]; # Uncomment to allow SMTP
    };
  };

  # Mosquitto configuration mba <
  users.groups.mosquitto = {
    gid = 1883;
  };

  users.users.${username}.extraGroups = [ "mosquitto" ];

  system.activationScripts.mosquittoPermissions = ''
    chown -R ${username}:mosquitto /home/${username}/docker/mosquitto
    chmod -R 775 /home/${username}/docker/mosquitto
  '';
  # > mba

  # Environment system packages
  environment.systemPackages = with pkgs; [
    # Add system packages here
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
              bind "Ctrl e" { SwitchToMode "Session"; }
          }
          session {
              bind "Ctrl e" { SwitchToMode "Normal"; }
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

          // csb0 theme
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

          // ms theme
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

      // Zellij session configuration
      session_serialization true

      // Theme to be used by Zellij
      theme "csb0"

    '';
  };
}
