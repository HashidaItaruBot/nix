# Custom nixvim plugins

Add your own nixvim module files here and import them from `plugins/default.nix`.

Do not edit files under `plugins/kickstart/` for personal plugins — keep customizations in this directory.

## 1. Nixvim built-in plugins (recommended)

Use when nixvim already wraps the plugin:

```nix
# plugins/custom/noice.nix
{
  plugins.noice = {
    enable = true;
    settings.lsp.override = {
      "vim.lsp.util.convert_input_to_markdown_lines" = true;
      "vim.lsp.util.stylize_markdown" = true;
      "cmp.entry.get_documentation" = true;
    };
  };
}
```

Then in `plugins/default.nix`:

```nix
./custom/noice.nix
```

## 2. extraPlugins (unwrapped vim plugins)

Use when the plugin exists in `pkgs.vimPlugins` but has no nixvim module:

```nix
# plugins/custom/example.nix
{pkgs, ...}: {
  extraPlugins = with pkgs.vimPlugins; [
    some-vim-plugin
  ];

  extraConfigLua = ''
    require('some-vim-plugin').setup {}
  '';
}
```

## 3. extraConfigLua / extraConfigLuaPost

Use for global Lua setup or tweaks that do not need a separate plugin file:

```nix
# plugins/custom/init.nix
{
  extraConfigLuaPost = ''
    vim.opt.relativenumber = true
  '';
}
```

## References

- https://nix-community.github.io/nixvim/
- https://github.com/JMartJonesy/kickstart.nixvim
