{ inputs, ... }:
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "hm-bak";   # rename clashing files instead of failing
    extraSpecialArgs = { inherit inputs; };
    users.eriskii = import ../home/eriskii.nix;
  };
}
