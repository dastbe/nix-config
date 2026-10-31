{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  name = "David Bell";
  email = "dastbe@gmail.com";
in {
  # This value pins home-manager's defaults to the release this config was
  # first written against. Read the home-manager release notes before bumping.
  home.stateVersion = "18.09";

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  home.packages = [
    pkgs.awscli2
    pkgs.bazelisk
    # bazelisk only installs `bazelisk`; expose it as `bazel` for scripts and
    # editors too, not just interactive shells.
    (pkgs.writeShellScriptBin "bazel" ''exec ${pkgs.bazelisk}/bin/bazelisk "$@"'')
    pkgs.difftastic
    pkgs.fd
    pkgs.go
    pkgs.gopls
    pkgs.htop
    pkgs.hyperfine
    pkgs.nil
    pkgs.ripgrep
    pkgs.rustup
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
  ]);

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  # Managing bat here (rather than as a bare package) makes home-manager
  # rebuild bat's theme/syntax cache on every switch, so it never goes stale
  # across bat upgrades.
  programs.bat = {
    enable = true;
    config.theme = "Catppuccin Frappe";
  };

  programs.claude-code = let
    # Pinned instead of installed with `/plugin install`, so the MCP server and
    # skills only change when this rev does.
    unifi-mcp = pkgs.fetchFromGitHub {
      owner = "sirkirby";
      repo = "unifi-mcp";
      rev = "9493e7bb83dece24e4a4ac8adb1f4ad16f81e5ec";
      hash = "sha256-N4uLdSJ1YPyWSjwYjiNn0DKopGALnhbxieEs49WVjN4=";
    };
    unifiSkills = "${unifi-mcp}/plugins/unifi-network/skills";
  in {
    enable = true;

    # The upstream plugin reads its settings from `/plugin config`; setting the
    # env directly keeps it declarative. The password stays in 1Password,
    # outside the nix store, and is read through the app integration.
    mcpServers.unifi-network = {
      command = "${pkgs.uv}/bin/uvx";
      args = [ "unifi-network-mcp==0.43.1" ];
      env = {
        UNIFI_NETWORK_HOST = "10.1.0.1";
        UNIFI_NETWORK_USERNAME = "claude";
        UNIFI_NETWORK_PASSWORD_COMMAND = "/usr/local/bin/op read op://Claude/unifi-network-mcp/password";
        # Read-only until I trust it. Mutations would still preview first.
        UNIFI_POLICY_NETWORK_CREATE = "false";
        UNIFI_POLICY_NETWORK_UPDATE = "false";
        UNIFI_POLICY_NETWORK_DELETE = "false";
        UNIFI_NETWORK_TOOL_PERMISSION_MODE = "confirm";
      };
    };

    # The setup and support skills write config imperatively, so skip them.
    skills = {
      unifi-network = "${unifiSkills}/unifi-network";
      network-health-check = "${unifiSkills}/network-health-check";
      firewall-auditor = "${unifiSkills}/firewall-auditor";
      firewall-manager = "${unifiSkills}/firewall-manager";
    };
  };

  programs.eza = {
    enable = true;
    git = true;
    extraOptions = [ "--binary" "--group" ];
  };

  programs.fzf = {
    enable = true;

    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidget = {
      command = "fd --type f --hidden --exclude .git";
      # Only preview files in the Ctrl-T file picker; a global preview breaks
      # Ctrl-R history search, where {} is a command, not a file.
      options = [ "--preview 'bat --color=always --style=numbers {}'" ];
    };
    changeDirWidget.command = "fd --type d --hidden --exclude .git";
  };

  programs.gh = {
    enable = true;
    # Use gh as the git credential helper for github.com.
    gitCredentialHelper.enable = true;
    settings.aliases.co = "pr checkout";
  };

  # Installed via the homebrew cask (darwin.nix); home-manager only writes
  # the config.
  programs.ghostty = {
    enable = true;
    package = lib.mkIf isDarwin null;

    settings = {
      theme = "Catppuccin Frappe";
      font-family = "FiraCode Nerd Font Mono";
      # Zellij's default keybindings are Alt-based.
      macos-option-as-alt = true;
      # Shift+Enter inserts a newline in Claude Code (and other TUIs).
      keybind = [ "shift+enter=text:\\x1b\\r" ];
    };
  };

  programs.git = {
    enable = true;

    ignores = [ ".DS_Store" ];

    settings = {
      user.name = name;
      user.email = email;
      init.defaultBranch = "main";
    };
  };

  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings.theme = "sonokai_andromeda";
  };

  programs.jujutsu = {
    enable = true;

    settings = {
      user = { inherit name email; };
      ui = {
        default-command = "log";
        diff-formatter = [ "difft" "--color=always" "$left" "$right" ];
      };
    };
  };

  # Claude through opencode needs an Anthropic API key (Claude Pro/Max
  # subscriptions aren't usable in third-party tools). The key is kept out of
  # the nix store: run `opencode auth login` once and pick Anthropic.
  programs.opencode = {
    enable = true;

    settings = {
      model = "anthropic/claude-opus-5-5";
      small_model = "anthropic/claude-haiku-5-5";
    };
  };

  programs.starship = {
    enable = true;
  };

  programs.zellij = {
    enable = true;

    settings = {
      theme = "catppuccin-frappe";
      show_startup_tips = false;
    };
  };

  programs.zoxide = {
    enable = true;
    # Replace `cd` with zoxide (keeps `cd -`, completion, etc. working).
    options = [ "--cmd cd" ];
  };

  programs.zsh = {
    enable = true;
    autocd = false;
    autosuggestion.enable = true;
    defaultKeymap = "viins";
    enableCompletion = true;

    shellAliases = {
      cat = "bat";
      ls = "eza --long";
    };
  };
}
