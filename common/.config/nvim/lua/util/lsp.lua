---@class util.lsp
local M = {
  jslike_filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
  }
}

---@param on_attach fun(client: vim.lsp.Client, bufnr: integer)
function M.generic_on_attach(client, bufnr)
  if client.supports_method("textDocument/formatting") then
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ bufnr = bufnr, id = client.id })
      end,
    })
  end
end

return M
