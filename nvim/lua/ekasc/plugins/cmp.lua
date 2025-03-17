---@diagnostic disable: missing-fields
local M = {
	"hrsh7th/nvim-cmp",
	dependencies = {
		{ "hrsh7th/cmp-buffer" },
		{ "hrsh7th/cmp-path" },
		{ "saadparwaiz1/cmp_luasnip" },
		{ "hrsh7th/cmp-nvim-lsp" },
		{ "hrsh7th/cmp-nvim-lua" },
		{ "onsails/lspkind.nvim" },
		-- Snippets
		{
			"L3MON4D3/LuaSnip",
			dependencies = {
				{ "rafamadriz/friendly-snippets" },
			},
		},
	},
}

function M.config()
	local cmp = require("cmp")
	local luasnip = require("luasnip")
	local kind_icons = {
		Text = "󰊄",
		Method = "m",
		Function = "󰊕",
		Constructor = "",
		Field = "",
		Variable = "󰫧",
		Class = "",
		Interface = "",
		Module = "",
		Property = "",
		Unit = "",
		Value = "",
		Enum = "",
		Keyword = "󰌆",
		Snippet = "",
		Color = "",
		File = "",
		Reference = "",
		Folder = "",
		EnumMember = "",
		Constant = "",
		Struct = "",
		Event = "",
		Operator = "",
		TypeParameter = "󰉺",
		Codeium = "",
		Copilot = "",
	}

	local has_words_before = function()
		if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
			return false
		end
		local line, col = unpack(vim.api.nvim_win_get_cursor(0))
		return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
	end

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered(),
		},
		sorting = {
			priority_weight = 2,
			comparators = {
				require("copilot_cmp.comparators").prioritize,

				-- Below is the default comparitor list and order for nvim-cmp
				cmp.config.compare.offset,
				-- cmp.config.compare.scopes, --this is commented in nvim-cmp too
				cmp.config.compare.exact,
				cmp.config.compare.score,
				cmp.config.compare.recently_used,
				cmp.config.compare.locality,
				cmp.config.compare.kind,
				cmp.config.compare.sort_text,
				cmp.config.compare.length,
				cmp.config.compare.order,
			},
		},
		mapping = require("lsp-zero").defaults.cmp_mappings({
			["<C-p"] = cmp.mapping.select_prev_item(),
			["<C-n"] = cmp.mapping.select_next_item(),
			["<C-y"] = cmp.mapping.confirm({ select = true }),
			["<CR>"] = cmp.mapping.confirm({ select = true }),
			["<Tab>"] = vim.schedule_wrap(function(fallback)
				if cmp.visible() and has_words_before() then
					cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
				else
					fallback()
				end
			end),
			-- ["<Tab>"] = cmp.mapping(function(fallback)
			-- 	if cmp.visible() then
			-- 		cmp.select_next_item()
			-- 	elseif luasnip.expandable() then
			-- 		luasnip.expand()
			-- 	else
			-- 		fallback()
			-- 	end
			-- end, {
			-- 	"i",
			-- 	"s",
			-- }),
			-- ["<S-Tab>"] = cmp.mapping(function(fallback)
			-- 	if cmp.visible() then
			-- 		cmp.select_prev_item()
			-- 	elseif luasnip.jumpable(-1) then
			-- 		luasnip.jump(-1)
			-- 	else
			-- 		fallback()
			-- 	end
			-- end, {
			-- 	"i",
			-- 	"s",
			-- }),
		}),
		formatting = {
			fields = { "kind", "abbr", "menu" },
			format = function(entry, vim_item)
				vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
				vim_item.menu = ({
					nvim_lua = "[Lua]",
					nvim_lsp = "[Lsp]",
					luasnip = "[Snippet]",
					buffer = "[Buffer]",
					path = "[Path]",
					-- codeium = "[AI]",
					copilot = "[AI]",
				})[entry.source.name]
				return vim_item
			end,
		},
		sources = cmp.config.sources({
			{ name = "nvim_lsp" },
			{ name = "luasnip" },
			-- { name = "codeium" },
			{ name = "copilot" },
			{ name = "buffer" },
			{ name = "path" },
		}),
		confirm_opts = {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		experimental = {
			ghost_text = false,
		},
	})
	require("luasnip/loaders/from_vscode").lazy_load()
	require("luasnip").filetype_extend("typescriptreact", { "html" })
	require("luasnip").filetype_extend("astro", { "html" })
	cmp.setup.cmdline("/", {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = "buffer" },
		},
	})

	-- `:` cmdline setup.
	--[[ cmp.setup.cmdline(':', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = cmp.config.sources({
			{ name = 'path' },
			{ name = 'buffer' }
		}, {
			{
				name = 'cmdline',
				option = {
					ignore_cmds = { 'Man', '!' }
				}
			}
		})
	}) ]]
end

return M
