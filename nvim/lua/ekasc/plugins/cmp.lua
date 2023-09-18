local M = {
	'hrsh7th/nvim-cmp',
	dependencies = {
		{ 'hrsh7th/cmp-buffer' },
		{ 'hrsh7th/cmp-path' },
		{ 'saadparwaiz1/cmp_luasnip' },
		{ 'hrsh7th/cmp-nvim-lsp' },
		{ 'hrsh7th/cmp-nvim-lua' },
		{ 'onsails/lspkind.nvim' },
		-- Snippets
		{
			'L3MON4D3/LuaSnip',
			dependencies = {
				{ 'rafamadriz/friendly-snippets' },
			},
		},
	}

}

function M.config()
	local cmp = require('cmp')
	local luasnip = require('luasnip')

	local kind_icons = {
		Text = '󰊄',
		Method = 'm',
		Function = '󰊕',
		Constructor = '',
		Field = '',
		Variable = '󰫧',
		Class = '',
		Interface = '',
		Module = '',
		Property = '',
		Unit = '',
		Value = '',
		Enum = '',
		Keyword = '󰌆',
		Snippet = '',
		Color = '',
		File = '',
		Reference = '',
		Folder = '',
		EnumMember = '',
		Constant = '',
		Struct = '',
		Event = '',
		Operator = '',
		TypeParameter = '󰉺',
	}

	cmp.setup({
		snippet = {
			expand = function(args)
				luasnip.lsp_expand(args.body)
			end,
		},
		window = {
			completion = cmp.config.window.bordered(),
			documentation = cmp.config.window.bordered()
		},
		mapping = cmp.mapping.preset.insert({
			['<C-p'] = cmp.mapping.scroll_docs(-1),
			['<C-n'] = cmp.mapping.scroll_docs(1),
			['<CR>'] = cmp.mapping.confirm({ select = true }),
		}),
		formatting = {
			fields = { 'kind', 'abbr', 'menu' },
			format = function(entry, vim_item)
				vim_item.kind = string.format('%s', kind_icons[vim_item.kind])
				vim_item.menu = ({
					nvim_lua = '[Lua]',
					nvim_lsp = '[Lsp]',
					luasnip = '[Snippet]',
					buffer = '[Buffer]',
					path = '[Path]',
				})[entry.source.name]
				return vim_item
			end,
		},
		sources = cmp.config.sources({
			{ name = 'nvim_lsp' },
			{ name = 'luasnip' },
			{ name = 'buffer' },
			{ name = 'path' },
		}),
		['<Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif luasnip.expand_or_jumpable() then
				luasnip.expand_or_jump()
			else
				fallback()
			end
		end, { 'i', 's' }),
		['<S-Tab>'] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif luasnip.jumpable(-1) then
				luasnip.jump(-1)
			else
				fallback()
			end
		end, { 'i', 's' }),
		confirm_opts = {
			behavior = cmp.ConfirmBehavior.Replace,
			select = true,
		},
		experimental = {
			ghost_text = false,
		}
	})
	require('luasnip/loaders/from_vscode').lazy_load()
	cmp.setup.cmdline('/', {
		mapping = cmp.mapping.preset.cmdline(),
		sources = {
			{ name = 'buffer' }
		}
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
