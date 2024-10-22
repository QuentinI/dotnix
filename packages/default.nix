final: prev:

let
  activitywatch = final.pkgs.callPackage ./activitywatch { };
in
{
  inherit activitywatch;
}
