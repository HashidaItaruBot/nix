{config, ...}: {
  plugins.treesitter = {
    enable = true;
    highlight.enable = true;
    # Treesitter indent sets indentexpr and overrides autoindent/smartindent.
    # Its queries are unreliable for many languages (esp. Nix), so new lines
    # often land at column 0. Keep highlight; use classic indent instead.
    indent.enable = false;

    grammarPackages = with config.plugins.treesitter.package.builtGrammars; [
      bash
      c
      cpp
      css
      html
      javascript
      json
      lua
      markdown
      markdown_inline
      nix
      python
      regex
      rust
      scala
      toml
      tsx
      typescript
      vim
      vimdoc
      yaml
    ];
  };
}
