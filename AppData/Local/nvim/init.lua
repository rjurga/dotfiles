vim.o.colorcolumn  = '119'       -- Columns to highlight.
vim.o.cursorline   = true        -- Highlight the screen line of the cursor.
vim.o.guifont      = 'Hack:h13'  -- GUI: Names of fonts to be used.
vim.o.list         = true        -- Show <Tab> and <EOL>.
vim.o.number       = true        -- Print the line number in front of each line.
vim.o.scrolloff    = 6           -- Minimum number of lines above and below cursor.
vim.o.showmode     = false       -- Message on status line to show current mode.
vim.o.signcolumn   = 'number'    -- When and how to display the sign column.
vim.o.smoothscroll = true        -- Scroll by screen lines when 'wrap' is set.
vim.o.swapfile     = false       -- Whether to use a swapfile for a buffer.

--
-- Tabs
--

vim.o.expandtab  = true  -- Use spaces when <Tab> is inserted.
vim.o.shiftwidth = 4     -- Number of spaces to use for (auto)indent step.
vim.o.tabstop    = 4     -- Number of columns between two tab stops.

--
-- Title
--

vim.o.title       = true                  -- Let Vim set the title of the window.
vim.o.titlestring = '%{getcwd()} - Nvim'  -- String to use for the Vim window title.

--
-- Key mappings
--

-- Move cursor vertically by display lines when lines wrap.
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')

-- Delete the word before the cursor.
vim.keymap.set('i', '<C-BS>', '<C-W>')

-- Move cursor to other windows.
vim.keymap.set({'n', 'v', 'i', 't'}, '<A-h>', '<C-\\><C-N><C-W>h')
vim.keymap.set({'n', 'v', 'i', 't'}, '<A-j>', '<C-\\><C-N><C-W>j')
vim.keymap.set({'n', 'v', 'i', 't'}, '<A-k>', '<C-\\><C-N><C-W>k')
vim.keymap.set({'n', 'v', 'i', 't'}, '<A-l>', '<C-\\><C-N><C-W>l')

-- Disable suspending Nvim.
vim.keymap.set({'n', 'v'}, '<C-Z>', '<NOP>')

-- Build.
vim.keymap.set({'n', 'v', 'i'}, '<F7>', '<Cmd>make<CR>')

-- Return to normal mode from terminal.
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-N>')

-- Paste in terminal.
vim.keymap.set('t', '<C-R>', function()
    return '<C-\\><C-N>"' .. vim.fn.nr2char(vim.fn.getchar()) .. 'pi'
end, {expr = true})

--
-- Autocommands
--

-- Disable auto-continuation of comments.
vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        vim.opt_local.formatoptions:remove({'r', 'o'})
        -- In a future Nvim version, this will be replaced with something like
        -- vim.o.formatoptions = vim.dict_del_key(vim.o.formatoptions, 'c')
    end,
    group = vim.api.nvim_create_augroup('disable-comment-auto-continuation', {clear = true}),
})

-- When the Nvim window is resized, make all windows the same height and width.
vim.api.nvim_create_autocmd('VimResized', {
    command = 'wincmd =',
    group = vim.api.nvim_create_augroup('resize-windows', {clear = true}),
})

-- Highlight when yanking text.
-- @ToDo: In nvim 0.13, can do this to do both put and yank:
-- vim.api.nvim_create_autocmd({'TextPutPost', 'TextYankPost'}, {
--     callback = function()
--         vim.hl.hl_op {higroup='Visual', timeout=300}
--     end,
--     group = vim.api.nvim_create_augroup('highlight-put-yank', {clear = true}),
-- })
vim.api.nvim_create_autocmd('TextYankPost', {
    callback = function()
        vim.hl.on_yank()
    end,
    group = vim.api.nvim_create_augroup('highlight-yank', {clear = true}),
})

--
-- Neovide
--

if vim.g.neovide then
    vim.g.neovide_pixel_geometry = "RGBH"
    vim.g.neovide_remember_window_size = false
end

--
-- Filetype mappings
--

vim.filetype.add({
    extension = {
        hlsl = 'hlsl',
    },
})

--
-- C/C++
--

