{ inputs
, config
, lib
, pkgs
, ...
}:

{
  imports = [
    inputs.microvm.nixosModules.host
  ];

  # 定义OpenClaw MicroVM
  microvm.vms.openclaw = {
    # 自动启动
    autostart = true;

    # MicroVM配置
    config = {
      imports = [
        inputs.microvm.nixosModules.microvm
        inputs.nix-openclaw.nixosModules.openclaw-gateway
        ./openclaw.nix
      ];

      # 添加overlay
      nixpkgs.overlays = [
        inputs.nix-openclaw.overlays.default
      ];
    };
  };
}

