-- Key mappings
local map = vim.api.nvim_set_keymap
local options = { noremap = true, silent = true }

-- Normal mode mappings
map("n", "<leader>a", "ggVG", options)
map("n", "<BS>", ":nohlsearch<CR>", { noremap = true, silent = false })

-- Visual mode mappings
map("v", "<", "<gv", options)
map("v", ">", ">gv", options)

-- Window navigation mappings
map("n", "<C-h>", "<C-w>h", options)
map("n", "<C-j>", "<C-w>j", options)
map("n", "<C-k>", "<C-w>k", options)
map("n", "<C-l>", "<C-w>l", options)

-- Custom commands
vim.api.nvim_create_user_command("E", function(opts)
  vim.cmd("e " .. opts.args)
end, { bang = true, nargs = "?" })
vim.api.nvim_create_user_command("W", function(opts)
  vim.cmd("w " .. opts.args)
end, { bang = true, nargs = "?" })
vim.api.nvim_create_user_command("Wq", function(opts)
  vim.cmd("wq " .. opts.args)
end, { bang = true, nargs = "?" })
vim.api.nvim_create_user_command("WQ", function(opts)
  vim.cmd("wq " .. opts.args)
end, { bang = true, nargs = "?" })
vim.api.nvim_create_user_command("Wa", function()
  vim.cmd("wa")
end, { bang = true })
vim.api.nvim_create_user_command("WA", function()
  vim.cmd("wa")
end, { bang = true })
vim.api.nvim_create_user_command("Q", function()
  vim.cmd("q")
end, { bang = true })
vim.api.nvim_create_user_command("QA", function()
  vim.cmd("qa")
end, { bang = true })
vim.api.nvim_create_user_command("Qa", function()
  vim.cmd("qa")
end, { bang = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  desc = "Highlight yanked test",
  group = vim.api.nvim_create_augroup("highlight-yank", { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_user_command('VitestWatch', function()
  -- Save the current buffer before running tests
  vim.cmd('write')

  local filename = vim.fn.expand('%:p')
  local quoted_filename = "'" .. filename:gsub("'", "'\\''") .. "'"

  -- Store the original window ID so we can restore focus later
  local original_win = vim.api.nvim_get_current_win()

  -- Open a vertical split to the right
  vim.cmd('rightbelow vsplit')

  -- Resize the split to 1/3 of the total columns
  local columns = vim.o.columns
  vim.cmd('vertical resize ' .. math.floor(columns / 3))

  -- Open the terminal and run the vitest watch command
  vim.cmd('term npx vitest watch ' .. quoted_filename)

  -- Restore focus to the original window
  vim.api.nvim_set_current_win(original_win)
end, { desc = "Run npx vitest watch <current-file> in a right 1/3 terminal split without focus change" })

map('n', '<leader>t', ':VitestWatch<CR>', options)
map('n', '?', '<cmd>lua vim.diagnostic.open_float()<CR>', options)
