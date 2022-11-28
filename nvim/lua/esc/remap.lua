local nnoremap = require("esc.keymap").nnoremap
local builtin = require("telescope.builtin")

--nnoremap("<leader>pv","<cmd>Ex<CR>")
nnoremap("<leader>v","<cmd>FZF<CR>")
nnoremap('<leader>ff', builtin.find_files)
nnoremap('<leader>fg', builtin.live_grep)
nnoremap('<leader>fb', builtin.buffers)
nnoremap('<leader>fh', builtin.help_tags)
