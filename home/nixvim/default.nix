{inputs, ...}: {
  imports = [
    inputs.nixvim.homeModules.nixvim
  ];

  programs.nixvim = {
    enable = true;

    # nixvim instantiates its own nixpkgs; system allowUnfree does not apply.
    nixpkgs.config.allowUnfree = true;

    imports = [
      ./config
    ];
  };
}
