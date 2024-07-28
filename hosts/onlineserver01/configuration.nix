# csb0 (onlineserver01) Netcup server mba
{ modulesPath, config, pkgs, username, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ../../modules/mixins/server-remote.nix
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
    hostId = "dabfdc01";  # needed for ZFS
    hostName = "onlineserver01";
    networkmanager.enable = true;

    # ssh is already enabled by the server-common mixin
    firewall = {
      # allowedTCPPorts = [ 25 ]; # SMTP
    };
  };

  environment.systemPackages = with pkgs; [
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

      themes {

          cyber-noir {
              bg "#0b0e1a" // Dark Blue
              fg "#91f3e4" // Teal
              red "#ff578d" // Hot Pink
              green "#00ff00" // Neon Green
              blue "#3377ff" // Electric Blue
              yellow "#ffd700" // Cyber Yellow
              magenta "#ff00ff" // Neon Purple
              orange "#ff7f50" // Cyber Orange
              cyan "#00e5e5" // Cyan
              black "#000000" // Black
              white "#91f3e4" // Teal
          }

          blade-runner {
              bg "#1a1a1a" // Dark Gray
              fg "#2bbff4" // Neon Blue
              red "#ff355e" // Neon Pink
              green "#00ff00" // Neon Green
              blue "#00d9e3" // Electric Blue
              yellow "#ffe600" // Neon Yellow
              magenta "#ff00ff" // Neon Purple
              orange "#ff8c0d" // Cyber Orange
              cyan "#00e5e5" // Cyan
              black "#000000" // Black
              white "#ffffff" // White
          }

          retro-wave {
              bg "#1a1a1a" // Dark Gray
              fg "#ff9900" // Retro Orange
              red "#ff355e" // Neon Pink
              green "#00ff00" // Neon Green
              blue "#00d9e3" // Electric Blue
              yellow "#ffe600" // Neon Yellow
              magenta "#ff00ff" // Neon Purple
              orange "#ff6611" // Retro Red
              cyan "#00e5e5" // Cyan
              black "#000000" // Black
              white "#ffffff" // White
          }

          csb0 {
              bg "#1a1a1a" // + Window bg
              fg "#6666af" // + Footer buttons
              red "#ffffff" // + White
              green "#9999ff" // + Frame
              blue "#00d9e3" // Electric Blue
              yellow "#aae600" // Neon Yellow
              magenta "#aa00ff" // Neon Purple
              orange "#006611" // Retro Red
              cyan "#00e5e5" // Cyan
              black "#000000" // Black
              white "#ffffff" // White
          }
      }
      
      session_serialization false;
      theme "csb0";

    '';
  };



}
