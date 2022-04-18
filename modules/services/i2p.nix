{ ... }:

{
    services.i2pd = {
        enable = true;
        enableIPv6 = false;
        enableIPv4 = true;
        ifname = "wg0";
        proto = {
            socksProxy.enable = true;
            http.enable = true;
        };
    };
}
