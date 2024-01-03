{
  description = "Sonata System";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    lowrisc-nix.url = "github:lowRISC/lowrisc-nix";
    nixpkgs.follows = "lowrisc-nix/nixpkgs";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    lowrisc-nix,
  }: let
    system_outputs = system: let
      sonata_version = "0.0.1";

      pkgs = import nixpkgs {
        inherit system;
      };
      lr_pkgs = lowrisc-nix.outputs.packages.${system};

      sim_build_deps =
        (with pkgs; [libelf zlib python311Packages.pip])
        ++ (with lr_pkgs; [python_ot verilator_ot]);

      sonata_simulator = pkgs.stdenv.mkDerivation {
        pname = "sonata-system-simulator";
        version = sonata_version;
        src = builtins.path {path = ./.;};
        nativeBuildInputs = sim_build_deps;
        buildPhase = ''
          export HOME=$(mktemp -d)
          fusesoc --cores-root=. run --target=sim --tool=verilator --setup \
            --build lowrisc:sonata:system
        '';
        installPhase = ''
          mkdir -p $out/bin/
          cp -r build/lowrisc_sonata_system_0/sim-verilator/Vsonata_system $out/bin/
        '';
      };
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        packages = sim_build_deps ++ [pkgs.gtkwave];
      };
      packages = {inherit sonata_simulator;};
    };
  in
    flake-utils.lib.eachDefaultSystem system_outputs;
}
