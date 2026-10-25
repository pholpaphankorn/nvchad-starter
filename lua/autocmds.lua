require "nvchad.autocmds"

vim.api.nvim_create_autocmd({ "InsertLeave", "BufLeave", "FocusLost" }, {
  group = vim.api.nvim_create_augroup("AutoSave", { clear = true }),
  nested = true,
  desc = "Save edited files when leaving insert mode, a buffer, or Neovim focus",
  callback = function(args)
    local buf = args.buf
    local opts = vim.bo[buf]

    if opts.buftype ~= "" or not opts.modifiable or opts.readonly or not opts.modified then
      return
    end

    if vim.api.nvim_buf_get_name(buf) == "" then
      return
    end

    vim.api.nvim_buf_call(buf, function()
      vim.cmd "silent update"
    end)
  end,
})
