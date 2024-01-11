{ inputs, ... }@flakeContext:
let
homeModule = { config, lib, pkgs, ... }: {
    config = {
	    manual.manpages.enable = false;
        fonts.fontconfig.enable = true;
        home = {
            stateVersion = "23.11";
            packages = [
                pkgs.fontconfig
                (pkgs.nerdfonts.override { fonts = [ "Hack" ]; })
                pkgs.git
                pkgs.bat
                pkgs.eza
                pkgs.fzf
                pkgs.zsh
                pkgs.zsh-syntax-highlighting
                pkgs.zsh-autosuggestions
                pkgs.zsh-powerlevel10k
                pkgs.thefuck
                pkgs.warp-terminal
                pkgs.neovim
                pkgs.wrangler
                pkgs.fd
                pkgs.ripgrep
                pkgs.jq
                pkgs.yq
                pkgs.kubectl
                pkgs.wget
                pkgs.hugo
                pkgs.gnupg
                pkgs.gawk
                # asdf manages tooling versions via ./.tool-versions
                # we do not install any langs here
                pkgs.asdf-vm
                pkgs.stylua
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
                };
            };
        };
    };
};
nixosModule = { ... }: {
    home-manager.users.shane = homeModule;
};
in
(
 (
  inputs.home-manager.lib.homeManagerConfiguration {
  modules = [
  homeModule
  ];
  pkgs = inputs.nixpkgs.legacyPackages.aarch64-darwin;
  }
 ) // { inherit nixosModule; }
 )
