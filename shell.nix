{ pkgs ? import <nixpkgs> {} }:

with pkgs;

let
  pythonEnv = python3.withPackages (ps: with ps; [
    matplotlib
    numpy
  ]);
in

mkShell {
  name = "quarto-shell";

  buildInputs = [
    pythonEnv

    (rWrapper.override {
      packages = with rPackages; [
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

    (texlive.combine { inherit (texlive)
      scheme-medium
      algorithms
      fontawesome5
      framed
      latexmk
      multirow
      pdfcol
      tcolorbox
      tikzfill
      ;
    })

    quarto
    julia
    git
    hut
    gnutar
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
}

