local dap = require "dap"

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
