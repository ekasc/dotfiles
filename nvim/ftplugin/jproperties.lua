local ok_lazy, lazy = pcall(require, "lazy")
if ok_lazy then
	pcall(lazy.load, { plugins = { "spring-boot.nvim" } })
end

local ok, spring_boot = pcall(require, "spring_boot")
if not ok then
	return
end

spring_boot.init_lsp_commands()
