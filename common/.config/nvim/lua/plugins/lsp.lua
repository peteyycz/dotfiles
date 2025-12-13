local LspUtil = require "util.lsp"

return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    opts = {
      automatic_enable = false,
      ensure_installed = { "lua_ls", "vtsls", "elixirls", "eslint", "rust_analyzer", "clangd", "templ", "gopls", "phpactor", "zls" },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        },
      },
    },
    config = function()
      local configs = require "lspconfig.configs"

      -- Helper function to get default config from lspconfig
      local function get_config(name)
        return configs[name] or {}
      end

      -- Zig Language Server
      vim.lsp.config.zls = vim.tbl_deep_extend("force", get_config("zls"), {
        cmd = { "zls" },
        filetypes = { "zig" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- PHP Language Server
      vim.lsp.config.phpactor = vim.tbl_deep_extend("force", get_config("phpactor"), {
        cmd = { "phpactor", "language-server" },
        filetypes = { "php" },
        on_attach = LspUtil.generic_on_attach,
        init_options = {
          language_server_php_version = "8.1",
          workspace_folders = { vim.fn.getcwd() },
        },
      })

      -- ESLint
      vim.lsp.config.eslint = vim.tbl_deep_extend("force", get_config("eslint"), {
        cmd = { "vscode-eslint-language-server", "--stdio" },
        filetypes = LspUtil.jslike_filetypes,
        on_attach = function(_client, bufnr)
          vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
          })
        end,
      })

      -- TypeScript/JavaScript Language Server
      vim.lsp.config.vtsls = vim.tbl_deep_extend("force", get_config("vtsls"), {
        cmd = { "vtsls", "--stdio" },
        filetypes = LspUtil.jslike_filetypes,
        settings = {
          complete_function_calls = true,
          vtsls = {
            enableMoveToFileCodeAction = true,
            autoUseWorkspaceTsdk = true,
            experimental = {
              maxInlayHintLength = 30,
              completion = {
                enableServerSideFuzzyMatch = true,
              },
            },
          },
          typescript = {
            updateImportsOnFileMove = { enabled = "always" },
            suggest = {
              completeFunctionCalls = true,
            },
            inlayHints = {
              enumMemberValues = { enabled = true },
              functionLikeReturnTypes = { enabled = true },
              parameterNames = { enabled = "literals" },
              parameterTypes = { enabled = true },
              propertyDeclarationTypes = { enabled = true },
              variableTypes = { enabled = false },
            },
          },
        },
      })

      -- Go Language Server
      vim.lsp.config.gopls = vim.tbl_deep_extend("force", get_config("gopls"), {
        cmd = { "gopls" },
        filetypes = { "go", "gomod", "gowork", "gotmpl", "templ" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- Templ Language Server
      vim.lsp.config.templ = vim.tbl_deep_extend("force", get_config("templ"), {
        cmd = { "templ", "lsp" },
        filetypes = { "templ" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- Lua Language Server
      vim.lsp.config.lua_ls = vim.tbl_deep_extend("force", get_config("lua_ls"), {
        cmd = { "lua-language-server" },
        filetypes = { "lua" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- C/C++ Language Server
      vim.lsp.config.clangd = vim.tbl_deep_extend("force", get_config("clangd"), {
        cmd = { "clangd" },
        filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- Gleam Language Server
      vim.lsp.config.gleam = vim.tbl_deep_extend("force", get_config("gleam"), {
        cmd = { "gleam", "lsp" },
        filetypes = { "gleam" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- Elixir Language Server
      vim.lsp.config.elixirls = vim.tbl_deep_extend("force", get_config("elixirls"), {
        cmd = { "elixir-ls" },
        filetypes = { "elixir", "eelixir", "heex", "surface" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- Astro Language Server
      vim.lsp.config.astro = vim.tbl_deep_extend("force", get_config("astro"), {
        cmd = { "astro-ls", "--stdio" },
        filetypes = { "astro" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- Rust Analyzer
      vim.lsp.config.rust_analyzer = vim.tbl_deep_extend("force", get_config("rust_analyzer"), {
        cmd = { "rust-analyzer" },
        filetypes = { "rust" },
        on_attach = LspUtil.generic_on_attach,
      })

      -- Enable LSP servers for their respective filetypes
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "zig",
        callback = function()
          vim.lsp.enable("zls")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "php",
        callback = function()
          vim.lsp.enable("phpactor")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = LspUtil.jslike_filetypes,
        callback = function()
          vim.lsp.enable("eslint")
          vim.lsp.enable("vtsls")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "go", "gomod", "gowork", "gotmpl", "templ" },
        callback = function()
          vim.lsp.enable("gopls")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "templ",
        callback = function()
          vim.lsp.enable("templ")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "lua",
        callback = function()
          vim.lsp.enable("lua_ls")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
        callback = function()
          vim.lsp.enable("clangd")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "gleam",
        callback = function()
          vim.lsp.enable("gleam")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "elixir", "eelixir", "heex", "surface" },
        callback = function()
          vim.lsp.enable("elixirls")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "rust",
        callback = function()
          vim.lsp.enable("rust_analyzer")
        end,
      })

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "astro",
        callback = function()
          vim.lsp.enable("astro")
        end,
      })
    end,
  },
}
