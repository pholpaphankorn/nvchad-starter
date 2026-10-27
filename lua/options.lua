require "nvchad.options"

-- add yours here!

-- Show absolute line numbers and relative distances in separate columns.
vim.opt.number = true
vim.opt.relativenumber = true
-- Keep both columns aligned as the buffer grows past 999, 9999, etc.
vim.opt.statuscolumn = "%s%C"
  .. " %{v:virtnum == 0 && &number ? printf('%*d', max([1, strlen(line('$'))]), v:lnum) : ''}"
  .. " %{v:virtnum == 0 && &relativenumber ? printf('%*d', max([1, strlen(line('$'))]), v:relnum) : ''} │ "

-- local o = vim.o
-- o.cursorlineopt ='both' -- to enable cursorline!
