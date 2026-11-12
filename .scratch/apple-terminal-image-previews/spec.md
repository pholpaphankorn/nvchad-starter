# Spec: Image previews while keeping Apple Terminal

**Status:** Draft — awaiting user approval of scope, test approach, and ticket breakdown.

## Problem Statement

The user edits Markdown and browses image files in a personal Neovim configuration while using the built-in macOS Terminal application. The existing Markdown renderer formats text inside Neovim but does not display the referenced pictures. Image files also need a convenient way to be viewed as pictures.

The user wants local and remote Markdown images and convenient image-file previews while continuing to use Apple Terminal. Research did not establish a supported route to ordinary inline bitmap images in Apple Terminal among the evaluated plugins. The user has selected the recommended browser Markdown preview and macOS Preview workflow.

## Solution

Add an explicitly started browser Markdown preview using `iamcco/markdown-preview.nvim`, alongside the existing `render-markdown.nvim` editing experience. The browser displays the whole document, including local images and public remote image URLs, and updates as the user edits.

Add an explicit `:ImagePreview` command and a discoverable normal-mode shortcut to open the current local PNG or JPEG file in macOS Preview. The command uses the on-disk image associated with the current buffer. Browser and image-file previews open in separate applications while Neovim remains in Apple Terminal.

Proposed defaults for approval: application launches are explicit; the browser is the macOS default browser; no particular browser or window arrangement is required. Entering Markdown or image buffers alone does not launch an application. This external image-file action supersedes the earlier automatic in-editor image-file display request.

## User Stories

1. As a Neovim user, I want to keep using Apple Terminal, so that image previews fit my current terminal workflow.
2. As a Markdown author, I want to retain the existing in-editor Markdown renderer, so that headings, tables, and links stay readable while I edit.
3. As a Markdown author, I want to start a browser Markdown preview on demand, so that I can choose when to open another application.
4. As a Markdown author, I want a discoverable shortcut for the browser preview, so that I can use it without remembering a long command.
5. As a Markdown author, I want a rendered view of the whole document, so that I can inspect text and pictures together.
6. As a Markdown author, I want relative local image references to resolve from the Markdown document, so that previews work regardless of Neovim's working directory.
7. As a Markdown author, I want local image filenames containing spaces to display, so that ordinary asset names work without renaming files.
8. As a Markdown author, I want public remote image URLs to display in the browser, so that web-hosted pictures are visible alongside local assets.
9. As a Markdown author, I want an active preview to update as I edit, so that I can review changes without repeatedly reopening the browser.
10. As a Markdown author, I want synchronized scrolling using the preview plugin's supported behavior, so that navigating a document also moves its preview.
11. As a Markdown author, I want to stop or toggle the browser preview, so that I can manage its lifecycle from Neovim.
12. As a Markdown author, I want missing images or an unavailable network to leave editing usable, so that a failed picture does not interrupt my work.
13. As a Neovim user, I want the default browser to open previews, so that I do not need to configure a specific browser.
14. As a Neovim user, I want a single command to open the current image file in macOS Preview, so that I can inspect its actual contents.
15. As a Neovim user, I want a discoverable shortcut for image-file previews, so that I can invoke the same action quickly.
16. As a Neovim user, I want PNG and JPEG files to open from their actual absolute location, so that image previews work across project directories.
17. As a Neovim user, I want spaces and shell-special characters in image filenames handled literally, so that the intended image is opened correctly.
18. As a Neovim user, I want a useful message for unnamed buffers, missing files, and unsupported file types, so that I understand why an image-file preview did not open.
19. As a Neovim user, I want launcher failures reported without blocking editing, so that I can correct the problem and continue working.
20. As a Neovim user, I want preview actions to leave my source files and unsaved edits untouched, so that viewing does not change my work.
21. As a Neovim user, I want to invoke image-file previews after opening a file through either the explorer or file finder, so that the action works with my existing navigation tools.
22. As the configuration owner, I want installation and usage documented, so that I can reproduce the setup on another Mac.
23. As the configuration owner, I want browser-preview plugin revisions recorded by the existing lockfile workflow, so that another installation can restore the same plugin revision.

## Implementation Decisions

