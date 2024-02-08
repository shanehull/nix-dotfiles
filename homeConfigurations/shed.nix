{inputs, ...} @ flakeContext: let
  system = "aarch64-darwin"; # Use "x86_64-darwin" if you are on an Intel Mac
  pkgs = inputs.nixpkgs.legacyPackages.${system};

  makeGitHubReleasePackage = import ./make-github-release-package.nix {inherit pkgs;};

  quickval = makeGitHubReleasePackage {
    pname = "quickval";
    fname = "quickval-darwin-arm64";
    version = "latest";
    repo = "quickval";
    owner = "shanehull";
    sha256 = "sha256-Pxtz5kFfZt24PG6Z19N9obm2mCXwB8z/qdptPqmkZ1o=";
  };
  shed = makeGitHubReleasePackage {
    pname = "shed";
    fname = "shed-darwin-arm64";
    version = "latest";
    repo = "shed";
    owner = "shanehull";
    sha256 = "sha256-LeiD7MamIMUdgJh4YfQJT4yDrMnxxrgPh4j06JB8L0A=";
  };

  homeModule = {
    config,
    lib,
    pkgs,
    ...
  }: {
    config = {
      manual.manpages.enable = false;
      fonts.fontconfig.enable = true;
      home = {
        stateVersion = "23.11";
        packages = with pkgs; [
          # asdf manages tooling versions via ./.tool-versions
          # we do not install any langs here
          asdf-vm

          # custom packages defined above
          shed
          quickval

          # all other packages
          fontconfig
          (nerdfonts.override {fonts = ["Hack"];})
          git

          # cli tools
          bat
          tree
          eza
          fzf
          fd
          gawk
          thefuck
          ripgrep
          jq
          yq
          wget

          # zsh and plugins
          zsh
          zsh-syntax-highlighting
          zsh-autosuggestions
          zsh-powerlevel10k

          # terminal and editor
          warp-terminal
          neovim

          # k8s tools
          k9s

          # language tools
          terraform-ls
          tflint
          gopls
          gotools
          golines
          golangci-lint
          stylua
          prettierd
          eslint_d
          pandoc
          statix
          alejandra

          # other
          gnupg
          ollama
        ];
      };
      programs = {
        home-manager = {
          enable = true;
        };
        git = {
          enable = true;
          extraConfig = {
            init.defaultBranch = "main";
            push.autoSetupRemote = true;
            pull.ff = "only";
          };
        };
        bat = {
          enable = true;
          config = {
            theme = "TwoDark";
            pager = "less -FR";
          };
        };
        eza = {
          enable = true;
          enableAliases = true;
        };
        fzf = {
          enable = true;
          enableBashIntegration = true;
          enableZshIntegration = true;
        };
        zsh = {
          enable = true;
          initExtra = ''
            # Powerlevel10k Zsh theme
            source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
            test -f ~/.config/zsh/.p10k.zsh && source ~/.config/zsh/.p10k.zsh

            # asdf init
            ASDF_DIR="${pkgs.asdf-vm}"/share/asdf-vm
            . ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh

            # homebrew path
            eval "$(/opt/homebrew/bin/brew shellenv)"

            # go path
            export PATH=$PATH:$(go env GOPATH)/bin

            # second brain dir
            export SECOND_BRAIN=$HOME/secondbrain
          '';
          plugins = [
            {
              name = "powerlevel10k-config";
              src = lib.cleanSource ./p10k-config;
              file = ".p10k.zsh";
            }
          ];
          oh-my-zsh = {
            enable = true;
            plugins = [
              "macos"
              "git"
              "thefuck"
              "kubectl"
              "asdf"
              "dotenv"
              "terraform"
            ];
          };
          shellAliases = {
            "v" = "nvim";
            "vim" = "nvim";
            "cat" = "bat";
            "ccat" = "bat --plain";
            "brain" = "cd $SECOND_BRAIN";
            "zet" = "shed zet";
            "checkcrt" = "shed checkcrt";
          };
        };
      };
    };
  };
  nixosModule = {...}: {
    home-manager.users.shane = homeModule;
  };
in
  inputs.home-manager.lib.homeManagerConfiguration {
    modules = [
      homeModule
    ];
    pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
  }
  // {inherit nixosModule;}
