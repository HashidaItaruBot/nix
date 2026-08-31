{pkgs, ...}: {
  plugins.treesitter = {
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      css
      diff
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      html
      javascript
      json
      lua
      markdown
      markdown_inline
      nix
      python
      query
      regex
      rust
      toml
      tsx
      typescript
      vim
      vimdoc
      yaml
    ];
    settings = {
      highlight.enable = true;
      indent.enable = true;
    };
  };
}
