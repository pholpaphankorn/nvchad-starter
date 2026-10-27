# Gitsigns recommendations for diff and hunk work

Reviewed 2026-10-27 against upstream documentation and the installed revision
`d4854fa9a94b5c8b37dd209fb4a19e98e764186f`, which matches `lazy-lock.json`.
This is a recommendation report; no configuration was changed.

## Existing setup

The current config already provides `]c` / `[c` with counts and native diff-mode
navigation, a floating hunk preview (`Space h p`), a file/index diff (`Space h d`),
and repository/commit/branch comparisons (`Space g d`, `g c`, `g l`, `g p`).
Current-line blame is enabled in `lua/plugins/init.lua`. These observations come
from the local configuration and README. NvChad's inherited Gitsigns config only
customizes two sign glyphs; the upstream feature defaults still apply.

## Recommended first additions

| Priority | Feature | Proposed mapping or setting | Why it fits this workflow |
| --- | --- | --- | --- |
| 1 | Stage/unstage a hunk | `Space h s` in normal and visual modes | Build focused commits while reviewing changes. Visual mode can stage part of a hunk. |
| 1 | Inline hunk preview | `Space h i` | Read removed lines beside the current code without opening a split. Keep the existing popup preview too. |
| 1 | Word differences | `word_diff = true`; `Space t w` to toggle | Make small edits inside changed lines easier to spot. |
| 1 | Hunk text object | `ih` in operator-pending and visual modes | Use `vih` to select and `yih` to copy a hunk. |
| 2 | Repository hunk list | `Space h Q` for all; `Space h q` for current buffer | Walk changes with quickfix when reviewing many files. |
| 2 | Staged-hunk navigation | Separate staged navigation or `target = 'all'` | Review what is already staged as well as pending edits. |
| 2 | File diff against `HEAD` | `Space h D` | Review staged and unstaged changes together relative to the latest commit. |
| 3 | Reset a selected hunk/range | `Space h r` in normal and visual modes | Discard a specific edit after inspecting it. |

Hunk staging, unstaging, range actions, inline previews, text objects, and word
differences are supported upstream; the proposed bindings are recommendations.
[Feature overview and mapping examples](https://github.com/lewis6991/gitsigns.nvim/blob/main/README.md)

`stage_hunk()` first looks for an unstaged hunk, then falls back to unstaging a
staged hunk. When staged and unstaged edits overlap at the cursor, the unstaged
action wins. `reset_hunk()` modifies buffer contents; it is different from
unstaging. Whole-buffer helpers exist (`stage_buffer()` and
`reset_buffer_index()`), but ordinary hunk actions should be the first setup.
[Action implementation](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/lua/gitsigns/actions.lua)

## Settings and navigation

Keep sign-column indicators and staged signs enabled; both already default to
true. Start with `word_diff = true`, and leave full-line highlights (`linehl`)
and line-number highlights (`numhl`) off unless the gutter is hard to follow.
Keep the existing blame preference, with an optional toggle for dense reviews.
These choices favor precise change cues with limited extra coloring.

Word differences require the internal diff engine. `diff_opts` inherits Neovim's
`diffopt`. The installed Neovim v0.12.6 already defaults to internal diff,
indent heuristics, and `linematch:40`; no local overrides were found. Keep those
initially. Consider `algorithm = 'histogram'` only if existing line alignment is
awkward; this is optional tuning. Avoid globally ignoring whitespace when those
changes matter to review.
[Configuration source](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/lua/gitsigns/config.lua)

`nav_hunk()` defaults to `target = 'unstaged'`; staged signs alone do not make
ordinary navigation include staged hunks. Preserve that default for editing,
then add staged-only review navigation, or deliberately choose `target = 'all'`.
It also supports `preview = true`, counts, and first/last navigation. Once a
preview is open, navigation can reopen it at the next hunk. With `linematch`,
`greedy = false` permits finer navigation between contiguous sub-hunks.
[Navigation source](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/lua/gitsigns/actions/nav.lua)

## Diff workflows to use

For the current file, `diffthis()` uses its configured base, normally the index.
The index buffer is editable: writing it updates staging. Use explicit
`diffthis('HEAD')` for comparison with the latest commit. `diffthis(nil,
{ unified = true })` gives an inline whole-file diff; repeat it to close.
In unified comparisons, staging/reset keep their normal comparison base.
[File diff implementation](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/lua/gitsigns/actions/diffthis.lua)

Do not use `~` as shorthand for `HEAD`: Gitsigns normalizes it to `HEAD~`, the
parent commit. Explicit revision names avoid ambiguity.
[Revision normalization](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/lua/gitsigns/util.lua)

The existing repository diff panel also supports `gu` to switch unified/split
layouts, `]f` / `[f` to move between files, and `g?` for its bindings. In
working-tree comparisons, `s`, `u`, and Space stage, unstage, or toggle staging
for files/directories. Those panel actions operate on saved files. The panel
list reflects disk; unsaved edits can still appear in the file pane.

Keep `origin/main...HEAD` for reviewing committed branch changes since the merge
base. Use `:Gitsigns diff --commit` for the latest commit, including a root commit.
`change_base()` is useful for signs against an older revision, but keep the
normal index base for everyday staging; reset it with `:Gitsigns reset_base`.
[Upstream help](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/doc/gitsigns.txt)

## Quickfix and optional features

`setqflist('all')` builds a cross-file hunk queue using saved files and the global
comparison base; it can cover repositories represented by attached buffers plus
the working directory. Current-buffer and `'attached'` lists use cached buffer
hunks, including unsaved edits. A buffer-only base change therefore does not
redefine the repository-wide list. Enable `attach_to_untracked = true` if new
files should also participate in this workflow.
[Quickfix implementation](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/lua/gitsigns/actions/qflist.lua)

Blame splits/popups, historical-file views, sign counts, and statusline data are
useful secondary features. Existing diff and hunk work should take priority.
Avoid deprecated `next_hunk()` / `prev_hunk()`, `undo_stage_hunk()`, and
`show_deleted` / `toggle_deleted()` in new mappings; use `nav_hunk()`,
`stage_hunk()` on staged changes, and inline preview/unified diff instead.
[API and deprecations](https://github.com/lewis6991/gitsigns.nvim/blob/d4854fa9a94b5c8b37dd209fb4a19e98e764186f/doc/gitsigns.txt)
