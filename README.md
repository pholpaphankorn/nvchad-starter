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

This config uses the `html`, `cssls`, and `basedpyright` language servers and the
`stylua`, `ruff`, and `prettier` formatters. Install any missing tools through
`:Mason` or your system package manager. Installed tools and plugin downloads
are separate from this repository.

## Save changes

```sh
cd ~/.config/nvim
git status
git add .
git commit -m "Describe the config change"
git push
```

On another configured computer, run `git pull --ff-only` from `~/.config/nvim`
when local changes have been committed, then run `:Lazy restore` inside Neovim.

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
