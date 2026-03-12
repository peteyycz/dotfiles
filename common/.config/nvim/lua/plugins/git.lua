return {
  {
    "echasnovski/mini.diff",
    event = "VeryLazy",
    opts = {
      view = {
        style = "sign",
        signs = {
          add = "▎",
          change = "▎",
          delete = "",
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    lazy = false,
    ---@module 'snacks'
    ---@type snacks.Config
    opts = {
      notifier = {},
    },
    keys = {
      {
        "<leader>gb",
        function() Snacks.gitbrowse() end,
        desc = "Browse file on remote",
        mode = "n",
      },
    },
  },
}
