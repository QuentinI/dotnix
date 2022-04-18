_:

{
  # Turn off NixOS boot messages
  boot.initrd.verbose = false;

  # Turn off kernel messages
  boot.consoleLogLevel = 0;
  boot.kernel.sysctl."printk" = "3 3 3 3";
  boot.kernelParams =
    [ "quiet" "udev.log_priority=3" "rd.systemd.show_status=auto" ];
}
