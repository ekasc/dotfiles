-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'
    use 'tmsvg/pear-tree'
    use 'folke/tokyonight.nvim'
    use 'vim-airline/vim-airline'
    --use 'ms-jpq/coq_nvim'
    use 'ryanoasis/vim-devicons'
    use 'ms-jpq/chadtree'
    use {'neoclide/coc.nvim', branch = 'release'}
    use 'junegunn/fzf'
    use 'vim-airline/vim-airline-themes'
    use 'ray-x/go.nvim'
    use 'ray-x/guihua.lua' -- recommanded if need floating window support
    use { 'nvim-treesitter/nvim-treesitter', run = function() require('nvim-treesitter.install').update({ with_sync = true }) end }
    use 'neovim/nvim-lspconfig' -- Configurations for Nvim LSP
    use 'sbdchd/neoformat'
    use "nvim-lua/plenary.nvim"
    use { 'nvim-telescope/telescope.nvim', tag = '0.1.0', requires = { {'nvim-lua/plenary.nvim'} }}
    use 'meain/vim-jsontogo'
  end)
