{ config, pkgs, ...}:

{
    systemd.user.services.ssh-agent = {
        Install = {
            WantedBy = [ "default.target" ]; 
            # Description = "SSH Agent";
        };
        Service = {
            ExecStartPre = "${pkgs.coreutils}/bin/rm -f %t/ssh-agent";
            ExecStart = "${pkgs.openssh}/bin/ssh-agent -a %t/ssh-agent";
            StandardOutput = "null";
            Type = "forking";
            Restart = "on-failure";
            SuccessExitStatus = "0 2";
        };
        # Allow ssh-agent to ask for confirmation. This requires the
        # unit to know about the user's $DISPLAY (via ‘systemctl
        # import-environment’).
        # environment.SSH_ASKPASS = optionalString config.services.xserver.enable askPasswordWrapper;
        # environment.DISPLAY = "fake"; # required to make ssh-agent start $SSH_ASKPASS
    };
}
