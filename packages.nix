pkgs:
with pkgs; (
  [
    hello
  ]
  ++ (with python3Packages; [
    {
      package = torch;
      cuda = true;
    }
  ])
)
