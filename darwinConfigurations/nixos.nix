{ inputs, ... }@flakeContext:
let
darwinModule = { config, lib, pkgs, ... }: {
    imports = [
        inputs.home-manager.darwinModules.home-manager
            inputs.self.homeConfigurations.shed.nixosModule
            {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                nixpkgs = { config = { allowUnfree = true; }; };
            }
    ];
    config = {
        documentation = {
            doc = {
                enable = false;
            };
        };
        nix = {
            extraOptions = ''
                experimental-features = nix-command flakes
                '';
        };
        programs = {
            zsh = {
                enable = true;
            };
        };
        services = {
            nix-daemon = {
                enable = true;
            };
        };
        users = {
            users.shane.home = "/Users/shane";
        };
        system = {
            stateVersion = 4;
            defaults = {
                dock = {
                    autohide = true;
                    show-recents = false;
                };
            };
        };
        environment = {
            shells = [ pkgs.bash pkgs.zsh ];
            loginShell = pkgs.zsh;
            systemPackages = [ pkgs.coreutils ];
        };
        homebrew = {
            enable = true;
            onActivation.autoUpdate = true;
            casks = [ "warp" "multipass" ];
        };
    };
};
in
inputs.nix-darwin.lib.darwinSystem {
    modules = [
        darwinModule
    ];
    system = "aarch64-darwin";
}
