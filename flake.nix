{
  description = "Dusty's NixOS configuration";



  inputs = {
    nvidia-patch.url = "github:icewind1991/nvidia-patch-nixos";  
    nvidia-patch.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
#    nixpkgs.url = "github:Continous/nixpkgs/decora-wifi";
    stablepkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nix-citizen.url = "github:LovingMelody/nix-citizen";
    nix-gaming.url = "github:fufexan/nix-gaming";
# 　nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
#   kde2nix.url = "github:nix-community/kde2nix";
    #sops-nix.url = "github:Mix92/sops-nix";
    # ... other inputs ...
  };

  outputs = { self, nixpkgs, stablepkgs, nix-citizen, ... }@inputs:

	let
	system = "x86_64-linux";
	in
{
    nixosConfigurations.NixOS = nixpkgs.lib.nixosSystem {
	#Define package sets
      inherit system;
      #nix-citizen = inputs.nix-citizen.legacyPackages;
      specialArgs = {
	inherit inputs;
	inherit system;
	nixpkgs.config.allowUnfree = true;
	};
      modules = [
        # Apply overlays
        ({ pkgs, ... }: {
          nixpkgs.overlays = [ 
	inputs.nvidia-patch.overlays.default 
#	(import ./opencvisbroke.nix)
        (final: prev: {
	stable = import stablepkgs {
				inherit system;
				config.allowUnfree = true;
		};
	})
	];
	})
        ./configuration.nix # For generic configuration of the System.
        ./packages.nix # For declaration of packages not associated with any other programs.
        ./hardware-configuration.nix # Auto-generated Hardware Configuration
        ./bootloader.nix # Bootloader configuration.
        ./networking-and-servers.nix
	    ./syncthing/core.nix
        #sops-nix.nixosModules.sops
        # ... other modules ...
      ];
    };
  };
}
