# Image previews for this Neovim configuration

Researched: 2026-11-03. Primary documentation and source were inspected; no plugins or tools were installed and no real terminal rendering test was performed. Links to moving branches describe the versions consulted on this date.

## Recommendation

**Use an existing image renderer and write only the configuration glue.** If changing terminal is acceptable, trial **Snacks.image with Kitty or Ghostty**, retaining `render-markdown.nvim`. Choose **image.nvim with Kitty** instead if cursor-only previews or its image API better fit the desired workflow. These are recommendations based on the documented features below, not measured performance or a completed compatibility test.

If Apple Terminal must remain the only terminal, use a **browser Markdown preview plus an external image viewer**. That changes the desired experience: pictures appear outside the Neovim editing window. No supported native bitmap route for Apple Terminal was established among the evaluated plugins; building a Lua renderer does not remove their terminal-protocol dependency. See the evidence below before treating any broad “works with any terminal” claim as equivalent to normal pictures.

## Requirements and local context

Confirmed by the user:

- Open image files as pictures automatically, fitted to the window with proportions preserved.
- Show pictures inside the Markdown editing window.
- Support both relative local references and remote image URLs immediately.
- The current terminal is the built-in macOS Terminal application.

The repo uses NvChad/lazy.nvim, configures `render-markdown.nvim` with default options in [the plugin list](../../lua/plugins/init.lua), and includes Markdown parsers in [Treesitter configuration](../../lua/configs/treesitter.lua). No separate browser-preview or image-renderer plugin was found in those configuration files or the lockfile. Prior local inspection reported Neovim 0.12.6. These are repository observations, not claims about upstream defaults.

Still undecided: another terminal, tmux/SSH support, all visible images versus cursor-only display, automatic remote downloads, and formats beyond PNG/JPEG. The comparison does not assume those answers.

## Options compared

