{config, ...}: {
  plugins.treesitter = {
    enable = true;
    highlight.enable = true;
    indent.enable = true;

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
      toml
      tsx
      typescript
      vim
      vimdoc
      yaml
    ];
  };
}
