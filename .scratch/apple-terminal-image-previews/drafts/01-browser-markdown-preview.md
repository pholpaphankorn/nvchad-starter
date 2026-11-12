# 01: Preview Markdown and its images in the browser

**Parent spec:** [Image previews while keeping Apple Terminal](../spec.md). This ticket implements the browser Markdown preview portion of that spec and follows its shared scope and testing decisions.

**What to build:** From Neovim running in Apple Terminal, explicitly start a live browser Markdown preview containing both local and public remote images, while keeping the current in-editor Markdown renderer. Deliver the plugin integration, user shortcut, reproducible installation instructions, and real workflow verification as one complete slice.

**Blocked by:** None. Independent of ticket 02; implementation begins only after user approval.

**Status:** Draft — awaiting user approval; unpublished.

- [ ] Integrate `iamcco/markdown-preview.nvim` through the existing lazy.nvim and lockfile workflow, retaining `render-markdown.nvim` and the Markdown parsers.
- [ ] Use the documented upstream prebuilt installer as the initial setup route; verify it on the target Mac. Document the actual prerequisites and recovery/build steps if that route is unavailable. Opening Neovim does not rebuild plugin assets on every startup.
- [ ] Expose the upstream `MarkdownPreview`, `MarkdownPreviewStop`, and `MarkdownPreviewToggle` commands plus one descriptive, non-conflicting normal-mode toggle shortcut scoped to Markdown.
- [ ] Entering a Markdown buffer alone opens no browser. Explicitly starting preview opens the document in the default browser using the plugin's local preview server.
- [ ] A real browser preview shows relative local PNG/JPEG images, including spaces in filenames, and a public HTTPS image. Relative paths resolve from the Markdown document when Neovim starts in a different directory.
- [ ] The active preview updates during editing and provides the plugin's synchronized scrolling behavior. Start, stop, and toggle are demonstrated with the installed plugin.
- [ ] The existing in-editor Markdown renderer continues to display headings, tables, and links, and previewing leaves source contents and unsaved edits intact.
- [ ] Missing local assets or a failed remote request leave Markdown editing usable. Local images remain viewable while a remote image is unavailable.
- [ ] Document setup, commands, the selected shortcut, supported local/remote sources, stop behavior, and the external-browser experience.
- [ ] Record manual acceptance evidence from Apple Terminal and the real browser. Headless loading checks, if useful, do not claim to verify browser rendering. Report any unperformed checks explicitly.

## Review Context

The approved direction is to retain Apple Terminal and view complete Markdown documents in the browser. Inline terminal images, authenticated image URLs, SSH forwarding, extra image formats, and a renderer replacement are outside this slice. The current image-file command in ticket 02 is a separate workflow and creates no dependency.

**Test entry point:** the public Markdown preview commands/shortcut, exercised with the real plugin and a small document containing local and remote image references. Use existing lightweight repository checks where helpful; add no test framework or tests that only restate plugin configuration.

**Primary references:** [plugin README](https://github.com/iamcco/markdown-preview.nvim), [image source handling](https://github.com/iamcco/markdown-preview.nvim/blob/master/app/pages/image.js), [renderer ecosystem guidance](https://github.com/MeanderingProgrammer/render-markdown.nvim/blob/main/doc/markdown-ecosystem.md).
