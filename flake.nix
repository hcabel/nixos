{
  description = "hcabel's NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
   };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ... 
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.msi-laptop = 
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/msi-laptop
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "hm-bak";
                extraSpecialArgs = { inherit inputs; };
                users.hcabel = ./home.nix;
              };
            }
          ];
        };
    };
}
