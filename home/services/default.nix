{ config, pkgs, ... }:

{
  imports = [
       ./kdeconnect
       ./gpg-agent
       ./shadowsocks
       ./unclutter
       ./nm-applet
       ./udiskie
       ./memory
       ./keybase
       ./syncthing
  ];
}
