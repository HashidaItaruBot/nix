{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Linux specific packages
    # Most have been moved to common.nix
    
    # Keeping specific Linux GUI tools if any remain
    # telegram-desktop and code-cursor moved to common
  ];
}

