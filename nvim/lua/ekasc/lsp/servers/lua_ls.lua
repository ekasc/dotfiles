local utils = require("ekasc.lsp.utils")

local lua_rtp = vim.split(package.path, ";")
table.insert(lua_rtp, "lua/?.lua")
table.insert(lua_rtp, "lua/?/init.lua")

return {
	on_attach = utils.on_attach,
	capabilities = utils.capabilities,
	settings = {
		Lua = {
			runtime = { version = "LuaJIT", path = lua_rtp },
			diagnostics = { globals = { "vim" } },
			workspace = { checkThirdParty = false },
			telemetry = { enable = false },
		},
	},
}
