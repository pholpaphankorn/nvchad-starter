-- Run from the config directory:
-- NVIM_LOG_FILE=/tmp/nvim-folding.log nvim --headless -i NONE -n '+lua dofile("tests/folding.lua")'
local function wait_for(predicate, message)
  assert(vim.wait(2000, predicate, 10), message)
end

local function check_shortcuts()
  vim.cmd "normal! zx"
  vim.cmd "normal! zM"
  assert(vim.fn.foldclosed(2) > 0, "zM did not close a fold")
  vim.cmd "normal! zR"
  assert(vim.fn.foldclosed(2) == -1, "zR did not open the fold")
end

local function run()
  vim.cmd.enew()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    "local function example()",
    "  if true then",
    '    print("fold me")',
    "  end",
    "end",
  })
  vim.bo.filetype = "lua"
  wait_for(function()
    return vim.wo.foldmethod == "expr"
  end, "Lua did not select automatic folding")
  assert(vim.wo.foldexpr == "v:lua.vim.treesitter.foldexpr()", "Lua should use Tree-sitter without an LSP")
  assert(vim.fn.foldclosed(2) == -1, "Files should start unfolded")
  check_shortcuts()
  assert(vim.fn.maparg("zM", "n") == "", "zM should keep its built-in behavior")
  assert(vim.fn.maparg("zR", "n") == "", "zR should keep its built-in behavior")
  vim.cmd "normal! zM"
  vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = buf })
  vim.wait(50)
  assert(vim.fn.foldclosed(2) > 0, "Re-entering the buffer reset closed folds")
  vim.cmd "normal! zR"

  -- Exercise Neovim's real LSP folding path with an in-process test server.
  local stopped = false
  local request_id = 0
  local client_id = vim.lsp.start {
    name = "folding-test",
    cmd = function(dispatchers)
      return {
        request = function(method, _, callback)
          request_id = request_id + 1
          local result
          if method == "initialize" then
            result = { capabilities = { foldingRangeProvider = true } }
          elseif method == "textDocument/foldingRange" then
            result = { { startLine = 0, endLine = 4 } }
          end
          vim.schedule(function()
            callback(nil, result)
          end)
          return true, request_id
        end,
        notify = function()
          return true
        end,
        is_closing = function()
          return stopped
        end,
        terminate = function()
          stopped = true
          dispatchers.on_exit(0, 0)
        end,
      }
    end,
  }
  assert(client_id, "Test LSP did not start")
  wait_for(function()
    return vim.wo.foldexpr == "v:lua.vim.lsp.foldexpr()"
  end, "LSP did not take priority over Tree-sitter")
  wait_for(function()
    vim.cmd "normal! zx"
    return vim.fn.foldlevel(1) > 0
  end, "LSP folding ranges were not applied")
  check_shortcuts()

  vim.cmd.vsplit()
  vim.wait(50)
  assert(vim.wo.foldexpr == "v:lua.vim.lsp.foldexpr()", "Split lost LSP folding")
  vim.lsp.buf_detach_client(buf, client_id)
  wait_for(function()
    return vim.wo.foldexpr == "v:lua.vim.treesitter.foldexpr()"
  end, "LSP detach did not restore Tree-sitter")
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    assert(vim.wo[win].foldexpr == "v:lua.vim.treesitter.foldexpr()", "Split kept stale LSP folding")
  end
  check_shortcuts()
  vim.lsp.get_client_by_id(client_id):stop(true)
  vim.cmd.close()

  vim.cmd.enew()
  vim.api.nvim_buf_set_lines(0, 0, -1, false, { "section", "  first", "  second", "end" })
  vim.bo.filetype = "folding_test_no_parser"
  wait_for(function()
    return vim.wo.foldmethod == "indent"
  end, "Missing parser did not fall back to indentation")
  check_shortcuts()
  vim.cmd.diffthis()
  vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = 0 })
  vim.wait(50)
  assert(vim.wo.foldmethod == "diff", "Code folding replaced diff folding")
  vim.cmd.diffoff()
  vim.bo.buftype = "nofile"
  vim.api.nvim_exec_autocmds("BufWinEnter", { buffer = 0 })
  wait_for(function()
    return vim.wo.foldmethod == "manual"
  end, "Special buffer inherited code folding")
  print "PASS: Tree-sitter, LSP, detach, splits, indentation, diff, special buffers, zM and zR"
end

vim.schedule(function()
  local ok, err = pcall(run)
  if not ok then
    print(err)
    vim.cmd "cquit 1"
  end
  vim.cmd "qa!"
end)
