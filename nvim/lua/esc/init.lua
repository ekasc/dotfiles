require("esc.set")
require("esc.remap")
vim.cmd [[let g:python3_host_prog = '/usr/local/bin/python3']]
require("esc.lspconfig")
require('go').setup()
--require'lspconfig'.gopls.setup{}
