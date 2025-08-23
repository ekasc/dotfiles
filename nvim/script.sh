mkdir -p lua/ekasc/lsp/servers

# init.lua
cat > lua/ekasc/lsp/init.lua << 'EOF'
local servers = {
  "cssls",
  "yamlls",
  "astro",
  "pylsp",
  "bashls",
  "svelte",
  "gopls",
  "jsonls",
  "jdtls",
  "clangd",
  "texlab",
  "html",
  "sqlls",
  "rust_analyzer",
  "ts_ls",
  "tailwindcss",
  "lua_ls",
}

for _, server in ipairs(servers) do
  local ok, config = pcall(require, "ekasc.lsp.servers." .. server)
  if ok then
    vim.lsp.config[server] = config
    vim.lsp.enable(server)
  else
    vim.notify("[lsp] failed to load config for: " .. server, vim.log.levels.WARN)
  end
end
EOF

# Generic servers
for name in cssls yamlls astro pylsp bashls svelte jsonls jdtls clangd texlab html rust_analyzer; do
  cat > lua/ekasc/lsp/servers/${name}.lua << EOF
local utils = require("ekasc.lsp.utils")

return {
  on_attach = utils.on_attach,
  capabilities = utils.capabilities,
}
EOF
done

# sqlls
cat > lua/ekasc/lsp/servers/sqlls.lua << 'EOF'
local utils = require("ekasc.lsp.utils")

return {
  on_attach = utils.on_attach,
  capabilities = utils.capabilities,
  root_dir = function()
    return vim.loop.cwd()
  end,
}
EOF

# gopls
cat > lua/ekasc/lsp/servers/gopls.lua << 'EOF'
local utils = require("ekasc.lsp.utils")

return {
  cmd = { "gopls" },
  filetypes = { "go", "gomod" },
  root_dir = vim.fs.root(0, { "go.mod", ".git" }),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
        nilness = true,
        unusedwrite = true,
      },
      staticcheck = true,
    },
  },
  on_attach = utils.on_attach,
  capabilities = utils.capabilities,
}
EOF

# ts_ls
cat > lua/ekasc/lsp/servers/ts_ls.lua << 'EOF'
local utils = require("ekasc.lsp.utils")

local function organize_imports()
  local params = {
    command = "_typescript.organizeImports",
    arguments = { vim.api.nvim_buf_get_name(0) },
    title = "",
  }
  vim.lsp.buf.execute_command(params)
end

return {
  on_attach = utils.on_attach,
  capabilities = utils.capabilities,
  commands = {
    OrganizeImports = {
      organize_imports,
      description = "Organize Imports",
    },
  },
}
EOF

# tailwindcss
cat > lua/ekasc/lsp/servers/tailwindcss.lua << 'EOF'
local utils = require("ekasc.lsp.utils")
local tailwind_highlight = require("tailwind-highlight")

return {
  on_attach = function(client, bufnr)
    tailwind_highlight.setup(client, bufnr, {
      single_column = false,
      mode = "background",
      debounce = 200,
    })
    utils.on_attach(client, bufnr)
  end,
  capabilities = utils.capabilities,
  filetypes = {
    "javascriptreact",
    "typescriptreact",
    "php",
    "html",
    "svelte",
    "css",
  },
}
EOF

# lua_ls
cat > lua/ekasc/lsp/servers/lua_ls.lua << 'EOF'
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
EOF

echo "✅ All LSP server config files generated!"

