" Font
set guifont=Hack:h12

" Display current directory as window title
set title
set titlestring=%{getcwd()}\ -\ NVIM

" Disable shortcut to suspend nvim
nnoremap <C-z> <Nop>

" Delete the word before the cursor
inoremap <C-BS> <C-W>

" Build
nnoremap <F7> :make<CR>

" Run
nnoremap <F5> :call system('raddbg --ipc run')<CR>

" Run to cursor
nnoremap <C-F10> :call system('raddbg --ipc run_to_line ' .. shellescape(expand('%:p') .. ':' .. line('.')))<CR>

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

" Highlight column for max line length
set colorcolumn=129

" Line numbers
set number
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
set cinoptions==0,l1,g0,E-s,t0,(0,W1s

" Ignored when completing file or directory names
set wildignore=*.o,*.obj,*.a,*.lib,*.dll,*.exe,*.pdb

" Using lualine to show mode
set noshowmode

" Disable preview window for insert mode completion
set completeopt-=preview

"
" Misc
"

if exists("g:neovide")
    let g:neovide_remember_window_size=v:false
endif

" Plugins
call plug#begin(stdpath('data') . '/plugged')
Plug 'jnurmine/Zenburn'
Plug 'nvim-treesitter/nvim-treesitter', { 'do': ':TSUpdate' }
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lua/plenary.nvim'  " Required for nvim-telescope
Plug 'nvim-telescope/telescope.nvim', { 'branch': 'master' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install' }
Plug 'nvim-lualine/lualine.nvim'
Plug 'rluba/jai.vim'

Plug 'nvim-treesitter/nvim-treesitter-textobjects', { 'branch': 'main' }
let g:no_plugin_maps = 1  " Disable entire built-in ftplugin mappings to avoid conflicts with nvim-treesitter-textobjects

Plug 'nvim-treesitter/nvim-treesitter-context', { 'branch': 'master' }

call plug#end()

" Color scheme
colorscheme zenburn

" Compilers
if filereadable('./first.jai') || filereadable('./build.jai')
    compiler! jai
elseif has('win32')
    if filereadable('./build.bat')
        set makeprg=build.bat
    elseif !empty(glob('../*.slnx')) && !empty(glob('*.vcxproj'))
        compiler! msbuild
        let s:solution_file = glob('../*.slnx')
        execute "nnoremap <F7> :make " .. fnameescape(s:solution_file) .. "<CR>"
    elseif !empty(glob('*.slnx')) || !empty(glob('*.sln')) || !empty(glob('*.vcxproj'))
        compiler! msbuild
    endif
endif

lua << LUAEOF

-- Options for keymaps
local opts = { noremap = true, silent = true }

--
-- Treesitter
--

require 'nvim-treesitter'.install {
    "c",
    "cmake",
    "cpp",
    "hlsl",
    "json",
    "lua",
    "python",
    "query",
    "toml",
    "vim",
    "vimdoc",
    "yaml",
}

vim.api.nvim_create_autocmd('FileType', {
    pattern = {
    "c",
    "cmake",
    "cpp",
    "hlsl",
    "json",
    "lua",
    "python",
    "query",
    "toml",
    "vim",
    "vimdoc",
    "yaml",
    },
    callback = function()
        -- syntax highlighting, provided by Neovim
        vim.treesitter.start()
    end,
})

--
-- Tresitter-textobjects
--

-- configuration
require('nvim-treesitter-textobjects').setup {
    select = {
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        -- You can choose the select mode (default is charwise 'v')
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * method: eg 'v' or 'o'
        -- and should return the mode ('v', 'V', or '<c-v>') or a table
        -- mapping query_strings to modes.
        selection_modes = {
            ['@parameter.outer'] = 'v', -- charwise
            ['@function.outer'] = 'V', -- linewise
            -- ['@class.outer'] = '<c-v>', -- blockwise
        },
        -- If you set this to `true` (default is `false`) then any textobject is
        -- extended to include preceding or succeeding whitespace. Succeeding
        -- whitespace has priority in order to act similarly to eg the built-in
        -- `ap`.
        --
        -- Can also be a function which gets passed a table with the keys
        -- * query_string: eg '@function.inner'
        -- * selection_mode: eg 'v'
        -- and should return true of false
        include_surrounding_whitespace = false,
    },
    move = {
        -- whether to set jumps in the jumplist
        set_jumps = true,
    },
}

vim.keymap.set({ 'x', 'o' }, 'am', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'im', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject('@function.inner', 'textobjects')
end)

vim.keymap.set({ 'x', 'o' }, 'ac', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'x', 'o' }, 'ic', function()
    require 'nvim-treesitter-textobjects.select'.select_textobject('@class.inner', 'textobjects')
end)

vim.keymap.set({ 'n', 'x', 'o' }, ']m', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[m', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@function.outer', 'textobjects')
end)

vim.keymap.set({ 'n', 'x', 'o' }, ']M', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@function.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[M', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@function.outer', 'textobjects')
end)

vim.keymap.set({ 'n', 'x', 'o' }, ']c', function()
    require('nvim-treesitter-textobjects.move').goto_next_start('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[c', function()
    require('nvim-treesitter-textobjects.move').goto_previous_start('@class.outer', 'textobjects')
end)

vim.keymap.set({ 'n', 'x', 'o' }, ']C', function()
    require('nvim-treesitter-textobjects.move').goto_next_end('@class.outer', 'textobjects')
end)
vim.keymap.set({ 'n', 'x', 'o' }, '[C', function()
    require('nvim-treesitter-textobjects.move').goto_previous_end('@class.outer', 'textobjects')
end)

-- Repeat movement with ; and ,
local ts_repeat_move = require "nvim-treesitter-textobjects.repeatable_move"

vim.keymap.set({ 'n', 'x', 'o' }, ';', ts_repeat_move.repeat_last_move)
vim.keymap.set({ 'n', 'x', 'o' }, ',', ts_repeat_move.repeat_last_move_opposite)

-- Make builtin f, F, t, T also repeatable with ; and ,
vim.keymap.set({ 'n', 'x', 'o' }, 'f', ts_repeat_move.builtin_f_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'F', ts_repeat_move.builtin_F_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 't', ts_repeat_move.builtin_t_expr, { expr = true })
vim.keymap.set({ 'n', 'x', 'o' }, 'T', ts_repeat_move.builtin_T_expr, { expr = true })

--
-- LSP
--

-- Setup language servers.
local lspconfig = require('lspconfig')
vim.lsp.enable('clangd')
vim.lsp.enable('slangd')

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { noremap = true, silent = true, buffer = args.buf }

        -- clangd
        vim.keymap.set('n', 'go', vim.cmd.LspClangdSwitchSourceHeader, bufopts)
    end,
})

