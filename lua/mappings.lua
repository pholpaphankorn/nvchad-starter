require "nvchad.mappings"

-- add yours here

local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "]c", function()
  if vim.wo.diff then
    vim.cmd.normal { vim.v.count1 .. "]c", bang = true }
  else
    require("gitsigns").nav_hunk("next", { count = vim.v.count1 })
  end
end, { desc = "Git next changed hunk" })

map("n", "[c", function()
  if vim.wo.diff then
    vim.cmd.normal { vim.v.count1 .. "[c", bang = true }
  else
    require("gitsigns").nav_hunk("prev", { count = vim.v.count1 })
  end
end, { desc = "Git previous changed hunk" })

map("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Git preview hunk" })
map("n", "<leader>hd", "<cmd>Gitsigns diffthis<CR>", { desc = "Git diff current file" })
map("n", "<leader>gd", "<cmd>Gitsigns diff<CR>", { desc = "Git repository diff" })
map("n", "<leader>gc", ":Gitsigns diff ", { desc = "Git compare branches or commits" })
map("n", "<leader>gp", "<cmd>Gitsigns diff origin/main...HEAD<CR>", { desc = "Git PR diff against origin/main" })

map("n", "<leader>ua", function()
  vim.g.autosave_enabled = vim.g.autosave_enabled == false
  vim.notify("Autosave " .. (vim.g.autosave_enabled and "enabled" or "disabled"), vim.log.levels.INFO)
end, { desc = "Toggle autosave" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
