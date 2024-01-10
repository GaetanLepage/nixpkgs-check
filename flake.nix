{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];

      perSystem = {
        pkgs,
        config,
        system,
        ...
      }: {
        _module.args = {
          pkgs_ = import inputs.nixpkgs-master {
            inherit system;
            config.allowUnfree = true;
          };

          pkgs_cuda = import inputs.nixpkgs-master {
            inherit system;
            config = {
              allowUnfree = true;
              cudaSupport = true;
            };
          };
        };

        formatter = pkgs.alejandra;

        imports = [
          ./checks.nix
        ];
      };
    };
}
