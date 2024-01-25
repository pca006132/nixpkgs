{ lib
, clangStdenv
, fetchFromGitHub
, cmake
, ninja
, pkg-config
, bison
, boost
, cairo
, cgal_5
, clipper2
, cudaPackages
, double-conversion
, eigen
, flex
, fontconfig
, freetype
, glib
, glm
, gmp
, harfbuzz
, hidapi
, lib3mf
, libGL
, libGLU
, libICE
, libSM
, libsForQt5
, libspnav
, libzip
, mpfr
, python3
, qscintilla
, tbb_2021_8
, wayland
, wayland-protocols
}:
let date = "2024-01-22"; in
# clang consume much less RAM than GCC
clangStdenv.mkDerivation {
  pname = "openscad-unstable";
  version = date;
  src = fetchFromGitHub {
    owner = "openscad";
    repo = "openscad";
    rev = "88d244aed3c40a76194ff537ed84bd65bc0e1aeb";
    hash = "sha256-qkQNbYhmOxF14zm+eCcwe9asLOEciYBANefUb8+KNEI=";
    fetchSubmodules = true;
  };
  nativeBuildInputs = [
    pkg-config
    cmake
    ninja
    bison
    flex
    python3
    libsForQt5.qt5.wrapQtAppsHook
  ];
  buildInputs = with libsForQt5.qt5; [
    # manifold dependencies
    clipper2
    cudaPackages.cuda_cccl
    glm
    tbb_2021_8

    boost
    cairo
    cgal_5
    double-conversion
    eigen
    fontconfig
    freetype
    glib
    gmp
    harfbuzz
    hidapi
    lib3mf
    libspnav
    libzip
    mpfr
    qscintilla
    qtbase
    qtmultimedia
  ]
  ++ lib.optionals clangStdenv.isLinux [ libICE libSM libGLU libGL wayland wayland-protocols qtwayland ]
  ++ lib.optional clangStdenv.isDarwin qtmacextras
  ;
  cmakeFlags = [
    "-DEXPERIMENTAL=ON" # enable experimental options
    "-DSNAPSHOT=ON" # nightly icons
    "-DUSE_BUILTIN_OPENCSG=ON" # bundled latest opencsg
    "-DOPENSCAD_VERSION=\"${builtins.replaceStrings ["-"] ["."] date}\""
    "-DCMAKE_UNITY_BUILD=ON" # faster build
    "-DENABLE_TESTS=OFF" # tests do not work for now
  ];
  meta = with lib; {
    description = "3D parametric model compiler (nightly)";
    longDescription = ''
      OpenSCAD is a software for creating solid 3D CAD objects. It is free
      software and available for Linux/UNIX, MS Windows and macOS.

      Unlike most free software for creating 3D models (such as the famous
      application Blender) it does not focus on the artistic aspects of 3D
      modelling but instead on the CAD aspects. Thus it might be the
      application you are looking for when you are planning to create 3D models of
      machine parts but pretty sure is not what you are looking for when you are more
      interested in creating computer-animated movies.
    '';
    homepage = "https://openscad.org/";
    # note that the *binary license* is gpl3 due to CGAL
    license = lib.licenses.gpl3;
    platforms = lib.platforms.unix;
    maintainers = with lib.maintainers; [ pca006132 ];
    mainProgram = "openscad";
  };
}
