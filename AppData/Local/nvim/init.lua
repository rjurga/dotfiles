-- Font
vim.o.guifont = 'Hack:h12'

-- Display current directory as window title
vim.o.title = true
vim.o.titlestring = '%{getcwd()} - Nvim'

-- Copy to the system clipboard
vim.o.clipboard = 'unnamedplus'

-- Disable shortcut to suspend nvim
vim.keymap.set('n', '<C-z>', '<Nop>')

-- Delete the word before the cursor
vim.keymap.set('i', '<C-BS>', '<C-W>')

-- Build
vim.keymap.set('n', '<F7>', '<cmd>make<CR>')

-- Go to normal mode in terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Window navigation
vim.keymap.set('t', '<A-h>', '<C-\\><C-N><C-w>h')
vim.keymap.set('t', '<A-j>', '<C-\\><C-N><C-w>j')
vim.keymap.set('t', '<A-k>', '<C-\\><C-N><C-w>k')
vim.keymap.set('t', '<A-l>', '<C-\\><C-N><C-w>l')
vim.keymap.set('i', '<A-h>', '<C-\\><C-N><C-w>h')
vim.keymap.set('i', '<A-j>', '<C-\\><C-N><C-w>j')
vim.keymap.set('i', '<A-k>', '<C-\\><C-N><C-w>k')
vim.keymap.set('i', '<A-l>', '<C-\\><C-N><C-w>l')
vim.keymap.set('n', '<A-h>', '<C-w>h')
vim.keymap.set('n', '<A-j>', '<C-w>j')
vim.keymap.set('n', '<A-k>', '<C-w>k')
vim.keymap.set('n', '<A-l>', '<C-w>l')

-- Disable swapfile
vim.o.swapfile = false

-- Highlight line of the cursor
vim.o.cursorline = true

-- Highlight column for max line length
vim.o.colorcolumn = '129'

-- Line numbers
vim.o.number = true
vim.o.signcolumn = 'number'

-- Indentation
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true

-- Show tabs and trailing blanks
vim.o.list = true

-- Disable auto-continuation of comments
vim.api.nvim_create_autocmd("FileType", {
    pattern = "*",
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Move vertically without skipping wrapped lines
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- Keep cursor away from vertical edges
vim.o.scrolloff = 6

-- Resize splits when resizing vim
vim.api.nvim_create_autocmd('VimResized', { command = 'wincmd =' })

-- C/C++
vim.g.filetype_inc = 'cpp'
vim.o.cinoptions = '=s,l1,g0,t0,(0,Ws'

-- Using lualine to show mode
vim.o.showmode = false

-- Neovide
if vim.g.neovide then
    vim.g.neovide_remember_window_size = false
end

--
-- Plugins
--

local hooks = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if kind == 'install' or kind == 'update' then
        if name == 'nvim-treesitter' then
            vim.cmd('TSUpdate')
        elseif name == 'telescope-fzf-native.nvim' then
            local opts = { cwd = ev.data.path }
            vim.system( { 'cmake', '-S.', '-Bbuild', '-DCMAKE_BUILD_TYPE=Release' }, opts):wait()
            vim.system( { 'cmake', '--build', 'build', '--config', 'Release', '--target', 'install' }, opts):wait()
        end
    end
end

vim.api.nvim_create_autocmd('PackChanged', { callback = hooks })

vim.pack.add({
    'https://github.com/jnurmine/Zenburn',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-telescope/telescope-fzf-native.nvim',
    'https://github.com/nvim-lualine/lualine.nvim',
    'https://github.com/rluba/jai.vim'
})

-- Color scheme
vim.cmd.colorscheme('zenburn')

--
-- Visual Studio
--

local function VisualStudioBuildSolution()
    local solution_file = vim.fn.trim(vim.fn.system(
        [[powershell -Command "try { [runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE').Solution.FullName } catch {}"]]
    ))
    if solution_file == '' then
        vim.api.nvim_echo({{'Visual Studio is not running', 'ErrorMsg'}}, true, {})
        return
    end
    vim.cmd('make ' .. vim.fn.fnameescape(solution_file))
end

local function ConfigureVisualStudio()
    -- Build solution
    vim.cmd('compiler! msbuild')
    vim.keymap.set('n', '<F7>', VisualStudioBuildSolution)

    -- Start
    vim.keymap.set('n', '<F5>', function()
        vim.fn.system(
            [[powershell -Command "$dte = [runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE'); (New-Object -ComObject WScript.Shell).AppActivate((Get-Process devenv)[0].Id); $dte.ExecuteCommand('Debug.Start')"]]
        )
    end)

    -- Go to current file
    vim.keymap.set('n', 'gX', function()
        local file = vim.fn.expand('%:p')
        local lnum = vim.fn.line('.')
        vim.fn.system(string.format(
            [[powershell -Command "$dte = [runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE'); (New-Object -ComObject WScript.Shell).AppActivate((Get-Process devenv)[0].Id); $dte.ItemOperations.OpenFile('%s'); $dte.ActiveDocument.Selection.GotoLine(%d);"]],
            file, lnum
        ))
    end)
end

if vim.fn.filereadable('./first.jai') == 1 or vim.fn.filereadable('./build.jai') == 1 then
    vim.cmd('compiler! jai')
elseif vim.fn.has('win32') == 1 then
    if vim.fn.filereadable('./build.bat') == 1 then
        vim.o.makeprg = 'build.bat'
    else
        ConfigureVisualStudio()
    end
end

-- Paste with C-V in terminal
vim.keymap.set('t', '<C-v>', function()
    vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
end)

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

-- Syntax highlighting
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
        vim.treesitter.start()
    end,
})

--
-- LSP
--

-- Setup language servers.
vim.lsp.enable('clangd')
vim.lsp.enable('slangd')

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
        -- Buffer local mappings.
        -- See `:help vim.lsp.*` for documentation on any of the below functions
        local bufopts = { buffer = args.buf }

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
    "%.slnx",
    "%.svg",
    "%.ttf",
    "%.vcxproj",
    "Session.vim",
    "third_party[/\\]",
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
vim.keymap.set('n', 'gri', builtin.lsp_implementations)
vim.keymap.set('n', 'grr', builtin.lsp_references)
vim.keymap.set('n', 'grt', builtin.lsp_type_definitions)
vim.keymap.set('n', 'gO', builtin.lsp_document_symbols)
vim.keymap.set('n', '<leader>ff', builtin.find_files)
vim.keymap.set('n', '<leader>fg', builtin.live_grep)
vim.keymap.set('n', '<leader>f*', builtin.grep_string)
vim.keymap.set('n', '<leader>fh', builtin.help_tags)
vim.keymap.set('n', '<leader>fs', builtin.lsp_dynamic_workspace_symbols)
vim.keymap.set('n', '<leader>F', builtin.resume)
vim.keymap.set('n', '<leader>f<tab>', builtin.pickers)

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
