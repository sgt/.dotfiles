require('util')

-- auto bootstrap
local fn = vim.fn
local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'
if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path})
end

-- Autocommand that reloads neovim whenever you save the init.lua file
local packer_reload_group = vim.api.nvim_create_augroup("packer_reload", { clear = true })
vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = 'plugins.lua',
    command = 'source <afile> | PackerSync',
    group = packer_reload_group,
})

require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'

    use {
        'lewis6991/impatient.nvim',
        config = function()
            require('impatient')
        end,
    }

    use {
        'puremourning/vimspector',
        config = function()
            vim.g.vimspector_enable_mappings = 'VISUAL_STUDIO'
            vim.cmd [[packadd vimspector]]
        end,
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require'nvim-treesitter.configs'.setup {
                ensure_installed = {'lua', 'haskell', 'bash', 'clojure', 'css', 'erlang', 'dockerfile', 'gdscript', 'go', 'javascript', 'json', 'llvm', 'nix', 'norg', 'ocaml', 'python', 'regex', 'scheme', 'tsx', 'typescript', 'vim', 'yaml'},
                sync_install = false,
                highlight = {
                    enable = true,
                    additional_vim_regex_highlighting = false,
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "gnn",
                        node_incremental = "grn",
                        scope_incremental = "grc",
                        node_decremental = "grm",
                    },
                },
                indent = {
                    enable = false,
                },
            }
            -- vim.opt.foldmethod = 'expr'
            -- vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
        end,
    }

    use {
        'simrat39/rust-tools.nvim',
        requires = {'neovim/nvim-lspconfig'},
        config = function()
            require('rust-tools').setup({});
        end
    }

    -- use {
    --     "folke/trouble.nvim",
    --     requires = "kyazdani42/nvim-web-devicons",
    --     config = function()
    --         require("trouble").setup { }
    --     end
    -- }
    use {
        'williamboman/nvim-lsp-installer',
        requires = {
            'neovim/nvim-lspconfig' ,
            { 'ms-jpq/coq_nvim', branch= 'coq' },
            { 'ms-jpq/coq.artifacts', branch  = 'artifacts' },
            { 'ms-jpq/coq.thirdparty', branch = '3p' },
        },
        config = function()
            local servers = {
                'bashls', 'clangd', 'cmake', 'clojure_lsp', 'dockerls', 'eslint', 'elixirls',
                'erlangls', 'gopls', 'graphql', 'hls', 'html', 'jsonls',
                'marksman', 'pyright', 'sqls', 'sumneko_lua',
                'rust_analyzer', 'tsserver', 'volar', 'lemminx', 'yamlls'
            }

            require('nvim-lsp-installer').setup {
                ensure_installed = servers,
                ui = {
                    icons = {
                        server_installed = "✓",
                        server_pending = "➜",
                        server_uninstalled = "✗",
                    },
                },
            }

            local lsp = require "lspconfig"
            local coq = require "coq"

            -- Mappings.
            -- See `:help vim.diagnostic.*` for documentation on any of the below functions
            nmap('<space>e', vim.diagnostic.open_float)
            nmap('[d', vim.diagnostic.goto_prev)
            nmap(']d', vim.diagnostic.goto_next)
            nmap('<space>q', vim.diagnostic.setloclist)

            -- Use an on_attach function to only map the following keys
            -- after the language server attaches to the current buffer
            local on_attach = function(_, bufnr)
                -- Enable completion triggered by <c-x><c-o>
                vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

                -- Mappings.
                -- See `:help vim.lsp.*` for documentation on any of the below functions
                local bufopts = { noremap=true, silent=true, buffer=bufnr }
                vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
                vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
                vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
                vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
                vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
                vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
                vim.keymap.set('n', '<space>wl', function()
                    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
                end, bufopts)
                vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
                vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
                vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
                vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
                vim.keymap.set('n', '<space>f', vim.lsp.buf.formatting, bufopts)
            end

            for _, server in ipairs(servers) do
                local opts = { on_attach = on_attach }
                if server == 'sumneko_lua' then
                    opts['settings'] = {
                        Lua = {
                            diagnostics = {
                                globals = { 'vim' }
                            }
                        }
                    }
                end
                lsp[server].setup(coq.lsp_ensure_capabilities(opts))
            end

            lsp.hls.setup(coq.lsp_ensure_capabilities({ on_attach = on_attach }))   -- managed by ghcup

            vim.cmd[[COQnow -s]]

        end,
    }


    use {
        'nvim-telescope/telescope.nvim',
        requires = {
            'nvim-lua/plenary.nvim',
            {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
        },
        config = function()
            local t = require('telescope')
            t.load_extension('fzf')
            t.setup {
                defaults = {
                    file_ignore_patterns = {".git"}
                }
            }
        end
    }

    use {
        'mhinz/vim-startify',
        setup = function()
            vim.g.startify_fortune_use_unicode = 1
            vim.g.startify_session_persistence = 1
            vim.g.startify_change_to_vcs_root = 1
        end,
    }

    use {
        'machakann/vim-sandwich',
        'tpope/vim-fugitive',
        'tpope/vim-commentary',
        'stsewd/gx-extended.vim',
        -- 'catppuccin/nvim', -- a theme to try
        -- 'simrat39/symbols-outline.nvim',
        -- 'folke/which-key.nvim',
        -- 'christoomey/vim-tmux-navigator',
        -- 'wellle/tmux-complete.vim',
        -- 'numirias/semshi', -- python
        -- 'Jorengarenar/vim-MvVis' -- moving visual selection
    }

    -- Visuals --
    use 'kyazdani42/nvim-web-devicons'

    --[[
    use {
        'Shatur/neovim-ayu',
        config = function()
            vim.cmd 'colorscheme ayu-mirage'
        end,
    }
    -]]

    --[[
    use {
        'sonph/onehalf',
        rtp = '/vim',
        config = function()
            vim.cmd 'colorscheme onehalflight'
        end,
    }

    --[[
    use {
        'marko-cerovac/material.nvim',
        config = function()
            vim.g.material_style = 'palenight'
            vim.cmd 'colorscheme material'
        end
    }
    --]]

    use {
        'rafi/awesome-vim-colorschemes',
        config = function()
            vim.opt.background = 'light'
            vim.cmd [[colorscheme onehalflight]]
        end,
    }

    use {
        'nvim-lualine/lualine.nvim',
        requires = { 'kyazdani42/nvim-web-devicons', opt = true } ,
        config = function ()
            require('lualine').setup()
        end
    }

end)
