local dap = require "dap"

-- Mason's Python runs the adapter; the project's Python runs your code.
dap.adapters.debugpy = {
  type = "executable",
  command = vim.fn.stdpath "data" .. "/mason/packages/debugpy/venv/bin/python",
  args = { "-m", "debugpy.adapter" },
}
-- Support older Python launch configurations as well as modern launch.json files.
dap.adapters.python = dap.adapters.debugpy

local function python_path()
  local cwd = vim.fn.getcwd()
  local environments = { vim.env.VIRTUAL_ENV or "", vim.env.CONDA_PREFIX or "", cwd .. "/.venv", cwd .. "/venv" }

  for _, environment in ipairs(environments) do
    local python = environment .. "/bin/python"
    if environment ~= "" and vim.fn.executable(python) == 1 then
      return python
    end
  end

  for _, command in ipairs { "python3", "python" } do
    local python = vim.fn.exepath(command)
    if python ~= "" then
      return python
    end
  end

  error "No Python interpreter found. Activate a virtual environment before starting Neovim."
end

dap.configurations.python = {
  {
    type = "debugpy",
    request = "launch",
    name = "Python: current file",
    program = "${file}",
    cwd = "${workspaceFolder}",
    pythonPath = python_path,
    console = "integratedTerminal",
    justMyCode = true,
  },
}

-- Mason's standalone VS Code JavaScript debugger serves each session on a free port.
for _, adapter_type in ipairs { "pwa-node", "pwa-chrome" } do
  dap.adapters[adapter_type] = {
    type = "server",
    host = "127.0.0.1",
    port = "${port}",
    executable = {
      command = vim.fn.stdpath "data" .. "/mason/bin/js-debug-adapter",
      args = { "${port}", "127.0.0.1" },
    },
  }
end

-- Accept the shorter adapter types used in VS Code launch.json files.
for alias, adapter_type in pairs { node = "pwa-node", chrome = "pwa-chrome" } do
  dap.adapters[alias] = function(callback, config)
    config.type = adapter_type
    callback(dap.adapters[adapter_type])
  end
end

for _, filetype in ipairs { "javascript", "javascriptreact", "typescript", "typescriptreact" } do
  dap.configurations[filetype] = {
    {
      type = "pwa-node",
      request = "launch",
      name = "Node: current file (compile TypeScript first)",
      program = "${file}",
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
      sourceMaps = true,
      outFiles = {
        "${workspaceFolder}/**/*.js",
        "${workspaceFolder}/**/*.mjs",
        "${workspaceFolder}/**/*.cjs",
        "!**/node_modules/**",
      },
      skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
    },
    {
      type = "pwa-node",
      request = "attach",
      name = "Node: attach to process",
      processId = require("dap.utils").pick_process,
      cwd = "${workspaceFolder}",
      sourceMaps = true,
      skipFiles = { "<node_internals>/**", "${workspaceFolder}/node_modules/**" },
    },
    {
      type = "pwa-chrome",
      request = "launch",
      name = "Chrome: launch web app",
      url = function()
        return vim.fn.input("Dev server URL: ", "http://localhost:5173")
      end,
      webRoot = "${workspaceFolder}",
      sourceMaps = true,
    },
  }
end