vim.g.filetype_inc = 'cpp'
vim.o.cinoptions = 'l1,g0,t0,(0,Ws'

--
-- Visual Studio
--

local function build_visual_studio_solution()
    local result = vim.system({'powershell', '-NoProfile', '-Command',
        [[[runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE').Solution.FullName]]
    }):wait()
    if result.code == 0 then
        local solution_file = vim.fn.trim(result.stdout)
        vim.cmd('make ' .. vim.fn.fnameescape(solution_file))
    else
        vim.notify('Visual Studio is not running', vim.log.levels.ERROR)
    end
end

local function run_in_visual_studio()
    vim.system({'powershell', '-NoProfile', '-Command',
        [[$dte = [runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE'); (New-Object -ComObject WScript.Shell).AppActivate((Get-Process devenv)[0].Id); $dte.ExecuteCommand('Debug.Start')]]
    })
end

local function open_current_location_in_visual_studio()
    local file = vim.fn.expand('%:p')
    local line_number = tostring(vim.fn.line('.'))
    vim.system({ 'powershell', '-NoProfile', '-Command',
        [[&{$dte = [runtime.interopservices.marshal]::getactiveobject('VisualStudio.DTE'); (New-Object -ComObject WScript.Shell).AppActivate((Get-Process devenv)[0].Id); $dte.ItemOperations.OpenFile($args[0]); $dte.ActiveDocument.Selection.GotoLine($args[1])}]],
        file, line_number
    })
end

local function configure_visual_studio()
    vim.cmd('compiler! msbuild')
    vim.keymap.set({'n', 'v', 'i'}, '<F7>', build_visual_studio_solution)
    vim.keymap.set('n', '<F5>', run_in_visual_studio)
    vim.keymap.set('n', 'gX', open_current_location_in_visual_studio)
end

--
-- RAD Debugger
--

local function run_in_raddbg()
    vim.system({'powershell', '-NoProfile', '-Command',
        [[(New-Object -ComObject WScript.Shell).AppActivate((Get-Process raddbg)[0].Id)]]
    }):wait()
    -- vim.system({'raddbg.exe', '--ipc', 'bring_to_front'}):wait()
    vim.system({'raddbg.exe', '--ipc', 'restart'})
end

local function open_current_location_in_raddbg()
    local location = vim.fn.expand('%:p') .. ':' .. vim.fn.line('.') .. ':' .. vim.fn.col('.')
    vim.system({'raddbg.exe', '--ipc', 'find_code_location', location})
    vim.system({'powershell', '-NoProfile', '-Command',
        [[(New-Object -ComObject WScript.Shell).AppActivate((Get-Process raddbg)[0].Id)]]
    })
    -- vim.system({'raddbg.exe', '--ipc', 'bring_to_front'})
end

local function configure_raddbg()
    vim.keymap.set('n', '<F5>', run_in_raddbg)
    vim.keymap.set('n', 'gX', open_current_location_in_raddbg)
end

--
-- Plugins
--

vim.api.nvim_create_autocmd('PackChanged', {
    callback = function(ev)
        local name, kind = ev.data.spec.name, ev.data.kind
        if name == 'nvim-treesitter' and kind == 'update' then
            if not ev.data.active then
                vim.cmd.packadd('nvim-treesitter')
            end
            vim.cmd('TSUpdate')
        end
    end,
    group = vim.api.nvim_create_augroup('pack-changed', {clear = true}),
})

vim.pack.add({
    'https://github.com/neovim/nvim-lspconfig',
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-context',
    'https://github.com/jnurmine/Zenburn',
    'https://github.com/nvim-tree/nvim-web-devicons',
    'https://github.com/nvim-lualine/lualine.nvim',
    'https://github.com/ibhagwan/fzf-lua',
    'https://github.com/rluba/jai.vim',
})

--
-- LSP
--

vim.lsp.config('*', {
    capabilities = {
        textDocument = {
            completion = {
                completionItem = {
                    snippetSupport = false
                }
            }
        }
    }
})
vim.lsp.enable({'clangd', 'slangd'})

-- Clangd: switch between source and header.
vim.api.nvim_create_autocmd('LspAttach', {
    callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client.name == 'clangd' then
            vim.keymap.set('n', 'go', vim.cmd.LspClangdSwitchSourceHeader, {buffer = ev.buf})
        end
    end,
    group = vim.api.nvim_create_augroup('clangd-switch-source-header', {clear = true}),
})

--
-- nvim-treesitter
--

require('nvim-treesitter').install {
    'cmake',
    'cpp',
    'hlsl',
    'python'
}

vim.api.nvim_create_autocmd('FileType', {
    callback = function()
        vim.treesitter.start()
    end,
    group = vim.api.nvim_create_augroup('treesitter-start', {clear = true}),
    pattern = {
        'c',
        'cpp',
        'hlsl',
        'lua',
        'markdown',
        'markdown_inline',
        'python',
        'query',
        'vim',
        'vimdoc',
    },
})

--
-- Zenburn
--

vim.cmd.colorscheme('zenburn')

--
-- lualine.nvim
--

require('lualine').setup {
    options = {
        theme = 'powerline',
    },
    sections = {
        lualine_c = {{'filename', path = 1}},
    },
    inactive_sections = {
        lualine_c = {{'filename', path = 1}},
    },
    tabline = {
        lualine_a = {'tabs'},
    },
}

--
-- fzf-lua
--

local fzf = require('fzf-lua')

local rg_opts = '--trim ' .. fzf.defaults.grep.rg_opts
if vim.fn.has('win32') == 1 then
    rg_opts = '--crlf ' .. rg_opts
end

fzf.setup {
    winopts = {
        height = 0.95,
        width = 0.95,
        row = 0.5,
        col = 0.5,
        preview = {
            wrap = true,
            horizontal = "right:50%",
        },
    },
    defaults = {
        git_icons = false,
        file_icons = false,
    },
    files = {
        cwd_prompt = false,
        fzf_opts = {
            ["--ansi"] = false,
        },
    },
    grep = {
        rg_opts = rg_opts,
    },
}

vim.keymap.set('n', '<Leader>ff', function() require("fzf-lua").files() end)
vim.keymap.set('n', '<Leader>fg', function() require("fzf-lua").live_grep() end)
vim.keymap.set('n', '<Leader>fh', function() require("fzf-lua").help_tags() end)
vim.keymap.set('n', '<Leader>f*', function() require("fzf-lua").grep_cword() end)
vim.keymap.set('v', '<Leader>f*', function() require("fzf-lua").grep_visual() end)
vim.keymap.set('n', 'gra',        function() require("fzf-lua").lsp_code_actions() end)
vim.keymap.set('n', 'gri',        function() require("fzf-lua").lsp_implementations({jump1 = true}) end)
vim.keymap.set('n', 'grr',        function() require("fzf-lua").lsp_references() end)
vim.keymap.set('n', 'grt',        function() require("fzf-lua").lsp_typedefs({jump1 = true}) end)
vim.keymap.set('n', 'gO',         function() require("fzf-lua").lsp_document_symbols() end)
vim.keymap.set('n', '<Leader>fs', function() require("fzf-lua").lsp_live_workspace_symbols() end)
vim.keymap.set('n', '<Leader>F',  function() require("fzf-lua").resume() end)

--
-- Compiler
--

if vim.fn.filereadable('./CMakeLists.txt') == 1 then
    vim.cmd('compiler! msvc')
    vim.opt.errorformat:prepend('%f(%l) : %t%*\\D%n: %m')  -- Fix for an errorformat parsing bug.
    vim.o.makeprg = 'cmake --build --preset $* -- --quiet'
    vim.keymap.set({'n', 'v', 'i'}, '<F7>', '<Cmd>make debug<CR>')
elseif vim.fn.filereadable('./first.jai') == 1 or vim.fn.filereadable('./build.jai') == 1 then
    vim.cmd('compiler! jai')
elseif vim.fn.has('win32') == 1 then
    configure_visual_studio()
end

if vim.fn.glob('*.raddbg_project') ~= '' or
    (vim.fn.fnamemodify(vim.fn.getcwd(), ':t') == 'src' and vim.fn.glob('../*.raddbg_project') ~= '') then
    configure_raddbg()
end
