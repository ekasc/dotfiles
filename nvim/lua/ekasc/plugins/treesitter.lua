return {
	"nvim-treesitter/nvim-treesitter",
	branch = "main",
	build = ":TSUpdate",
	cmd = { "TSInstall", "TSUpdate", "TSUninstall" },
	config = function()
		local parser_dir = vim.fn.stdpath("data") .. "/site/parser"

		local parsers = {
			"go", "json", "tsx", "css", "html", "python",
			"javascript", "typescript", "lua", "sql",
			"markdown", "markdown_inline",
		}

		for _, lang in ipairs(parsers) do
			if vim.fn.filereadable(parser_dir .. "/" .. lang .. ".so") == 0 then
				require("nvim-treesitter.install").install({ lang }):wait(300000)
			end
		end

		local max_filesize = 200 * 1024
		vim.api.nvim_create_autocmd("BufReadPost", {
			callback = function(args)
				local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
				if ok and stats and stats.size > max_filesize then
					vim.treesitter.stop(args.buf)
				end
			end,
		})
	end,
}
