-- Run with: nvim --headless -u NONE -l tests/dap_regression.lua
-- Compare the entry point with the version before issue #10.
local baseline = vim.fn.system "git show 3b2abf533ea334d33d909fdb9fd28fc48923ed8a:lua/configs/dap.lua 2>/dev/null"
assert(vim.v.shell_error == 0, "Could not read baseline from git")
local real_vim = vim
local picker = function() end
local state

local function load_config(source)
  state = { executable = {}, paths = {}, calls = 0 }
  local dap = { adapters = {}, configurations = {} }
  package.loaded.dap = dap
  package.loaded["dap.utils"] = { pick_process = picker }
  package.loaded["configs.dap"] = nil
  package.loaded["configs.dap.python"] = nil
  package.loaded["configs.dap.javascript"] = nil
  vim = setmetatable({
    env = {},
    fn = {
      stdpath = function() return "/data" end,
      getcwd = function() state.calls = state.calls + 1; return "/project" end,
      executable = function(path) state.calls = state.calls + 1; return state.executable[path] and 1 or 0 end,
      exepath = function(name) state.calls = state.calls + 1; return state.paths[name] or "" end,
      input = function(prompt, default)
        state.calls = state.calls + 1
        state.prompt, state.default = prompt, default
        return "chosen URL"
      end,
    },
  }, { __index = real_vim })
  if source then
    assert(loadstring(source))()
  else
    require "configs.dap"
  end
  assert(state.calls == 0, "registration must not resolve project settings")
  return dap
end

local function snapshot(value)
  if type(value) == "function" then return "<callback>" end
  if type(value) ~= "table" then return value end
  local result = {}
  for key, item in pairs(value) do result[key] = snapshot(item) end
  return result
end

local function exercise(dap)
  assert(dap.adapters.python == dap.adapters.debugpy)
  local python = dap.configurations.python[1].pythonPath
  vim.env.VIRTUAL_ENV, vim.env.CONDA_PREFIX = "/virtual", "/conda"
  local paths = { "/virtual/bin/python", "/conda/bin/python", "/project/.venv/bin/python", "/project/venv/bin/python" }
  for _, path in ipairs(paths) do state.executable[path] = true end
  state.paths.python3, state.paths.python = "/path/python3", "/path/python"
  for _, path in ipairs(paths) do
    assert(python() == path)
    state.executable[path] = nil
  end
  assert(python() == "/path/python3")
  state.paths.python3 = nil
  assert(python() == "/path/python")
  state.paths.python = nil
  local ok, err = pcall(python)
  assert(not ok and err:find("No Python interpreter found. Activate a virtual environment before starting Neovim.", 1, true))
  for alias, target in pairs { node = "pwa-node", chrome = "pwa-chrome" } do
    local config, selected = { type = alias }, nil
    dap.adapters[alias](function(adapter) selected = adapter end, config)
    assert(config.type == target and selected == dap.adapters[target])
  end
  for _, ft in ipairs { "javascript", "javascriptreact", "typescript", "typescriptreact" } do
    local configs = dap.configurations[ft]
    assert(configs[2].processId == picker)
    assert(configs[3].url() == "chosen URL")
    assert(state.prompt == "Dev server URL: " and state.default == "http://localhost:5173")
  end
end

package.path = "./lua/?.lua;./lua/?/init.lua;" .. package.path
local before = load_config(baseline)
local expected = snapshot(before)
exercise(before)
local after = load_config()
assert(real_vim.deep_equal(expected, snapshot(after)), "registrations changed")
exercise(after)
vim = real_vim
print "DAP registration and callbacks match baseline"
