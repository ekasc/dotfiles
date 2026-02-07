-- Ensure nvim-jdtls is loaded before requiring.
local ok_lazy, lazy = pcall(require, "lazy")
if ok_lazy then
	pcall(lazy.load, { plugins = { "nvim-jdtls" } })
end

local ok, jdtls = pcall(require, "jdtls")
if not ok then
	vim.schedule(function()
		vim.notify("[java] nvim-jdtls not available (did it install/load?)", vim.log.levels.WARN)
	end)
	return
end

local uv = vim.uv or vim.loop
local utils = require("ekasc.lsp.utils")

local function load_spring_boot()
	local ok_lazy, lazy = pcall(require, "lazy")
	if ok_lazy then
		pcall(lazy.load, { plugins = { "spring-boot.nvim" } })
	end
	return pcall(require, "spring_boot")
end

local ok_boot, spring_boot = load_spring_boot()
if ok_boot then
	spring_boot.init_lsp_commands()
end

local function realpath(p)
	return uv.fs_realpath(p) or p
end

local function find_root(startpath)
	-- Intentionally ignore `.git` here.
	-- If you keep many projects under one parent repo, `.git` would cause jdtls to index everything.
	local markers = {
		"mvnw",
		"pom.xml",
		"gradlew",
		"build.gradle",
		"build.gradle.kts",
		"settings.gradle",
		"settings.gradle.kts",
	}

	local found = vim.fs.find(markers, { path = startpath, upward = true })[1]
	return found and vim.fs.dirname(found) or nil
end

-- Root policy:
-- - If Neovim is opened on a folder (e.g. `nvim .`), that folder is the project.
-- - If Neovim is opened on a file (e.g. `nvim path/to/Main.java`), that file's folder is the project.
-- - We only use Maven/Gradle markers to lift the root within that project folder.
local function initial_project_dir()
	-- If Neovim was started with a directory argument, use that.
	-- Otherwise fall back to the captured start cwd.
	local argc = vim.fn.argc()
	if argc >= 1 then
		local arg0 = vim.fn.argv(0)
		if arg0 and arg0 ~= "" then
			local stat = uv.fs_stat(arg0)
			if stat and stat.type == "directory" then
				return realpath(arg0)
			end
			if stat and stat.type == "file" then
				return realpath(vim.fs.dirname(arg0))
			end
		end
	end

	local start = vim.g.start_cwd
	if not start or start == "" then
		start = uv.cwd()
	end
	return realpath(start)
end

local proj_dir = initial_project_dir()

local bufname = vim.api.nvim_buf_get_name(0)
local buf_dir = bufname ~= "" and realpath(vim.fs.dirname(bufname)) or proj_dir

-- Root selection:
-- - Prefer Maven/Gradle root if found within the opened project dir.
-- - Otherwise, for marker-less projects, treat the file's directory as the root.
local candidate = find_root(buf_dir)
local root_dir
if candidate and vim.startswith(realpath(candidate), proj_dir) then
	root_dir = realpath(candidate)
else
	-- marker-less project: just treat this folder as the project
	root_dir = buf_dir
end

-- If jdtls is already running for this root in the current Neovim session,
-- just attach to it (avoid spawning extra Java processes).
local bufnr = vim.api.nvim_get_current_buf()
for _, client in ipairs(vim.lsp.get_clients({ name = "jdtls" })) do
	if client.config and client.config.root_dir == root_dir then
		vim.lsp.buf_attach_client(bufnr, client.id)
		return
	end
end

-- Make workspace unique per root (avoid collisions like multiple "backend" folders)
local real_root = uv.fs_realpath(root_dir) or root_dir
-- Make workspace stable per root (same root => same workspace on reopen)
local ws_id = vim.fn.sha256(real_root):sub(1, 12)
-- Use state (not cache) so workspaces survive restarts.
local workspace_dir = vim.fn.stdpath("state") .. "/jdtls/" .. ws_id

local bundles = {}
if ok_boot then
	vim.list_extend(bundles, spring_boot.java_extensions())
end

local function get_java_home()
	-- Use macOS java_home if available; it points at the active system runtime.
	local out = vim.fn.system({ "/usr/libexec/java_home" })
	if vim.v.shell_error == 0 then
		out = vim.trim(out)
		if out ~= "" and uv.fs_stat(out) then
			return out
		end
	end
	return nil
end

local java_home = get_java_home()

jdtls.start_or_attach({
	cmd = { vim.fn.exepath("jdtls"), "-data", workspace_dir, "--jvm-arg=-Dfile.encoding=UTF-8" },
	root_dir = root_dir,
	on_attach = utils.on_attach,
	capabilities = utils.capabilities,
	init_options = {
		bundles = bundles,
	},
	settings = java_home and {
		java = {
			home = java_home,
		},
	} or nil,
})

-- Keep one jdtls per root within a Neovim session.
-- (ftplugin can run multiple times; avoid spawning extra clients for the same root)
if vim.g.__jdtls_root == nil then
	vim.g.__jdtls_root = {}
end
vim.g.__jdtls_root[root_dir] = true

local function run_in_term(cmd)
	vim.cmd("botright split")
	vim.cmd("resize 15")
	vim.fn.termopen(cmd, { cwd = root_dir })
	vim.cmd("startinsert")
end

local function spring_boot_cmd()
	if uv.fs_stat(root_dir .. "/mvnw") then
		return { "./mvnw", "spring-boot:run" }
	end
	if uv.fs_stat(root_dir .. "/gradlew") then
		return { "./gradlew", "bootRun" }
	end
	-- Fallback: assume mvn/gradle are on PATH
	if uv.fs_stat(root_dir .. "/pom.xml") then
		return { "mvn", "spring-boot:run" }
	end
	if uv.fs_stat(root_dir .. "/build.gradle") or uv.fs_stat(root_dir .. "/build.gradle.kts") then
		return { "gradle", "bootRun" }
	end
	return nil
end

pcall(vim.api.nvim_del_user_command, "JavaRun")
vim.api.nvim_create_user_command("JavaRun", function()
	local cmd = spring_boot_cmd()
	if not cmd then
		vim.notify("[java] No Maven/Gradle wrapper found in project root", vim.log.levels.WARN)
		return
	end
	run_in_term(cmd)
end, {})

vim.keymap.set("n", "<leader>rr", "<cmd>JavaRun<cr>", { buffer = true, desc = "Run Spring Boot" })
