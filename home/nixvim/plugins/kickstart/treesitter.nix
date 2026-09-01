{pkgs, ...}: {
  plugins.treesitter = {
    enable = true;
    grammarPackages = with pkgs.vimPlugins.nvim-treesitter.builtGrammars; [
      bash
      ssh_config
      tmux
      nix
      query
      vim
      vimdoc
      lua
      csv
      diff
      editorconfig
      git_config
      git_rebase
      gitattributes
      gitcommit
      gitignore
      ini
      markdown
      markdown_inline
      regex
      yaml
      rust
      toml
      css
      html
      javascript
      json
      python
      tsx
      typescript
    ];
    settings = {
      ensureInstalled = [];
      highlight = {
        enable = true;
        additional_vim_regex_highlighting = ["ruby"];
      };
      indent = {
        enable = true;
        disable = ["ruby"];
      };
    };
  };
}
