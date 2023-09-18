vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = { '*.gohtml', '*.go.html' },
	callback = function() vim.opt_local.filetype = 'gohtmltmpl' end,
})
vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
	pattern = { '*.gotmpl', '*.go.tmpl' },
	callback = function() vim.opt_local.filetype = 'gotexttmpl' end,
})
