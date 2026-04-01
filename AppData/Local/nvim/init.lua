--
-- Display
--

vim.o.guifont = 'Hack:h12'
vim.o.title = true
vim.o.titlestring = '%{getcwd()} - Nvim'
vim.o.cursorline = true
vim.o.colorcolumn = '129'
vim.o.number = true
vim.o.signcolumn = 'number'
vim.o.showmode = false
vim.o.list = true

--
-- Editing
--

vim.o.clipboard = 'unnamedplus'
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.expandtab = true
vim.o.scrolloff = 6
vim.o.swapfile = false

-- Delete the word before the cursor
vim.keymap.set('i', '<C-BS>', '<C-W>')

-- Disable auto-continuation of comments
vim.api.nvim_create_autocmd("BufEnter", {
    callback = function()
        vim.opt_local.formatoptions:remove({ "c", "r", "o" })
    end,
})

-- Move vertically without skipping wrapped lines
vim.keymap.set('n', 'j', function() return vim.v.count == 0 and 'gj' or 'j' end, { expr = true })
vim.keymap.set('n', 'k', function() return vim.v.count == 0 and 'gk' or 'k' end, { expr = true })

--
-- Navigation
--

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

-- Resize splits when resizing vim
vim.api.nvim_create_autocmd('VimResized', { command = 'wincmd =' })

--
-- Terminal
--

-- Go to normal mode in terminal
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Paste with C-V in terminal
vim.keymap.set('t', '<C-v>', function()
    vim.api.nvim_paste(vim.fn.getreg('+'), true, -1)
end)

--
-- Misc keymaps
--

vim.keymap.set('n', '<C-z>', '<Nop>')

--
-- C/C++
--

vim.g.filetype_inc = 'cpp'
vim.o.cinoptions = '=s,l1,g0,t0,(0,Ws'

--
-- Build system
--

vim.keymap.set('n', '<F7>', '<cmd>make<CR>')

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
        vim.system(
            { 'powershell', '-Command', [[$dte = [runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE'); (New-Object -ComObject WScript.Shell).AppActivate((Get-Process devenv)[0].Id); $dte.ExecuteCommand('Debug.Start')]] }
        )
    end)

    -- Go to current file
    vim.keymap.set('n', 'gX', function()
        local file = vim.fn.expand('%:p')
        local lnum = tostring(vim.fn.line('.'))
        vim.system(
            { 'powershell', '-Command',
                [[& { $dte = [runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE'); (New-Object -ComObject WScript.Shell).AppActivate((Get-Process devenv)[0].Id); $dte.ItemOperations.OpenFile($args[0]); $dte.ActiveDocument.Selection.GotoLine($args[1]) }]],
                file, lnum }
        )
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

--
-- Neovide
--

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
-- Treesitter
--

local ts_languages = {
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

require 'nvim-treesitter'.install(ts_languages)

-- Syntax highlighting
vim.api.nvim_create_autocmd('FileType', {
    pattern = ts_languages,
    callback = function()
        vim.treesitter.start()
    end,
})

--
-- LSP
--

vim.lsp.enable('clangd')
vim.lsp.enable('slangd')

vim.api.nvim_create_autocmd('LspAttach', {
    group = vim.api.nvim_create_augroup('UserLspConfig', {}),
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.name == 'clangd' then
            vim.keymap.set('n', 'go', vim.cmd.LspClangdSwitchSourceHeader, { buffer = args.buf })
        end
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

local custom_vimgrep_arguments = vim.list_extend({}, require("telescope.config").values.vimgrep_arguments)
if vim.fn.has('win32') == 1 then
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
    }
}

require('telescope').load_extension('fzf')

-- Wrap lines in previewer
vim.api.nvim_create_autocmd("User", {
    pattern = "TelescopePreviewerLoaded",
    callback = function()
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
