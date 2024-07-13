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
function RunToCursorInRaddbg()
    call system('raddbg --ipc find_code_location ' .. shellescape(expand('%:p') .. ':' .. line('.')))
    call system('raddbg --ipc run_to_cursor')
endfunction
nnoremap <C-F10> :call RunToCursorInRaddbg()<CR>

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

" Highlight column for max line length
set colorcolumn=129

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
set cinoptions==0,l1,g0,E-s,t0,(0,W1s

" Ignored when completing file or directory names
set wildignore=*.o,*.obj,*.a,*.lib,*.dll,*.exe,*.pdb

" Using lualine to show mode
set noshowmode

" Disable preview window for insert mode completion
set completeopt-=preview

" Disable vertical separator
set fillchars=vert:\ 

"
" Misc
"

if exists("g:neovide")
    let g:neovide_remember_window_size=v:false
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

" Compilers
if filereadable('./first.jai') || filereadable('./build.jai')
    compiler! jai
elseif has('win32')
    if filereadable('./build.bat')
        set makeprg=build.bat
    elseif !empty(glob('*.sln')) || !empty(glob('*.vcxproj'))
        compiler! msbuild
    endif
endif

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
        enable = false,
    },
}

--
-- LSP
--

-- Disable virtual text in diagnostics
vim.diagnostic.config({ virtual_text = false })

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.clangd.setup {}

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
        vim.keymap.set({ 'i', 'n' }, '<C-k>', vim.lsp.buf.signature_help, bufopts)
        vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
        vim.keymap.set('n', '<space>wl', function()
            print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
        end, bufopts)
        vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
        vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, bufopts)
        vim.keymap.set('n', '<space>f', function()
            vim.lsp.buf.format { async = true }
        end, bufopts)

        -- clangd
        vim.keymap.set('n', 'go', vim.cmd.ClangdSwitchSourceHeader, bufopts)
    end,
})

--
-- Telescope
--

local file_ignore_patterns_defaults = {
    "^build\\",
    "%.a",
    "%.dll",
    "%.exe",
    "%.lib",
    "%.o",
    "%.obj",
    "%.pdb",
    "%.png",
    "%.raddbg",
    "%.rdi",
    "%.sln",
    "%.ttf",
    "%.vcxproj",
    "Session.vim",
}

local file_ignore_patterns_third_party = {
    "^src\\third_party"
}

vim.list_extend(file_ignore_patterns_third_party, file_ignore_patterns_defaults)

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
        file_ignore_patterns = file_ignore_patterns_defaults,
        vimgrep_arguments = custom_vimgrep_arguments
    },
    pickers = {
        find_files = {
            file_ignore_patterns = file_ignore_patterns_third_party
        },
        grep_string = {
            file_ignore_patterns = file_ignore_patterns_third_party
        },
        live_grep = {
            file_ignore_patterns = file_ignore_patterns_third_party
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
vim.keymap.set('n', '<leader>ff', builtin.find_files, opts)
vim.keymap.set('n', '<leader>fg', builtin.live_grep, opts)
vim.keymap.set('n', '<leader>f*', builtin.grep_string, opts)
vim.keymap.set('n', '<leader>fb', builtin.buffers, opts)
vim.keymap.set('n', '<leader>fh', builtin.help_tags, opts)
vim.keymap.set('n', '<leader>fr', builtin.lsp_references, opts)
--vim.keymap.set('n', '<leader>fs', builtin.lsp_workspace_symbols, opts)
vim.keymap.set('n', '<leader>fs', function()
    vim.ui.input({ prompt = 'Find symbol: ' }, function(query)
        builtin.lsp_workspace_symbols({ query = query })
    end)
end, { desc = 'LSP workspace symbols' })
vim.keymap.set('n', '<leader>fS', builtin.lsp_dynamic_workspace_symbols, opts)
vim.keymap.set('n', 'gi', builtin.lsp_implementations, opts)
vim.keymap.set('n', 'gd', builtin.lsp_definitions, opts)
vim.keymap.set('n', 'gD', builtin.lsp_type_definitions, opts)
vim.keymap.set('n', '<leader>F', builtin.resume, opts)
vim.keymap.set('n', '<leader>f<tab>', builtin.pickers, opts)

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
