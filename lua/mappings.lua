require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>ua", function()
  vim.g.autosave_enabled = vim.g.autosave_enabled == false
  vim.notify("Autosave " .. (vim.g.autosave_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle autosave" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
