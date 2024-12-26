{ secrets, hostname, ... }:
{
  services.spotifyd = {
    enable = true;
    settings = {
      global = {
        backend = "pulseaudio";
        device = hostname;
        username = secrets.spotify.user;
        password = secrets.spotify.password;
      };
    };
  };
}