--
-- Telescope
--

local file_ignore_patterns = {
    "%.a",
    "%.dll",
    "%.exe",
    "%.lib",
    "%.o",
    "%.obj",
    "%.pdb",
    "%.png",
    "%.props",
    "%.raddbg",
    "%.rdi",
    "%.sln",
    "%.svg",
    "%.ttf",
    "%.vcxproj",
    "Session.vim",
}

-- If on Windows, add crlf flag to ripgrep
local custom_vimgrep_arguments = { unpack(require("telescope.config").values.vimgrep_arguments) }
if vim.fn.has('win32') then
    table.insert(custom_vimgrep_arguments, "--crlf")
end

require('telescope').setup {
    defaults = {
        cache_picker = {
            num_pickers = 64,
            limit_entries = 8192
        },
        file_ignore_patterns = file_ignore_patterns,
        vimgrep_arguments = custom_vimgrep_arguments
    },
    pickers = {
        find_files = {
            file_ignore_patterns = file_ignore_patterns
        },
        grep_string = {
            file_ignore_patterns = file_ignore_patterns
        },
        live_grep = {
            file_ignore_patterns = file_ignore_patterns
        }
    }
}
require('telescope').load_extension('fzf')

-- Wrap lines in previewer
vim.api.nvim_create_autocmd("User", {
    pattern = "TelescopePreviewerLoaded",
    callback = function(args)
        vim.wo.wrap = true
    end,
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', 'grr', builtin.lsp_references, opts)
vim.keymap.set('n', 'gri', builtin.lsp_implementations, opts)
vim.keymap.set('n', '<leader>ff', builtin.find_files, opts)
vim.keymap.set('n', '<leader>fg', builtin.live_grep, opts)
vim.keymap.set('n', '<leader>f*', builtin.grep_string, opts)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, opts)
vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols, opts)
vim.keymap.set('n', '<leader>F', builtin.resume, opts)
vim.keymap.set('n', '<leader>f<tab>', builtin.pickers, opts)

--
-- lualine
--

require('lualine').setup {
    options = {
        theme = 'powerline'
    },
    sections = {
        lualine_c = {
            {
                'filename',
                path = 1
            }
        }
    },
    inactive_sections = {
        lualine_c = {
            {
                'filename',
                path = 1
            }
        }
    },
    tabline = {
        lualine_a = {'tabs'},
    }
}

LUAEOF
