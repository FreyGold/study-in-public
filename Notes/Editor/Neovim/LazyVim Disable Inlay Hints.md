## Approaches

### Quick (not persistent across LSP attach)
```lua
-- ~/.config/nvim/lua/config/options.lua
vim.lsp.inlay_hint.enable(false)
```

### Recommended (LazyVim plugin spec)
```lua
-- ~/.config/nvim/lua/plugins/lsp.lua
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      inlay_hints = { enabled = false },
    },
  },
}
```

## Why the Spec Wins

- LSP servers can re-enable hints on attach; the spec ensures the setting is reapplied.
- Keeps LSP configuration centralized in `plugins/lsp.lua` per LazyVim conventions.