| Option | What it provides | Fit and constraint |
| --- | --- | --- |
| [Snacks.image](https://github.com/folke/snacks.nvim/blob/main/docs/image.md) | Automatic image-file display and inline Markdown pictures. | Leading trial if Kitty/Ghostty is acceptable. WezTerm lacks its inline mode. |
| [image.nvim](https://github.com/3rd/image.nvim#configuration) | File hijacking, Markdown local/remote images, cursor-only popup or inline modes. | Strong focused alternative; Kitty is upstream's recommended backend. |
| [markdown-preview.nvim](https://github.com/iamcco/markdown-preview.nvim#introduction) | Live browser rendering with synchronized scrolling and local images. | Useful while staying in Apple Terminal, but outside the editor. |
| [Chafa](https://github.com/hpjansson/chafa#about) | Terminal graphics or ANSI/Unicode character art, depending on capabilities. | Character approximation is a possible fallback, not the same image quality. |
| Small custom integration | Configuration, a toggle/keymap, or opening an external viewer. | Reasonable glue; a new Markdown/image renderer is unnecessary for these needs. |

### Snacks.image

Verified: uses Kitty Graphics Protocol; documentation lists Kitty and Ghostty, with limited WezTerm support and no inline images there. ImageMagick converts non-PNG images. Markdown uses Treesitter; configuration exposes document size limits, inline/floating modes, and a path resolver. The default conversion selects the first raster frame, so listed GIF support should not be interpreted as guaranteed animation. [Image documentation](https://github.com/folke/snacks.nvim/blob/main/docs/image.md)

Source confirms remote URLs are fetched using `curl` or `wget`; this is not just a local-image feature. [Conversion source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/convert.lua)

Path resolution searches the working directory, the document directory and configured image directories; a custom resolver is available. Visible-range discovery is implemented. For reproducible relative paths, test a document opened from a different working directory, including duplicate filenames in potential search roots. [Document source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/doc.lua)

The implementation handles scrolling, edits and buffer entry through scheduled updates. Placement uses virtual lines/Unicode placeholders and accounts for adjacent text and wrapping; this is an existing implementation of the hard editor-layout work. [Inline source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/inline.lua), [placement source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/placement.lua)

The fit helper preserves the image's ratio within available cell dimensions. File interception uses `BufReadCmd`; its health check reports terminal and conversion issues. [Fit source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/util.lua), [setup/health source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/init.lua)

Only enable the image module. Snacks modules require explicit configuration, and its installation guide recommends early setup (`lazy = false`, `priority = 1000`). Do not load exclusively on Markdown filetype: opening `nvim picture.png` must also work. The last sentence is the integration implication of the setup model. [Snacks installation](https://github.com/folke/snacks.nvim#installation)

### image.nvim

Verified: supports Kitty, Überzug++, and Sixel backends. Kitty is recommended; Sixel requires a supporting terminal and upstream describes lower performance. ImageMagick is required; the default CLI processor avoids needing LuaRocks, while optional FFI bindings add that setup. Remote images require cURL. Defaults include Markdown remote downloads, cursor-only controls, window-relative sizing and image-file interception. Tmux requires passthrough and related configuration. [Dependencies and configuration](https://github.com/3rd/image.nvim#dependencies)

The Markdown integration parses Markdown image references with Treesitter. This offers existing document integration rather than merely a low-level image API. [Markdown integration source](https://github.com/3rd/image.nvim/blob/master/lua/image/integrations/markdown.lua)

Recommendation: prefer this option if the desired design becomes “show the image at my cursor” or if a focused image API is needed. This is a workflow judgment, not a benchmark ranking.

## Keeping the existing Markdown renderer

`render-markdown.nvim` explicitly says it does no native image rendering and aims not to interfere with image plugins such as `image.nvim`. It recommends `only_render_image_at_cursor`. Therefore replacing it is not necessary to start the trial. This does **not** prove every all-images layout or Snacks combination is conflict-free; both plugins use editor decorations, so actual coexistence needs a terminal smoke test. [Renderer image guidance](https://github.com/MeanderingProgrammer/render-markdown.nvim#images)

Keep headings, tables and existing Markdown behavior during the trial. If rendering clashes, first test cursor-only images or concealment settings before considering a renderer replacement. That is a proposed troubleshooting order, not an upstream compatibility guarantee.

## Apple Terminal: what the evidence establishes

Snacks' terminal implementation marks Kitty and Ghostty as supporting Unicode image placeholders, and WezTerm as lacking them; it has no supported Apple Terminal entry. [Terminal source](https://github.com/folke/snacks.nvim/blob/main/lua/snacks/image/terminal.lua)

More directly, Chafa's terminal database identifies `TERM_PROGRAM=Apple_Terminal` with text/color sequences and no pixel-protocol capabilities. Its Ghostty entry includes image support. This is primary implementation evidence about Chafa's capability model, not an exhaustive specification of every Apple Terminal version. [Chafa terminal database](https://github.com/hpjansson/chafa/blob/master/chafa/chafa-term-db.c)

The “any terminal” Überzug++ route should not be read as native pictures on Apple Terminal: its Chafa canvas explicitly selects symbol mode with block/border/space characters. [Überzug++ Chafa canvas](https://github.com/jstkdng/ueberzugpp/blob/master/src/canvas/chafa.cpp)

**Inference:** for the requested ordinary bitmap images inside Neovim, switching to a documented graphics-capable terminal is the practical path among these options. This research did not experimentally probe Apple Terminal or prove that no possible external overlay/GUI approach exists. Ghostty's own documentation confirms Kitty Graphics Protocol and macOS support; Kitty defines the protocol used by the recommended routes. [Ghostty features](https://ghostty.org/docs/features), [Kitty graphics protocol](https://sw.kovidgoyal.net/kitty/graphics-protocol/)

### If Apple Terminal stays

`markdown-preview.nvim` runs the preview in a browser, supports macOS and synchronized scrolling, and offers a prebuilt install route or a Node-based build. Its image renderer leaves remote HTTP image URLs for the browser and rewrites local references to its image-serving endpoint. This covers both image sources without requiring terminal graphics, but not inside the editing buffer. [Plugin README](https://github.com/iamcco/markdown-preview.nvim), [image renderer source](https://github.com/iamcco/markdown-preview.nvim/blob/master/app/pages/image.js)

For standalone image files, macOS Preview already opens images. A small Neovim command/keymap could delegate to it. This would be an explicit external-viewer fallback; automatically opening another application for every selected image needs a separate behavior decision. [Apple Preview guide](https://support.apple.com/guide/preview/open-pdfs-and-images-prvw81f73d4e/mac)

## Use existing tools or build?

**Recommended custom scope:** a lazy.nvim plugin specification, any small path-resolution customization actually needed by this repo, an image toggle if desired, sensible size limits, unsupported-terminal behavior, and README instructions. Use the chosen plugin for fetching, caching, resizing and placement.

**A custom renderer would duplicate** image conversion, remote loading/cache invalidation, Markdown parsing, placement during scrolling/edits, terminal size detection, split/overlap cleanup and graphics-protocol handling. These responsibilities are visible in the cited plugin source. The maintenance cost is an engineering inference; no speculative time estimate is assigned.

**A custom Lua plugin cannot make an unsupported terminal decode Kitty/Sixel image sequences.** The receiving terminal must implement the protocol; inventing a renderer only changes the sending side. An external native overlay or new GUI would be a substantially different product and is not justified by the current request. [Protocol architecture](https://sw.kovidgoyal.net/kitty/graphics-protocol/)

## Proposed implementation and verification

1. Decide whether another terminal is acceptable. If yes, trial Snacks.image in Kitty or Ghostty; otherwise choose the external-preview compromise explicitly.
2. Install the chosen terminal and image dependencies separately from repo edits; keep the current Markdown renderer. For Snacks, enable just image support early enough for direct file opening.
3. Verify `:checkhealth snacks` (if selected), then open PNG and JPEG through `nvim image.png`, `:edit`, NvimTree and Telescope. Confirm fit, proportions, resize behavior and clean buffer changes.
4. Use one Markdown fixture with relative paths, spaces in filenames, multiple images and a public HTTPS image. Open it from a different working directory. Check scrolling, splits, normal/insert modes, headings and tables with `render-markdown.nvim` enabled.
5. Check missing local files, offline/failed remote fetches and unsupported terminals. Confirm editing remains usable, image buffers do not overwrite source pictures, and closing previews leaves no stale images.
6. Test tmux/SSH only if required. Snacks documents tmux passthrough and remote transfer handling; that is not proof the user's eventual environment works. Record the tested terminal/plugin versions in the implementation notes. [Transport documentation](https://github.com/folke/snacks.nvim/blob/main/docs/image.md)

These are proposed manual acceptance checks. Headless Lua checks can verify configuration/loading, but cannot establish actual terminal image quality or decoration coexistence. No runtime validation is claimed by this report.

## Decisions needed before implementation

- Can Neovim run in Kitty/Ghostty, or must Apple Terminal remain the only terminal?
- Are tmux or SSH part of the required environment?
- Should every visible Markdown image appear, or only the one at the cursor?
- Should remote URLs fetch automatically, and are public URLs sufficient?
- Which extra formats, if any, are required beyond PNG/JPEG?

The research is ready for a decision; runtime configuration remains unchanged.
