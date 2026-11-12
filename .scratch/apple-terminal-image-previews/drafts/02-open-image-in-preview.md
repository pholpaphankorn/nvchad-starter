# 02: Open the current image file in macOS Preview

**Parent spec:** [Image previews while keeping Apple Terminal](../spec.md). This ticket implements the image-file preview portion of that spec and follows its shared scope and testing decisions.

**What to build:** From Neovim running in Apple Terminal, explicitly open the current local PNG/JPEG image in macOS Preview using a command or normal-mode shortcut. Deliver the user action, clear failure handling, focused behavior checks, and usage documentation as one complete slice.

**Blocked by:** None. Independent of ticket 01; implementation begins only after user approval.

**Status:** Draft — awaiting user approval; unpublished.

- [ ] Provide `:ImagePreview` and one descriptive, non-conflicting normal-mode shortcut that invokes the same current-buffer action.
- [ ] The action accepts existing local PNG/JPEG regular files, recognizing PNG, JPG, and JPEG extensions case-insensitively. It hands the absolute filename to the macOS application launcher targeting Preview.
- [ ] The command works after opening an image through either the existing file explorer or file finder, and remains correct when Neovim's working directory differs from the image directory.
- [ ] Spaces and shell-special characters in filenames are passed literally using asynchronous argument-vector process execution. The launcher is never built by interpolating filenames into a shell command.
- [ ] Unnamed buffers, missing files, directories, and unsupported types produce useful notifications and launch no application.
- [ ] Launcher startup failures and nonzero launcher exits are reported without blocking editing. A successful handoff is not treated as proof that a Preview window rendered correctly.
- [ ] The action views the saved image on disk without writing, replacing, deleting, or transforming it, or discarding modified buffer contents.
- [ ] Opening or selecting an image buffer alone launches no application; invoking the command or shortcut is required.
- [ ] Loading the configuration on another operating system remains safe; invoking the macOS-only action there reports the platform requirement.
- [ ] Focused headless command-level checks substitute only the operating-system launch boundary and cover literal paths, validation, preserved source/buffer state, and failure notifications. Reuse the repository's lightweight Lua assertion style; add no framework or test-only public abstraction.
- [ ] A real Mac acceptance check shows the intended PNG and JPEG in macOS Preview through both the command and shortcut, with Neovim remaining usable in Apple Terminal. Record actual evidence and any unperformed checks.
- [ ] Document the command, selected shortcut, saved-file behavior, supported types, external application, platform requirement, and error recovery.

## Review Context

The approved direction is an external image viewer while retaining Apple Terminal. This deliberately uses an explicit action instead of the earlier automatic in-editor image-file display idea. Browser Markdown preview, images under a Markdown cursor, remote image downloads, extra formats, and image editing are outside this slice.

This ticket needs no browser preview plugin, terminal graphics plugin, ImageMagick dependency, or shared preview framework. It can be implemented independently of ticket 01.

**Test entry point:** invoke the public `:ImagePreview` command for representative current buffers and replace only the OS launcher in automated checks. Verify the visible result with the real Preview application separately.

**Primary reference:** [Apple Preview guide](https://support.apple.com/guide/preview/open-pdfs-and-images-prvw81f73d4e/mac).
