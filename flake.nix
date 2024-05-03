{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };

        pam50-core = import ./pkgs/pam50.nix { inherit pkgs; };
        rSuggestsPackages = with pkgs.rPackages; [
          ggplot2
          tidyr
          ComplexHeatmap
          circlize
          rlang
        ];

        pam50-full =
          import ./pkgs/pam50.nix { inherit pkgs rSuggestsPackages; };

        rDevPackages = with pkgs.rPackages; [
          devtools
          roxygen2
          languageserver
          styler
          jsonlite
          caret
          forcats
        ];

        R-with-packages-dev =
          pkgs.rWrapper.override { packages = [ pam50-full rDevPackages ]; };

        utils-dev = with pkgs; [ busybox act ];
        dev-pkgs = [ R-with-packages-dev ] ++ utils-dev;

        R-with-pam50-core =
          pkgs.rWrapper.override { packages = [ pam50-core ]; };
        R-with-pam50-full =
          pkgs.rWrapper.override { packages = [ pam50-full ]; };

        base-contents = [ pkgs.gocryptfs pkgs.bash pkgs.busybox ];
        runscript = ''
          #!/usr/bin/env bash
          export LC_ALL=C.UTF-8
          Rscript --vanilla "\$@"
        '';

        sqfs-core = import ./pkgs/mkSquashfs.nix {
          inherit pkgs runscript;
          name = "pam50-core";
          contents = base-contents ++ [ R-with-pam50-core ];
        };
        sqfs-full = import ./pkgs/mkSquashfs.nix {
          inherit pkgs runscript;
          name = "pam50-full";
          contents = base-contents ++ [ R-with-pam50-full ];
        };

      in {
        formatter = pkgs.nixfmt;
        devShells.default = pkgs.mkShell { buildInputs = dev-pkgs; };
        devShells.test = pkgs.mkShell { buildInputs = [ R-with-pam50-full ]; };

        packages.sqfs-core = sqfs-core;
        packages.sqfs-full = sqfs-full;

        packages.pam50-core = pam50-core;
        packages.default = pam50-full;
      });
}
