{
  description = "Quarto development shell (Python, R, Julia, LaTeX)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        pythonEnv = pkgs.python3.withPackages (ps: with ps; [
          matplotlib
          numpy
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          name = "quarto-shell";

          buildInputs = [

            # Tools
            pkgs.quarto
            pkgs.julia
            pkgs.git
            pkgs.hut
            pkgs.gnutar

            # Python environment
            pythonEnv

            # R environment
            (pkgs.rWrapper.override {
              packages = with pkgs.rPackages; [
                DT
                IRkernel
                dplyr
                ggplot2
                knitr
                leaflet
                lubridate
                qrcode
                quarto
                readr
                reticulate
                sf
                stringi
              ];
            })

            # TexLive
            (pkgs.texlive.combine {
              inherit (pkgs.texlive)
                scheme-medium
                algorithms
                fontawesome5
                framed
                latexmk
                multirow
                pdfcol
                tcolorbox
                tikzfill;
            })

          ];

          shellHook = ''
            export JULIA_PROJECT=$PWD
            export JULIA_DEPOT_PATH=$PWD/.julia

            julia -e 'using Pkg; Pkg.instantiate()'

            echo "Quarto development shell ready"
            echo "Quarto        : $(quarto --version)"
            echo "Python        : $(python --version)"
            echo "R             : $(R --version | head -n 1)"
            echo "TexLive       : $(latex -version | head -n 1)"
            echo "Julia         : $(julia --version)"
            echo "Julia project : $JULIA_PROJECT"
            echo "Julia depot   : $JULIA_DEPOT_PATH"
          '';
        };
      }
    );
}

