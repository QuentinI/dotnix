{ config, pkgs, ... }:

{
  services.jupyter = {
    enable = true;
    kernels = {
      python3 = let
        env = (pkgs.python3.withPackages (pythonPackages:
          with pythonPackages; [
            ipykernel
            matplotlib
            pandas
            scikitlearn
          ]));
      in {
        displayName = "Python";
        argv = [
          "${env.interpreter}"
          "-m"
          "ipykernel_launcher"
          "-f"
          "{connection_file}"
        ];
        language = "python";
      };
    };
    password = "'sha1:45cc773e0113:b45021322f80c33a637a962aee12e525ff08c938'";
  };
}
