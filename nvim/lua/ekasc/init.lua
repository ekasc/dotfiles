-- Capture the directory Neovim was started in.
-- We use this for per-project language server workspaces.
vim.g.start_cwd = (vim.uv or vim.loop).cwd()

require("ekasc.keymap")
require("ekasc.set")
require("ekasc.lazy")
