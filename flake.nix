{
    description = "hcabel's NixOS configuration";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
        home-manager = {
            url = "github:nix-community/home-manager/release-26.05";
            inputs.nixpkgs.follows = "nixpkgs";
        };
        sops-nix = {
            url = "github:Mic92/sops-nix";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };

    outputs = { self, nixpkgs, home-manager, ... }@inputs:
        let
            system = "x86_64-linux";
            pkgs = import nixpkgs {
                inherit system;
                config.allowUnfree = true;
            };

            mkHost = extraModules: nixpkgs.lib.nixosSystem
            {
                inherit system;
                specialArgs = { inherit inputs; };
                modules = [
                    ./hosts/msi-laptop
                    home-manager.nixosModules.home-manager
                    # sops self-contained in modules/home/secret.nix
                    {
                        home-manager = {
                            useGlobalPkgs = true;
                            useUserPackages = true;
                            backupFileExtension = "hm-bak";
                            extraSpecialArgs = { };
                            users.hcabel = import ./home;
                        };
                    }
                ]
                ++ extraModules;
            };
    in {
        nixosConfigurations.msi-laptop = mkHost [ ];

        devShells.${system}.default = pkgs.mkShell {
            packages = with pkgs; [
                nixd # LSP
                nixfmt # Formatting
                sops
                age
                ssh-to-age
                nixos-option
            ];
        };
    };
}