- Keep the existing Markdown renderer and Markdown parsers. Introduce the browser preview plugin through the existing lazy.nvim configuration and lockfile workflow.
- Use the browser preview plugin's documented prebuilt installation hook as the initial installation route. Verify availability on the actual Mac; document a source-build fallback and its prerequisites if the prebuilt route is unavailable. Installing or building plugin assets belongs to plugin setup, rather than every editor startup.
- Retain upstream `MarkdownPreview`, `MarkdownPreviewStop`, and `MarkdownPreviewToggle` commands. Add one descriptive, non-conflicting normal-mode shortcut for toggling Markdown preview, scoped to Markdown. Exact key selection follows inspection of the effective NvChad mappings during implementation.
- Use the default browser and the plugin's local preview server, with explicit start, live updates, and synchronized scrolling. Keep the upstream local-only server default. Browser image fetching begins as part of the explicitly opened document preview.
- Support standard Markdown image references to local PNG/JPEG assets and public HTTP(S) image URLs. Local references must be relative to the document, including when the working directory differs. Missing assets or failed remote requests may retain the browser's ordinary broken-image presentation while editing continues.
- Use upstream preview rendering, fetching, and lifecycle behavior. Confirm stop/toggle behavior with the installed plugin; closing a browser tab by hand is not specified as equivalent to stopping the preview session.
- Implement `:ImagePreview` for the current buffer's existing local PNG/JPEG file, accepting extension spelling case-insensitively. Add one descriptive, non-conflicting normal-mode shortcut that invokes the same action. The action remains independent of the browser preview plugin.
- Resolve the current buffer's filename to an absolute local filename, validate that it is an existing regular file of a supported type, and pass it literally to the macOS application launcher targeting Preview.
- Launch asynchronously with an argument vector rather than constructing a shell command. Report validation failures, launcher startup errors, and nonzero launcher exits through ordinary Neovim notifications. A successful launcher exit establishes handoff, not proof that a window was rendered correctly.
- Preview the saved image on disk. The image command must not save, replace, delete, or transform the source file or discard modified buffer contents.
- On non-macOS systems, invoking the image action reports that this Preview integration requires macOS. Registering the configuration remains safe; cross-platform viewer selection is outside this feature.
- Keep custom code limited to the image action, shortcut integration, and necessary configuration. Introduce no custom Markdown renderer, terminal graphics backend, or general preview framework.
- Document installation, commands, selected shortcuts, supported image sources, failure recovery, and the fact that previews appear in external applications. Each implementation ticket delivers its own usage documentation and verification evidence.

## Testing Decisions

- **Proposed seam for approval:** exercise the public Neovim commands and shortcuts as the feature entry point. Prefer this user-visible boundary over separate tests of plugin tables, mapping declarations, or private helpers.
- **Meaningful headless checks:** invoke the custom image command with temporary PNG/JPEG paths while substituting only the operating-system launch boundary. Verify the literal absolute filename, target application, no launch for invalid buffers/files, supported extension handling, and observable failure notifications. This checks command behavior rather than duplicating its implementation.
- Cover filenames containing spaces and shell-special characters, an unrelated working directory, unnamed and missing files, unsupported types, launcher failures, and invocation outside macOS. Source contents and modified-buffer state must remain intact.
- **Prior art:** the repository already has a standalone headless Lua regression check with isolated dependencies and plain assertions. Reuse that lightweight execution style if automated checks are added; introduce no test framework or abstraction solely for this feature.
- **Browser acceptance:** from Apple Terminal, start, stop, and toggle the real plugin; check live text updates, scrolling, relative local PNG/JPEG images, spaces in filenames, a public HTTPS image, and a different working directory. Confirm existing in-editor Markdown behavior still works.
- **Image-file acceptance:** from Apple Terminal, use both the command and shortcut on real PNG/JPEG files opened through the existing explorer and file finder. Confirm macOS Preview displays the intended picture and Neovim stays usable.
- A missing local image and a failed remote request must not prevent further Markdown editing or local-image viewing. An offline remote check is a manual acceptance case, not a network-dependent automated test.
- Perform browser and Preview visual checks on a real Mac. Headless checks and mocked launch calls cannot establish real application rendering. Report any acceptance checks that could not be performed, rather than treating them as passed.

## Out of Scope

- Inline Markdown images or terminal bitmap rendering inside Apple Terminal.
- Switching to Kitty, Ghostty, another terminal, or a Neovim GUI.
- Automatically launching Preview or a browser when a buffer is entered.
- Opening a Markdown image under the cursor in Preview; this image command targets the current image-file buffer.
- Authenticated remote images, standalone remote-image downloads, custom credentials, or custom caching.
- Guaranteed formats beyond PNG/JPEG, animation playback, SVG/PDF handling, diagrams, and image editing.
- A custom renderer, custom browser service, custom window-placement automation, or cross-platform external-viewer abstraction.
- Remote Neovim over SSH, browser forwarding, or a tmux-specific support commitment. These were not established as requirements.
- Replacing the existing explorer, file finder, Markdown renderer, or test infrastructure.

## Further Notes

This is a synthesis draft, not an implementation authorization. The user requested approval of the proposed spec and tickets before publication or implementation. The test approach above is also awaiting that approval.

No tracker configuration or triage-label mapping was found. Run `/setup-matt-pocock-skills` before publishing the approved spec or tickets. The local drafts do not establish a tracker choice and are not marked `ready-for-agent`.

The two proposed tickets are independent complete user workflows. There is no necessary prefactoring or shared infrastructure ticket. Each includes configuration/code, documentation, and verification appropriate to its behavior.

Both tickets implement this parent spec: [01: Browser Markdown preview](drafts/01-browser-markdown-preview.md) and [02: Image-file preview in macOS Preview](drafts/02-open-image-in-preview.md). Neither ticket blocks the other; completing both and verifying their acceptance criteria fulfills the implementation scope of this spec.

The browser preview plugin documents its installation routes, commands, live updates, and scrolling in its [official README](https://github.com/iamcco/markdown-preview.nvim). Its [image renderer](https://github.com/iamcco/markdown-preview.nvim/blob/master/app/pages/image.js) handles local and remote image sources. The current Markdown renderer lists browser previews as complementary in its [ecosystem guide](https://github.com/MeanderingProgrammer/render-markdown.nvim/blob/main/doc/markdown-ecosystem.md). Apple's [Preview guide](https://support.apple.com/guide/preview/open-pdfs-and-images-prvw81f73d4e/mac) describes opening images in Preview. Runtime compatibility remains to be verified during implementation.
