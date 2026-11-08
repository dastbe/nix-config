{ lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  name = "David Bell";
  email = "dastbe@gmail.com";
in {
  imports = [ ./home/neovim ];

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

  # Machine-wide Bazel settings, read before each workspace's .bazelrc. Half
  # the cores, so the machine stays usable while Bazel builds and tests.
  home.file.".bazelrc".text = ''
    common --local_resources=cpu=HOST_CPUS*.5
    common --jobs=HOST_CPUS*.5
  '';

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
    # Off for now: every session starts its own server, and each one asks
    # 1Password for CLI access. Flip back once it reads a service account.
    enableUnifi = false;

    # Model, directory, the jj change at @, and subscription usage. Claude
    # Code pipes session JSON on stdin; rate_limits only appears for
    # subscribers, after the first response, so each piece is optional.
    statusline = pkgs.writeShellApplication {
      name = "claude-statusline";
      runtimeInputs = [ pkgs.jq pkgs.jujutsu ];
      text = ''
        model="" dir="" five="" five_reset="" week=""
        eval "$(jq -r '@sh "
          model=\(.model.display_name // "")
          dir=\(.workspace.current_dir // .cwd // "")
          five=\(.rate_limits.five_hour.used_percentage // "" | if . == "" then . else round end)
          five_reset=\(.rate_limits.five_hour.resets_at // "")
          week=\(.rate_limits.seven_day.used_percentage // "" | if . == "" then . else round end)
        "')"

        dim=$'\e[2m' reset=$'\e[0m'

        # Green under half, yellow under 80%, red beyond.
        usage() {
          local color=$'\e[32m'
          if (( $2 >= 80 )); then color=$'\e[31m'; elif (( $2 >= 50 )); then color=$'\e[33m'; fi
          printf '%s%s %s%%%s' "$dim" "$1" "$color$2" "$reset"
        }

        # --ignore-working-copy: don't snapshot on every refresh.
        change=$(cd "$dir" 2>/dev/null && jj log -r @ --no-graph --color never \
          --ignore-working-copy \
          -T 'change_id.shortest(8) ++ " " ++ coalesce(description.first_line(), "(no description)")' \
          2>/dev/null) || change=""

        out="$model  ''${dir/#"$HOME"/\~}"
        if [[ -n $change ]]; then out+="  $dim''${change%% *}$reset ''${change#* }"; fi
        if [[ -n $five ]]; then
          out+="  $(usage 5h "$five")"
          if [[ -n $five_reset ]]; then out+="$dim ↻$(date -r "$five_reset" +%H:%M)$reset"; fi
        fi
        if [[ -n $week ]]; then out+="  $(usage 7d "$week")"; fi
        printf '%s' "$out"
      '';
    };
  in {
    enable = true;

    # Written to ~/.claude/CLAUDE.md, which Claude Code loads in every repo.
    context = ./agent-conventions.md;

    settings = {
      theme = "dark";
      # Sessions work in per-session jj workspaces here (see
      # agent-conventions.md), whichever checkout they started in.
      permissions.additionalDirectories = [ "~/workplace/claude" ];

      statusLine = {
        type = "command";
        command = lib.getExe statusline;
      };

      # What `rex skill setup` would add, if settings.json weren't in the
      # store. Tells each session which Rex session and block it runs in.
      # Keep the command verbatim so `rex skill status` reports it current.
      hooks.SessionStart = [{
        hooks = [{
          type = "command";
          command = "/bin/sh -c 'rex __internal session-start --agent claude --feature-session-naming=false 2>/dev/null || true'";
          timeout = 5;
        }];
      }];
    };

    # The upstream plugin reads its settings from `/plugin config`; setting the
    # env directly keeps it declarative. The password stays in 1Password,
    # outside the nix store, and is read through the app integration.
    mcpServers.unifi-network = lib.mkIf enableUnifi {
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
    skills = lib.mkIf enableUnifi {
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
      # Colocate new repos and workspaces with Git, so git-aware tooling
      # works in them (agent workspaces rely on this).
      git.colocate = true;
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

    # Rex prepends its bin dir to PATH in its terminals, but nix-darwin's
    # /etc/zshenv resets PATH. Put it back so `rex` (and the Claude Code
    # hook and skill that call it) resolve inside Rex.
    envExtra = ''
      if [[ -n "''${REX_BIN_DIR-}" ]]; then
        path=("$REX_BIN_DIR" $path)
      fi
    '';

    shellAliases = {
      cat = "bat";
      ls = "eza --long";
    };
  };
}
