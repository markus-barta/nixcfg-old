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

      # Zellij keybindings configuration
      keybinds {
        unbind "Ctrl o"

        normal {
          bind "Ctrl e" { SwitchToMode "Session"; }
        }

        session {
          bind "Ctrl e" { SwitchToMode "Normal"; }
        }
      }

      # Zellij themes configuration
      themes {

        # csb0 theme
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

        # ms theme
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

      # Zellij session configuration
      session_serialization true;

      # Theme to be used by Zellij
      theme "csb0";

    '';
  };
}
