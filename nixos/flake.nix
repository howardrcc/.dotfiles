{
  description = "Howard's NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    # For the few packages that should track the latest release (e.g. sunshine).
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell/stable";
      # DMS tracks unstable (needs newer Go than the stable channel ships).
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    claude-code.url = "github:sadjow/claude-code-nix";
  # pin it to your nixpkgs to avoid a second nixpkgs eval (optional but tidy):
    claude-code.inputs.nixpkgs.follows = "nixpkgs";

    codex-cli.url = "github:sadjow/codex-cli-nix";
    codex-cli.inputs.nixpkgs.follows = "nixpkgs";

    # Agent skills, linked into ~/.claude/skills and ~/.codex/skills (see home.nix).
    poteto-plugins = { url = "github:poteto/plugins"; flake = false; };
    mattpocock-skills = { url = "github:mattpocock/skills"; flake = false; };

  };

  outputs = inputs@ { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        pkgs-unstable = import inputs.nixpkgs-unstable {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
      };
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.howie = import ./home.nix;
        }
      ];
    };
  };
}
