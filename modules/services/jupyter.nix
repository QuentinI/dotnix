{
  pkgs,
  secrets,
  ...
}:

{
  services.jupyter =
    if builtins.hasAttr "jupyter-password" secrets then
      {
        enable = true;
        kernels = {
          python3 =
            let
              env = pkgs.python3.withPackages (
                pythonPackages: with pythonPackages; [
                  ipykernel
                  matplotlib
                  pandas
                  scikitlearn
                ]
              );
            in
            {
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
        password = secrets.jupyter-password;
      }
    else
      pkgs.lib.warn "Jupyter service is enabled, but `secrets.jupyter-password` is not set, disabling"
        { };
  # WORKAROUND for some bug
  users.users."jupyter".isNormalUser = true;
}
