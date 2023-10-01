" Font
set guifont=Hack:h12

" Disable shortcut to suspend nvim
nnoremap <C-z> <Nop>

" Delete the word before the cursor
inoremap <C-BS> <C-W>

" Build
nnoremap <F7> :make<CR>

" Quickfix
nnoremap <F8> :cnext<CR>
nnoremap <S-F8> :cprevious<CR>

" Terminal
tnoremap <Esc> <C-\><C-n>

" Window navigation
tnoremap <A-h> <C-\><C-N><C-w>h
tnoremap <A-j> <C-\><C-N><C-w>j
tnoremap <A-k> <C-\><C-N><C-w>k
tnoremap <A-l> <C-\><C-N><C-w>l
inoremap <A-h> <C-\><C-N><C-w>h
inoremap <A-j> <C-\><C-N><C-w>j
inoremap <A-k> <C-\><C-N><C-w>k
inoremap <A-l> <C-\><C-N><C-w>l
nnoremap <A-h> <C-w>h
nnoremap <A-j> <C-w>j
nnoremap <A-k> <C-w>k
nnoremap <A-l> <C-w>l

" Disable swapfile
set noswapfile

" Highlight line of the cursor
set cursorline

" Line numbers
set number
set relativenumber
set signcolumn=number

" Indentation
set tabstop=4
set shiftwidth=4
set expandtab

" Show tabs and trailing blanks
set list

" Disable auto-continuation of comments
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Move vertically without skipping wrapped lines
nnoremap j gj
nnoremap k gk

" Keep cursor away from vertical edges
set scrolloff=6

" Resize splits when resizing vim
autocmd VimResized * wincmd =

" C/C++
let g:filetype_inc='c'
set cinoptions=l1,g0,E-s,t0,(0,W1s

" Ignored when completing file or directory names
set wildignore=*.o,*.obj,*.a,*.lib,*.dll,*.exe,*.pdb

" Using lualine to show mode
set noshowmode

"
" Misc
"

if exists("g:neovide")
    let g:neovide_remember_window_size=v:false
endif

if executable("rg")
    set grepprg=rg\ --vimgrep
endif

" Plugins
call plug#begin(stdpath('data') . '/plugged')
Plug 'jnurmine/Zenburn'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim' " Required for nvim-telescope
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build --prefix build' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'rluba/jai.vim'
call plug#end()

" Color scheme
colorscheme zenburn
hi VertSplit guifg=#303030 guibg=#303030 ctermfg=236 ctermbg=65

lua << LUAEOF

-- Options for keymaps
local opts = { noremap = true, silent = true }

--
-- Treesitter
--

-- Switch the default install method to curl
require 'nvim-treesitter.install'.prefer_git = false

require'nvim-treesitter.configs'.setup {
    -- A list of parser names, or "all" (the five first listed parsers should always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "cpp", "hlsl", "json", "python", "toml", "yaml" },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    highlight = {
        enable = true,

        -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
        -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
        -- Using this option may slow down your editor, and you may see some duplicate highlights.
        -- Instead of true it can also be a list of languages
        additional_vim_regex_highlighting = false,
    },

    -- Indentation based on treesitter for the = operator
    indent = {
        enable = true,
    },
}

--
-- LSP
--

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {}

-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, opts)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(ev)
        -- Enable completion triggered by <c-x><c-o>
        vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = ev.buf }
        vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
        vim.keymap.set({ 'i', 'n' }, '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<leader>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<leader>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<leader>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', '<leader>f', function()
            vim.lsp.buf.format { async = true }
        end, bufopts)

        -- clangd
        vim.keymap.set('n', 'go', vim.cmd.ClangdSwitchSourceHeader, bufopts)
    end,
})

--
-- Telescope
--

require('telescope').setup {
    defaults = {
        file_ignore_patterns = {
            "%.o",
            "%.obj",
            "%.a",
            "%.lib",
            "%.dll",
            "%.exe",
            "%.pdb",
            "%.sln",
            "%.vcxproj",
            "Session.vim",
        }
    }
}
require('telescope').load_extension('fzf')

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, opts)
vim.keymap.set('n', '<leader>fg', builtin.live_grep, opts)
vim.keymap.set('n', '<leader>fb', builtin.buffers, opts)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, opts)
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, opts)
vim.keymap.set('n', '<leader>fs', builtin.lsp_workspace_symbols, opts)
vim.keymap.set('n', '<leader>fS', builtin.lsp_dynamic_workspace_symbols, opts)
vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
vim.keymap.set('n', 'gD', builtin.lsp_type_definitions, opts)

--
-- lualine
--

require('lualine').setup {
    options = {
        theme = 'powerline'
    },
    tabline = {
        lualine_a = {'tabs'},
    }
}

LUAEOF

" Compilers
if filereadable('./first.jai') || filereadable('./build.jai')
    compiler! jai
elseif has('win32')
    if !empty(glob('*.sln')) || !empty(glob('*.vcxproj'))
        compiler! msbuild
    endif
endif
