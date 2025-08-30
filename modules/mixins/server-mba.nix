{ config, inputs, username, ... }:
{
  imports = [
    ./remote-store-cache.nix
  ];

  # No password needed for sudo for wheel group
  security.sudo.wheelNeedsPassword = false;

  users.users.${username} = {
    description = "Markus";
    openssh.authorizedKeys.keys = [
      # Public key of mba
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDGIQIkx1H1iVXWYKnHkxQsS7tGsZq3SoHxlVccd+kroMC/DhC4MWwVnJInWwDpo/bz7LiLuh+1Bmq04PswD78EiHVVQ+O7Ckk32heWrywD2vufihukhKRTy5zl6uodb5+oa8PBholTnw09d3M0gbsVKfLEi4NDlgPJiiQsIU00ct/y42nI0s1wXhYn/Oudfqh0yRfGvv2DZowN+XGkxQQ5LSCBYYabBK/W9imvqrxizttw02h2/u3knXcsUpOEhcWJYHHn/0mw33tl6a093bT2IfFPFb3LE2KxUjVqwIYz8jou8cb0F/1+QJVKtqOVLMvDBMqyXAhCkvwtEz13KEyt"
      # miniserver24: node-red container ssh calls
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAhUleyXsqtdA4LC17BshpLAw0X1vMLNKp+lOLpf2bw1 mba@miniserver24"
      # github
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHg1Y7vbAJs4dB7I0zez5nhz9/zYI6qaEt1+HefM/7qF github-actions-deployment@pixoo-daemon"
    ];
  };

  home-manager.users.${username} = {
    programs.git = {
      userName  = "Markus Barta";
      userEmail = "markus@barta.com";
    };
  };

  # Set mba specific fish config
  programs.fish = {
    shellAliases = {
#      mc = "EDITOR=nano mc";
    };
    shellAbbrs = {
#      cat = "bat";
    };
    interactiveShellInit = ''
      function sourcefish --description 'Load env vars from a .env file into current Fish session'
        set file "$argv[1]"
        if test -z "$file"
          echo "Usage: sourcefish PATH_TO_ENV_FILE"
          return 1
        end
        if test -f "$file"
          for line in (cat "$file" | grep -v '^[[:space:]]*#' | grep .)
            set key (echo $line | cut -d= -f1)
            set val (echo $line | cut -d= -f2-)
            set -gx $key "$val"
          end
        else
          echo "File not found: $file"
          return 1
        end
      end
      export EDITOR=nano
    '';
  };

  environment.variables.EDITOR = "nano";

  # GHCR (GitHub Container Registry) credentials for Docker
  environment.sessionVariables = {
    GHCR_USERNAME = "markus-barta";
    # GHCR_PASSWORD → manual login
  };
}
