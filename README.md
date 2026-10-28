# My Neovim config

Personal configuration forked from [NvChad starter](https://github.com/NvChad/starter).
NvChad itself is installed as a plugin by `init.lua`.

## Install on another computer

Install Git and the prerequisites in the [NvChad installation guide](https://nvchad.com/docs/quickstart/install/).
If `~/.config/nvim` already exists, move it to a backup location first.

```sh
git clone https://github.com/pholpaphankorn/nvchad-starter.git ~/.config/nvim
cd ~/.config/nvim
git remote add upstream https://github.com/NvChad/starter.git
nvim
```

Allow the first launch to install plugins, then run these commands inside Neovim:

```vim
:Lazy restore
:MasonInstallAll
:TSInstallAll
```

`lazy-lock.json` records plugin revisions; keep it committed so `:Lazy restore`
can restore the same versions on another computer. See the [lazy.nvim lockfile guide](https://lazy.folke.io/usage/lockfile).

`lua/configs/mason.lua` lists the tools to install: `lua-language-server`,
`html-lsp`, `css-lsp`, `basedpyright`, `stylua`, `ruff`, `prettier`, and `debugpy`.
`lua/chadrc.lua` connects this list to NvChad's built-in `:MasonInstallAll`
command, which installs missing tools when run. No extra installer plugin or
startup installation is needed. NvChad also detects tools from the LSP,
Conform, and nvim-lint configuration. Add tools installed manually through
`:Mason` to this list if they should be restored on another computer.

`lua/configs/lspconfig.lua` enables language servers, while
`lua/configs/conform.lua` selects formatters and enables formatting on save.
`lua/configs/treesitter.lua` lists the parsers installed by `:TSInstallAll`.
`lua/plugins/init.lua` connects these configuration files to their plugins.

Keep these configuration files and `lazy-lock.json` in Git. The lockfile pins
plugin revisions; it does not pin Mason tool versions. Specific tool versions
can be declared in the Mason tool list when needed. Downloaded tools, compiled
parsers, and plugin checkouts are installed separately on each computer.

## Autosave

Autosave is disabled by default when Neovim starts. In normal mode, press
`Space u a` to toggle it for the current session. A notification shows whether
autosave is now enabled or disabled. When enabled, edited files are saved on
leaving insert mode, leaving a buffer, or losing Neovim focus.

## Code folding

Folding uses the attached language server when it supports folding ranges,
otherwise the installed Tree-sitter parser and its folding query. Files without
either use indentation. This uses [Neovim's native folding support](https://neovim.io/doc/user/lsp/#vim.lsp.foldexpr()),
so no additional plugin is needed. Files start with all folds open.

These shortcuts work in normal mode:

| Shortcut | Action |
| --- | --- |
| `zM` / `zR` | Close / open all folds |
| `zc` / `zo` | Close / open the fold under the cursor |
| `za` | Toggle the fold under the cursor |
| `zm` / `zr` | Fold one level more / less |

Folding updates when a language server attaches or detaches and applies to each
split showing the file. Diff windows retain their own folding behavior.
To add language support, install its parser with `:TSInstall <language>` or
configure a language server in `lua/configs/lspconfig.lua`.

## Git shortcuts

These shortcuts work in normal mode; `<leader>` is `Space`.

| Shortcut | Action |
| --- | --- |
| `]c` / `[c` | Next / previous changed hunk; counts such as `3]c` are supported |
| `<leader>hp` | Preview the current hunk |
| `<leader>hi` | Preview the current hunk inline, including deleted lines |
| `<leader>hs` | Stage the current hunk, or unstage it when only staged changes are present |
| `<leader>tw` | Toggle word-level difference highlighting (disabled on startup) |
| `<leader>hd` | Diff the current file against the index |
| `<leader>gd` | Open the repository diff against `HEAD` |
| `<leader>gc` | Start `:Gitsigns diff ` to enter branches or commits |
| `<leader>gg` | Open `git log --oneline --graph --decorate --all` in a terminal in a new tab |
| `<leader>gl` | Diff the latest commit against its parent (`:Gitsigns diff HEAD~1..HEAD`) |
| `<leader>gp` | Compare the current branch against `origin/main` using the merge base |

In visual mode, `Space h s` stages only the selected lines, allowing partial-hunk
staging. Selecting staged lines with no overlapping unstaged changes unstages
them instead. When staged and unstaged edits overlap, staging takes precedence.

The `ih` text object selects a hunk in visual and operator-pending modes: use
`vih` to select a hunk or `yih` to copy its current buffer lines.

Use `Space t w` to turn word-level differences on or off for the current session.
Restarting Neovim returns them to disabled.

To review a PR, fetch from `origin`, check out its branch, then press `Space g p`.
This runs `:Gitsigns diff origin/main...HEAD`, showing committed changes since
the branches' common ancestor. Uncommitted edits are excluded. For a PR targeting
another branch, use `Space g c` and enter, for example, `origin/develop...HEAD`.
You can also enter `main..feature` to compare branch tips or `abc123..def456`
to compare specific commits.

Press `Space g g` to see the commit graph across all local and remote-tracking
branches. If Git opens a pager, press `i` to send terminal input, then `q` to
quit the pager. Use NvChad's `Ctrl-x` to return to normal mode and `:q` to close
the graph tab.

In a diff window, `]c` and `[c` keep Neovim's built-in diff navigation.
NvChad's existing `Space h` shortcut still opens a horizontal terminal after
the mapping timeout; longer `Space h …` shortcuts select the Git actions above.

Gitsigns shows blame information for the current line as virtual text by default.
Use `:Gitsigns toggle_current_line_blame` to toggle it for the current session.

## Python debugging

Mason installs `debugpy`, the Python debug adapter. The `nvim-dap` plugin connects
Neovim to it. This setup uses nvim-dap's built-in console and variable/stack
viewers, with no additional debugger UI plugins.

Restart Neovim after pulling this configuration and let Lazy install `nvim-dap`.
On another computer, run `:Lazy restore` and `:MasonInstallAll` first.
The configuration lives in `lua/configs/dap.lua`, and its shortcuts are in
`lua/plugins/dap.lua`. It loads when opening Python files or using a debug shortcut.

Start Neovim from your Python project's root directory (`cd /path/to/project &&
nvim main.py`), or use `:cd /path/to/project` inside Neovim. That directory is
the program's working directory. The interpreter is selected in this order:

1. An activated virtual environment (`VIRTUAL_ENV`, then `CONDA_PREFIX`). Activate
   it in your shell **before** starting Neovim.
2. `.venv/bin/python` or `venv/bin/python` in Neovim's working directory.
3. `python3`, then `python`, from `PATH`.

Install your project's dependencies in that interpreter. Mason's separate Python
only runs the adapter; your project environment does not need its own debugpy.

### First debug session

Save this as `main.py` in a project directory:

```python
def total_price(price, quantity):
    total = price * quantity
    return total


result = total_price(12, 3)
print(result)
```

1. Open the file and save your edits with `:w` before debugging.
2. Put the cursor on `result = total_price(12, 3)` and press `Space d b` to set a
   breakpoint. A breakpoint pauses execution **before** that line runs.
3. Press `Space d c` to launch the current file. Execution pauses at the breakpoint.
4. Press `Space d i` to enter `total_price`, then `Space d o` to execute the
   multiplication. Put the cursor on `total` and press `Space d h` to inspect it;
   it should be `36`. Use `Space d v` to see all local variables.
5. Close the floating viewer with `:q`, then press `Space d c` to finish. Program
   output appears in a terminal split; `input()` also works there.

These shortcuts work in normal mode; `<leader>` is `Space`:

| Shortcut | Action |
| --- | --- |
| `<leader>db` | Toggle a breakpoint on the current line |
| `<leader>dB` | Set a conditional breakpoint, such as `quantity > 2` |
| `<leader>dc` | Start debugging the current file, or continue to the next breakpoint |
| `<leader>do` | Step over: execute the next line without entering function calls |
| `<leader>di` | Step into a function call |
| `<leader>dO` | Step out: finish the current function and return to its caller |
| `<leader>dh` | Inspect the expression under the cursor while paused |
| `<leader>dv` | Show variables and scopes while paused |
| `<leader>df` | Show stack frames; press Enter on a frame to inspect its caller |
| `<leader>dr` | Toggle the debug console (REPL) |
| `<leader>dl` | Run the last debug configuration again |
| `<leader>dt` | Terminate the debug session |

In the console, press `i`, type an expression such as `price * quantity`, then
press Enter to evaluate it while paused. `.help` lists console commands.
Press Enter on structured variables in viewers to expand them. Use `:q` to close
a floating viewer, `Ctrl-w w` to move between splits, and NvChad's `Ctrl-x` to
leave terminal input mode. Toggle breakpoints off with `Space d b` when finished;
breakpoints last for the current Neovim session.

The default configuration launches a standalone script and steps through your own
code (`justMyCode = true`). For modules, command-line arguments, or framework
entry points, add a configuration in `lua/configs/dap.lua` using `module`, `args`,
or `env` as described in the [debugpy configuration reference](https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings).
See [nvim-dap's documentation](https://codeberg.org/mfussenegger/nvim-dap) and
`:help dap` for more workflows.

nvim-dap also reads `.vscode/launch.json` from Neovim's working directory and
offers those configurations when starting a session. Both `"type": "debugpy"`
and the older `"type": "python"` use Mason's debugpy adapter. Choose
`Python: current file` to use the default setup above, or select your project's
configuration to use its arguments, environment, and entry point.

If the debugger cannot start, check `:Mason` for `debugpy` and run
`:MasonInstall debugpy` if missing. Use `:DapShowLog` for adapter errors.
If imports fail, check that Neovim's working directory (`:pwd`) and the chosen
project environment match your project.

## Save changes

```sh
cd ~/.config/nvim
git status
git add .
git commit -m "Describe the config change"
git push
```

On another configured computer, run `git pull --ff-only` from `~/.config/nvim`
when local changes have been committed, then run `:Lazy restore`,
`:MasonInstallAll`, and `:TSInstallAll` inside Neovim. Restart Neovim after
restoring plugins so their restored versions are loaded.

## Sync changes from NvChad starter

With local changes committed, create a review branch from your fork's current
`main` and merge starter changes into it:

```sh
cd ~/.config/nvim
git switch main
git pull --ff-only origin main
git fetch upstream
git switch -c sync/nvchad-starter-YYYY-MM-DD
git merge upstream/main
git push -u origin HEAD
```

Replace `YYYY-MM-DD` with the date of the sync. If Git reports conflicts, resolve
them and commit the merge before pushing. Open a pull request in
`pholpaphankorn/nvchad-starter` with `main` as the base branch, review it, and merge
it when ready. Then switch back to `main` and run `git pull --ff-only origin main`.

The `upstream` remote points to the starter configuration. Updates to NvChad's
core and other plugins are managed separately through `:Lazy update`; commit
the resulting `lazy-lock.json` changes after checking the update.

## Credits

- [NvChad](https://github.com/NvChad/NvChad) and its [starter](https://github.com/NvChad/starter).
- [LazyVim starter](https://github.com/LazyVim/starter), which inspired NvChad's starter.
