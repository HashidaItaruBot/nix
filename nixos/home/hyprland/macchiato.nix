# Catppuccin Macchiato 颜色变量
# 来源: XNM1/linux-nixos-hyprland-config-dotfiles
# 用于 Hyprland、hyprlock、GTK/Qt 统一配色
{
  catppuccin = {
    # ---- 调色板 ----
    rosewater = "rgb(f4dbd6)";
    flamingo = "rgb(f0c6c6)";
    pink = "rgb(f5bde6)";
    mauve = "rgb(c6a0f6)";
    red = "rgb(ed8796)";
    maroon = "rgb(ee99a0)";
    peach = "rgb(f5a97f)";
    yellow = "rgb(eed49f)";
    green = "rgb(a6da95)";
    teal = "rgb(8bd5ca)";
    sky = "rgb(91d7e3)";
    sapphire = "rgb(7dc4e4)";
    blue = "rgb(8aadf4)";
    lavender = "rgb(b7bdf8)";

    # ---- 文本层级 ----
    text = "rgb(cad3f5)";
    subtext1 = "rgb(b8c0e0)";
    subtext0 = "rgb(a5adcb)";

    # ---- 叠加层 ----
    overlay2 = "rgb(939ab7)";
    overlay1 = "rgb(8087a2)";
    overlay0 = "rgb(6e738d)";

    # ---- 表面层 ----
    surface2 = "rgb(5b6078)";
    surface1 = "rgb(494d64)";
    surface0 = "rgb(363a4f)";

    # ---- 基础层 ----
    base = "rgb(24273a)";
    mantle = "rgb(1e2030)";
    crust = "rgb(181926)";

    # ---- Alpha 通道（用于 rgba() 拼接）----
    tealAlpha = "8bd5ca";
    baseAlpha = "24273a";
  };
}
