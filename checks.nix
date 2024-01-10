{
  system,
  lib,
  pkgs_,
  pkgs_cuda,
  ...
}: let
  isPackage = p: (lib.isDerivation p) || (lib.isStorePath p);

  rawPackages = import ./packages.nix pkgs_;
  rawPackagesWithCuda =
    lib.filter
    (
      p:
        (lib.isAttrs p)
        && (p.cuda or false)
    )
    (import ./packages.nix pkgs_cuda);

  mkPackages = pkgs: let
    listOfAttrs = map (p:
      if isPackage p
      then {package = p;}
      else p)
    pkgs;
    filteredPackages =
      lib.filter
      (
        p:
          (
            if p ? systems
            then lib.elem system p.systems
            else true
          )
          && (p.package.meta.broken == false)
      )
      listOfAttrs;
  in
    map
    (p: p.package)
    filteredPackages;
in {
  checks = {
    normal = pkgs_.symlinkJoin {
      name = "normal";
      paths = mkPackages rawPackages;
    };

    cuda = pkgs_cuda.symlinkJoin {
      name = "cuda";
      paths = mkPackages rawPackagesWithCuda;
    };
  };
}
