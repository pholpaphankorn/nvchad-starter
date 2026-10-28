local M = {}

local function provider(buf)
  if vim.bo[buf].buftype ~= "" then
    return "manual", "0"
  end

  if vim.lsp.foldexpr and #vim.lsp.get_clients { bufnr = buf, method = "textDocument/foldingRange" } > 0 then
    return "expr", "v:lua.vim.lsp.foldexpr()"
  end

  local ok, parser = pcall(vim.treesitter.get_parser, buf)
  if ok and parser then
    local has_query, query = pcall(vim.treesitter.query.get, parser:lang(), "folds")
    if has_query and query then
      return "expr", "v:lua.vim.treesitter.foldexpr()"
    end
  end

  return "indent", "0"
end

local function update(buf)
  if not vim.api.nvim_buf_is_valid(buf) then
    return
  end

  local method, expr = provider(buf)
  for _, win in ipairs(vim.fn.win_findbuf(buf)) do
    local opts = vim.wo[win][0]
    -- Diff mode manages its own folds. Avoid resetting existing folds on re-entry.
    if not opts.diff then
      if opts.foldexpr ~= expr then
        opts.foldexpr = expr
      end
      if opts.foldmethod ~= method then
        opts.foldmethod = method
      end
    end
  end
end

function M.setup()
  vim.api.nvim_create_autocmd({ "FileType", "BufWinEnter", "LspAttach", "LspDetach" }, {
    group = vim.api.nvim_create_augroup("LanguageFolding", { clear = true }),
    desc = "Use LSP folds, then Tree-sitter, then indentation",
    callback = function(args)
      -- Wait for filetype plugins and LSP attachment/detachment to finish.
      vim.schedule(function()
        update(args.buf)
      end)
    end,
  })
end

return M
