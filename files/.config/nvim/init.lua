require('util')
require('plugins')

-- Options
local opt = vim.opt
opt.termguicolors = true
opt.scrolloff = 8
opt.number = true
opt.relativenumber = true
opt.tabstop = 4
opt.softtabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.encoding = 'utf-8'

local g = vim.g
-- g.loaded_python3_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
g.loaded_ruby_provider = 0

g.netrw_browsex_viewer = 'wslview'

-- Mappings
g.mapleader = ' '
nmap('<leader><cr>', '<cmd>source ~/.config/nvim/init.lua<cr>')
nmap('<C-j>', '<cmd>cnext')
nmap('<C-k>', '<cmd>cprev')

vmap('J', ":m '>+1<cr>gv=gv")
vmap('K', ":m '<-2<cr>gv=gv")

local tb = require('telescope.builtin')
nmap('<leader>ff', function() tb.find_files(--[[{hidden=true}--]]) end)
nmap('<leader>fG', function() tb.git_files() end)
nmap('<leader>fg', function() tb.live_grep() end)
nmap('<leader>fb', function() tb.buffers() end)
nmap('<leader>fh', function() tb.help_tags() end)
