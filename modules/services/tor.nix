{ ... }:

{
    services.tor = {
        enable = true;
        client = {
            enable = true;
        };
        settings = {
            ExitNodes = "{de}";
        };
    };
}
