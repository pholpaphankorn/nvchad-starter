return {
  {
    "mfussenegger/nvim-dap",
    ft = "python",
    cmd = {
      "DapContinue",
      "DapToggleBreakpoint",
      "DapStepOver",
      "DapStepInto",
      "DapStepOut",
      "DapTerminate",
      "DapShowLog",
    },
    keys = {
      {
        "<leader>dc",
        function()
          require("dap").continue()
        end,
        desc = "Debug start or continue",
      },
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Debug toggle breakpoint",
      },
      {
        "<leader>dB",
        function()
          vim.ui.input({ prompt = "Breakpoint condition: " }, function(condition)
            if condition and condition ~= "" then
              require("dap").set_breakpoint(condition)
            end
          end)
        end,
        desc = "Debug conditional breakpoint",
      },
      {
        "<leader>do",
        function()
          require("dap").step_over()
        end,
        desc = "Debug step over",
      },
      {
        "<leader>di",
        function()
          require("dap").step_into()
        end,
        desc = "Debug step into",
      },
      {
        "<leader>dO",
        function()
          require("dap").step_out()
        end,
        desc = "Debug step out",
      },
      {
        "<leader>dt",
        function()
          require("dap").terminate()
        end,
        desc = "Debug terminate",
      },
      {
        "<leader>dl",
        function()
          require("dap").run_last()
        end,
        desc = "Debug run last configuration",
      },
      {
        "<leader>dr",
        function()
          require("dap").repl.toggle()
        end,
        desc = "Debug toggle console",
      },
      {
        "<leader>dh",
        function()
          require("dap.ui.widgets").hover()
        end,
        desc = "Debug inspect under cursor",
      },
      {
        "<leader>dv",
        function()
          local widgets = require "dap.ui.widgets"
          widgets.centered_float(widgets.scopes)
        end,
        desc = "Debug variables and scopes",
      },
      {
        "<leader>df",
        function()
          local widgets = require "dap.ui.widgets"
          widgets.centered_float(widgets.frames)
        end,
        desc = "Debug stack frames",
      },
    },
    config = function()
      require "configs.dap"
    end,
  },
}
