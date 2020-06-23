self: super:

{
  grin-wallet = super.rustPlatform.buildRustPackage rec {
    pname = "grin-wallet-${version}";
    version = "3.1.1";

    src = super.fetchFromGitHub {
      owner = "mimblewimble";
      repo = "grin-wallet";
      rev = "v${version}";
      sha256 = "07aicgq0fm0z2mb8nxgh2w6wgzn41s508xl6pdlzsp5a43cq5pa2";
    };

    LIBCLANG_PATH = "${super.llvmPackages.libclang}/lib";
    LIBRARY_PATH = "${super.llvmPackages.libcxx}/include/c++/v1";

    nativeBuildInputs = [ super.pkg-config super.llvmPackages.libclang super.llvmPackages.libcxx ];

    buildInputs = [  super.openssl ];

    cargoSha256 = "04q7nn9h126ms9s90ap48xi74ypnzgyibjrj4xwa75w9h77id6zh";

    meta = with super.stdenv.lib; {
      description = "";
      homepage = "grin.mw";
      platforms = platforms.all;
    };
  };
}
