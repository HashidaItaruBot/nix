{pkgs, ...}: {
  # Auto-switch fcitx5: English in Normal, restore previous IM in Insert.
  extraPlugins = with pkgs.vimPlugins; [
    im-select-nvim
  ];

  extraConfigLua = ''
    require("im_select").setup({
      -- Normal / CmdlineLeave: force English US keyboard
      default_im_select = "keyboard-us",
      default_command = "fcitx5-remote",
      set_default_events = { "InsertLeave", "CmdlineLeave" },
      -- InsertEnter: restore the IM used before leaving Insert
      set_previous_events = { "InsertEnter" },
      async_switch_im = true,
    })
  '';
}
