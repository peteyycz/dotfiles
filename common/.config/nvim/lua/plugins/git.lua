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
      {
        "<leader>gg",
        function() Snacks.lazygit() end,
        desc = "Open lazygit",
        mode = "n",
      },
      {
        "<leader>gl",
        function() Snacks.lazygit.log() end,
        desc = "Lazygit log",
        mode = "n",
      },
    },
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
    },
    opts = {},
  },
  {
    "pwntester/octo.nvim",
    cmd = "Octo",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    opts = {},
  },
}
