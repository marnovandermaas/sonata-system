{
  description = "Sonata System";
  inputs = {
    lowrisc-nix.url = "github:lowRISC/lowrisc-nix";

    nixpkgs.follows = "lowrisc-nix/nixpkgs";
    flake-utils.follows = "lowrisc-nix/flake-utils";
    poetry2nix.follows = "lowrisc-nix/poetry2nix";
  };

  nixConfig = {
    extra-substituters = ["https://nix-cache.lowrisc.org/public/"];
    extra-trusted-public-keys = ["nix-cache.lowrisc.org-public-1:O6JLD0yXzaJDPiQW1meVu32JIDViuaPtGDfjlOopU7o="];
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    lowrisc-nix,
    ...
  } @ inputs: let
    system_outputs = system: let
      version = "0.0.1";

      pkgs = import nixpkgs {
        inherit system;
      };

      lrDoc = lowrisc-nix.lib.doc {inherit pkgs;};
      lrPkgs = lowrisc-nix.outputs.packages.${system};
      fs = pkgs.lib.fileset;

      pythonEnv = let
        poetry2nix = inputs.poetry2nix.lib.mkPoetry2Nix {inherit pkgs;};
        poetryOverrides = lowrisc-nix.lib.poetryOverrides {inherit pkgs;};
      in
        poetry2nix.mkPoetryEnv {
          projectDir = ./.;
          overrides = [
            poetryOverrides
            poetry2nix.defaultPoetryOverrides
          ];
        };

      sonata-documentation = lrDoc.buildMdbookSite {
        inherit version;
        pname = "sonata-documentation";
        src = fs.toSource {
          root = ./.;
          fileset = fs.unions [
            (lrDoc.standardMdbookFileset ./.)
            ./util/mdbook
            ./util/mdbook_wavejson.py
          ];
        };
      };

      cheriotPkgs = lowrisc-nix.outputs.devShells.${system}.cheriot.nativeBuildInputs;

      sonata-simulator-lint = pkgs.stdenvNoCC.mkDerivation {
        name = "sonta-simulator-lint";
        src = ./.;
        buildInputs = with pkgs; [libelf zlib];
        nativeBuildInputs = [pkgs.verilator pythonEnv];
        dontBuild = true;
        doCheck = true;
        checkPhase = ''
          HOME=$TMPDIR fusesoc --cores-root=. run \
            --target=lint --setup --build lowrisc:sonata:system \
            --verilator_options="+define+RVFI -j $NIX_BUILD_CORES"
        '';
        installPhase = "mkdir $out";
      };

      sonata-simulator = pkgs.stdenv.mkDerivation rec {
        inherit version;
        pname = "sonata-simulator";
        src = ./.;
        buildInputs = with pkgs; [libelf zlib];
        nativeBuildInputs = [pkgs.verilator pythonEnv];
        buildPhase = ''
          HOME=$TMPDIR fusesoc --cores-root=. run \
            --target=sim --setup --build lowrisc:sonata:system \
            --verilator_options="-j $NIX_BUILD_CORES" --make_options="-j $NIX_BUILD_CORES"
        '';
        installPhase = ''
          mkdir -p $out/bin/
          cp -r build/lowrisc_sonata_system_0/sim-verilator/Vtop_verilator $out/bin/${pname}
        '';
        meta.mainProgram = pname;
      };

      sonata-sim-boot-stub = pkgs.stdenv.mkDerivation rec {
        inherit version;
        pname = "sonata-sim-boot-stub";
        src = sw/cheri/sim_boot_stub/.;
        nativeBuildInputs = cheriotPkgs;
        buildPhase = ''
          make
        '';
        installPhase = ''
          mkdir -p $out/share/
          cp -r sim_boot_stub $out/share
        '';
      };
    in {
      formatter = pkgs.alejandra;
      devShells.default = pkgs.mkShell {
        name = "sonata-system-devshell";
        packages =
          (with pkgs; [
            cmake
            screen
            picocom
            srecord
            gtkwave
            openfpgaloader
            openocd
          ])
          ++ (with lrPkgs; [
            uf2conv
            # For legacy software
            lowrisc-toolchain-gcc-rv32imcb
          ])
          ++ (with sonata-simulator; buildInputs ++ nativeBuildInputs);
      };
      packages = {inherit sonata-simulator sonata-sim-boot-stub sonata-documentation;};
      checks = {inherit sonata-simulator-lint;};
    };
  in
    flake-utils.lib.eachDefaultSystem system_outputs;
}
