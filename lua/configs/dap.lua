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
