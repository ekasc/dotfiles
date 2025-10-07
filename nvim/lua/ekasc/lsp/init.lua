local servers = {
	"cssls",
	"yamlls",
	"astro",
	-- "pylsp",
	"bashls",
	"svelte",
	"gopls",
	"jsonls",
	-- "jdtls",
	-- "clangd",
	"texlab",
	"html",
	"sqlls",
	-- "rust_analyzer",
	-- "ts_ls",
	"tailwindcss",
	"lua_ls",
	"tombi",
	-- "intelephense",
	"phpactor",
}

for _, server in ipairs(servers) do
	if server == "ts_ls" then
		goto continue
	end
	local ok, config = pcall(require, "ekasc.lsp.servers." .. server)
	if ok then
		vim.lsp.config[server] = config
		vim.lsp.enable(server)
	else
		vim.notify("[lsp] failed to load config for: " .. server, vim.log.levels.WARN)
	end
	::continue::
end
