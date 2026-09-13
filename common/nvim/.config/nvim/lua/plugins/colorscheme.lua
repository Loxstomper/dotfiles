return {
  -- Solarized colorscheme with treesitter & LSP support
  {
    "maxmx03/solarized.nvim",
    lazy = false,
    priority = 1000,
    ---@type solarized.config
    opts = {},
    init = function()
      -- force the dark variant
      vim.o.background = "dark"
    end,
  },

  -- tell LazyVim to use it
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
}
