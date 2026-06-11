local function on_attach(client, bufnr)
	local map = function(mode, lhs, rhs, desc)
		vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
	end

	local function snacks_picker(name)
		return function()
			require("snacks").picker[name]()
		end
	end

	map("n", "gd", vim.lsp.buf.definition, "Go to definition [LSP]")
	map("n", "gt", vim.lsp.buf.type_definition, "Go to type definition")
	map("n", "gD", vim.lsp.buf.declaration, "Go to declaration [LSP]")
	map("n", "gi", snacks_picker("lsp_implementations"), "Go to implementation [LSP]")
	map("n", "gw", snacks_picker("lsp_symbols"), "Document symbols [LSP]")
	map("n", "gW", snacks_picker("lsp_workspace_symbols"), "Workspace symbols [LSP]")
	map("n", "<leader>vrr", snacks_picker("lsp_references"), "Show references [LSP]")
	map("n", "<c-k>", function()
		vim.lsp.buf.signature_help({ border = "single" })
	end, "Signature help [LSP]")
	map("n", "<leader>vca", vim.lsp.buf.code_action, "Code action [LSP]")
	map("n", "<leader>vcf", function()
		local bufnr = vim.api.nvim_get_current_buf()
		local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
		local replacements = {}
		for i, line in ipairs(lines) do
			local new_line, count = line:gsub("([%w:_]+)%-%[var%(--([^)]+)%)%]", "%1-(--%2)")
			if count > 0 then
				table.insert(replacements, { idx = i - 1, text = new_line })
			end
		end
		if #replacements == 0 then
			vim.notify("No Tailwind canonical suggestions found")
			return
		end
		for _, r in ipairs(replacements) do
			vim.api.nvim_buf_set_lines(bufnr, r.idx, r.idx + 1, false, { r.text })
		end
		vim.notify("Fixed " .. #replacements .. " Tailwind canonical class suggestions")
	end, "Fix Tailwind canonical classes [LSP]")
	map("n", "<leader>vrn", vim.lsp.buf.rename, "Rename [LSP]")
	map("n", "<leader>vd", vim.diagnostic.open_float, "Show diagnostic [LSP]")
	map("n", "K", vim.lsp.buf.hover, "Hover info [LSP]")
	-- map("n", "K", vim.diagnostic.open_float, "Hover info [LSP]")

	if client.name == "svelte" or client.name == "typescript-tools" then
		map("n", "<Leader>oi", "<Cmd>TSToolsOrganizeImports<CR>", "Organize imports [TS]")
	end
	if client.name == "svelte" or client.name == "typescript-tools" then
		map("n", "<Leader>oo", "<Cmd>TSToolsAddMissingImports<CR>", "Organize imports [TS]")
	end

	if client.name == "gopls" then
		map("n", "<leader>l", require("go.format").goimport, "Go import [GOPLS]")
	end

	if client.server_capabilities.inlayHintProvider then
		pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
	end

	if client.name == "typescript-tools" and client.server_capabilities.hoverProvider == nil then
		client.server_capabilities.hoverProvider = true
	end
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
capabilities.textDocument.completion.completionItem.preselectSupport = true
capabilities.textDocument.completion.completionItem.insertReplaceSupport = true
capabilities.textDocument.completion.completionItem.resolveSupport = {
	properties = { "documentation", "detail", "additionalTextEdits" },
}

return {
	on_attach = on_attach,
	capabilities = capabilities,
}
