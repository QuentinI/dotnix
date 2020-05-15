self: super:

{
  yeetgif = super.buildGoPackage rec {
    pname = "yeetgif-${version}";
    version = "1.23.5";

    goPackagePath = "github.com/sgreben/yeetgif";
    subPackages = [ "cmd/gif" ];

    src = super.fetchFromGitHub {
      owner = "sgreben";
      repo = "yeetgif";
      rev = "${version}";
      sha256 = "1yz4pps8g378lvmi92cnci6msjj7fprp9bxqmnsyn6lqw7s2wb47";
    };

    modSha256 =
      "842690a705e339d8211a06755acce2923de18dd511bc28830bc6e967f33d31f6";
  };
}
