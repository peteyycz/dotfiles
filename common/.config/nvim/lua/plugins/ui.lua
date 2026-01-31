return {
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
    config = function()
      require("rose-pine").setup({
        variant = "moon",
        styles = {
          transparency = true,
        },
        highlight_groups = {
          Whitespace = { fg = "#393552" },
          NonText = { fg = "#393552" },
        },
      })
      vim.cmd.colorscheme "rose-pine"
    end,
  },
  {
    "echasnovski/mini.icons",
    lazy = true,
    opts = {
      file = {
        [".keep"] = { glyph = "󰊢", hl = "MiniIconsGrey" },
        ["devcontainer.json"] = { glyph = "", hl = "MiniIconsAzure" },
      },
      filetype = {
        dotenv = { glyph = "", hl = "MiniIconsYellow" },
      },
    },
    init = function()
      package.preload["nvim-web-devicons"] = function()
        require("mini.icons").mock_nvim_web_devicons()
        return package.loaded["nvim-web-devicons"]
      end
    end,
  },
  {
    "stevearc/oil.nvim",
    lazy = false,
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
      default_file_explorer = true,
      columns = { "icon" },
      view_options = { show_hidden = true },
      keymaps = {
        ["<C-p>"] = false
      },
    },
    keys = {
      {
        "-",
        "<CMD>Oil<CR>",
        desc = "Open parent directory",
        mode = "n",
      }
    },
  },
  {
    "echasnovski/mini.statusline",
    opts = {
      use_icons = true,
    },
  },
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
    },
    keys = {
      { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>" },
      { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>" },
      { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>" },
      { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>" },
      { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>" },
    },
  },
  {
    "ibhagwan/fzf-lua",
    opts = {
      { 'telescope' },
      winopts = {
        preview = {
          hidden = "hidden",
        },
      },
      keymap = {
        builtin = {
          ["<C-u>"] = "<C-u>",
        },
        fzf = {
          ["ctrl-u"] = "unix-line-discard",
        },
      },
    },
    keys = {
      {
        "<C-p>",
        function()
          require "fzf-lua".files()
        end,
        desc = "Find files",
      },
      {
        "<leader>fs",
        function()
          require "fzf-lua".live_grep { resume = true }
        end,
        desc = "Search in project",
      },
      {
        "gre",
        function()
          require "fzf-lua".diagnostics_workspace()
        end,
        desc = "Show workspace diagnostics",
      },
      {
        "grr",
        function()
          require "fzf-lua".lsp_references()
        end,
        desc = "Find LSP References",
      },
    }
  },
}
