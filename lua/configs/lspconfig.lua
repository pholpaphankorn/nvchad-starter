require("nvchad.configs.lspconfig").defaults()

-- Conform handles formatting; ESLint supplies diagnostics and code actions.
vim.lsp.config("eslint", { settings = { format = false } })

local servers = { "html", "cssls", "basedpyright", "ts_ls", "eslint" }
vim.lsp.enable(servers)

-- read :h vim.lsp.config for changing options of lsp servers
