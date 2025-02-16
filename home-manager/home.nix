# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: let
  vimrcRepo = builtins.fetchGit {
      url = "https://github.com/ianmkim/vimrc";
      rev = "55370c21bd2b2d304d0665df3e06c5c5e210cf25";
      submodules = true;
    };
    nvimrcRepo = builtins.fetchGit {
        url = "https://github.com/ianmkim/nvim-config.git";
        rev = "867fde7e34397037d3e6c37910364e2d56c49de8";
        submodules = true;
    };
in {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    # ./nvim.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
    };
  };

  # TODO: Set your username
  home = {
    username = "adrian";
    homeDirectory = "/home/adrian";
  };

  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    neovim
    steam
    ibm-plex
    tmux
    ack
    lazygit
    python312Full
    python312Packages.pip
    rustup
    gcc
    btop
  ];

  home.sessionVariables = {
      TERMINFO_DIRS = "${pkgs.kitty.terminfo.outPath}/share/terminfo";
  };

  # Add Vim and amix/vimrc configuration
  programs.vim.packageConfigurable = {
    enable = true;
  };

  programs.kitty = {
      enable = true;
  };

  # Fetch amix/vimrc repository
  # Clone amix/vimrc repository into ~/.vim_runtime
  home.file.".vim_runtime".source = vimrcRepo;

  home.file.".config/nvim".source = nvimrcRepo;

  # Set up .vimrc to source amix/vimrc
  home.file.".vimrc".text = ''
    set runtimepath+=~/.vim_runtime
    source ~/.vim_runtime/vimrcs/basic.vim
    source ~/.vim_runtime/vimrcs/filetypes.vim
    source ~/.vim_runtime/vimrcs/plugins_config.vim
    source ~/.vim_runtime/vimrcs/extended.vim
  '';


  # add shell configuration
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;

    oh-my-zsh = {
       enable = true;
      plugins = ["git"];
      theme = "candy";
    };

    shellAliases = {
      ll = "ls -l";
    };
  };

  # add tmux configuration
  programs.tmux = {
      enable = true;
      extraConfig = ''
      set -g default-terminal "screen-256color"

      # turn on mouse support
      set-option -g mouse on
      set -g @scroll-speed-num-lines-per-scroll "1"

      # update prefix hotkey
      set-option -g prefix C-a
      bind-key C-a send-prefix

      # update pane-split keys
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # update pane switching
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # update alternate pane switching with Alt
      # for mac, preference > profile > keyboard
      # and use Option as Meta key
      bind -n M-h select-pane -L
      bind -n M-j select-pane -D
      bind -n M-k select-pane -U
      bind -n M-l select-pane -R

      # reload config file
      bind r source-file ~/.tmux.conf \; display "reloaded tmux configuration"

      # shorten command delay
      set -g escape-time 1

      # set window and pane base index to 1
      set-option -g base-index 1
      setw -g pane-base-index 1

      # make the current window first window
      bind T swap-window -t 1

      # update history to 10k
      set -g history-limit 10000

      # swap windows
      bind -r > swap-window -t +1
      bind -r < swap-window -t -1

      # switch windows
      bind -r ] select-window -t :+
      bind -r [ select-window -t :-

      ## Theme (ix.i0/V5C)

      # panes
      set -g pane-border-style fg=black
      set -g pane-active-border-style fg=colour8

      # toggle statusbar
      bind-key b set-option status

      # status line
      set -g status-justify left
      set -g status-bg colour16
      set -g status-fg colour16
      set -g status-interval 2

      # messaging
      set -g automatic-rename on

      # colors
      setw -g window-status-format "#[fg=colour3] •#[fg=colour8] #W "
      setw -g window-status-current-format "#[fg=colour2] •#[fg=colour7] #W "
      set -g status-position bottom
      set -g status-justify centre
      set -g status-left "  #[fg=colour3]• #[fg=colour2]• #[fg=colour4]•"
      set -g status-right " #[fg=colour4] •#[fg=colour8] #S  "


      # plugins
      set -g @plugin 'tmux-plugins/tmux-copycat'

      # initialize plugin manager
      run '~/.tmux/plugins/tpm/tpm'
      '';
  };

  # Enable home-manager and git
  programs.home-manager.enable = true;

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "23.05";
}
