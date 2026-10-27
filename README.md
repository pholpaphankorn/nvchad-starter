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

## Git shortcuts

These shortcuts work in normal mode; `<leader>` is `Space`.

| Shortcut | Action |
| --- | --- |
| `]c` / `[c` | Next / previous changed hunk; counts such as `3]c` are supported |
| `<leader>hp` | Preview the current hunk |
| `<leader>hd` | Diff the current file against the index |
| `<leader>gd` | Open the repository diff against `HEAD` |
| `<leader>gc` | Start `:Gitsigns diff ` to enter branches or commits |
| `<leader>gp` | Compare the current branch against `origin/main` using the merge base |

To review a PR, fetch from `origin`, check out its branch, then press `Space g p`.
This runs `:Gitsigns diff origin/main...HEAD`, showing committed changes since
the branches' common ancestor. Uncommitted edits are excluded. For a PR targeting
another branch, use `Space g c` and enter, for example, `origin/develop...HEAD`.
You can also enter `main..feature` to compare branch tips or `abc123..def456`
to compare specific commits.

In a diff window, `]c` and `[c` keep Neovim's built-in diff navigation.
NvChad's existing `Space h` shortcut still opens a horizontal terminal after
the mapping timeout; `Space h p` and `Space h d` select the Git actions above.

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
