" Rationale

" - No support for vim, only neovim in mind
" - Keep it minimal: we need a good reason to change default behavior
" - Multiplatform: should work on POSIX systems
" - Lua: vimscript is only nice for vim compatibility (transition to lua is
"   not complete)

" map ,e :e <C-R>=expand("%:p:h") . "/" <CR>
" map ,t :tabe <C-R>=expand("%:p:h") . "/" <CR>
" map ,s :split <C-R>=expand("%:p:h") . "/" <CR>

lua <<EOF
-- Don't mess with 'tabstop', with 'expandtab' it isn't used.
-- Instead set softtabstop=-1, then 'shiftwidth' is used.
vim.o.expandtab = true
vim.o.shiftwidth = 2
vim.o.softtabstop = -1

-- set tabstop to 4 in php files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "php" },
    command = "setlocal ts=4 sts=4 sw=4",
})

vim.o.clipboard = "unnamedplus" -- Use the clipboard for all operations
vim.o.fillchars = "vert: ,stl: ,stlnc: "
vim.o.showmatch = true
vim.o.mat = 2
vim.o.mouse = ""
vim.o.nu = true
vim.o.showtabline = 2
vim.o.laststatus = 3
vim.o.inccommand = "split"
vim.o.undofile = true -- undo-persistence
vim.o.modeline = false -- can be a security issue
vim.o.smartindent = true
vim.o.list = true -- show unprintable characters
vim.o.fsync = true
vim.o.lazyredraw = true

vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
-- vim.o.foldmethod = "indent"
vim.opt.foldexpr = [[nvim_treesitter#foldexpr()]] -- take advantage of treesitter for foldexpr

-- hide line numbers in terminal windows
-- vim.api.nvim_exec([[
--    au BufEnter term://* setlocal nonumber
-- ]], false)

local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<C-l>", [[:tabnext<CR>]], keymap_opts)
vim.api.nvim_set_keymap("i", "<C-l>", [[<Esc>:tabnext<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n>:tabnext<CR>]], keymap_opts)
vim.api.nvim_set_keymap("n", "<C-h>", [[:tabprevious<CR>]], keymap_opts)
vim.api.nvim_set_keymap("i", "<C-h>", [[<Esc>:tabprevious<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n>:tabprevious<CR>]], keymap_opts)

EOF

" set shellslash
" set shell=/bin/bash
"https://www.reddit.com/r/neovim/comments/gbb2g3/wierd_vimplug_error_messages/.compact
"if has('win32')
"  set shell=powershell.exe
"endif

" Statusline
set statusline=
set statusline+=\ [%n%H%M%R%W]\     " flags and buf no
set statusline+=\ %f\               " path
set statusline+=%=                  " switch to right side
set statusline+=%y\                 " file type
set statusline+=[%l,%c]\ %p%%\      " line, column and percentage

" Retab the file (fix tab spaced files)
function! Retab()
  set noexpandtab
  retab!
  set expandtab
  retab!
endfunction

lua <<EOF

function Upgrade()
  local get_separator = function()
    if jit.os == "Windows" then
      return '\\'
    end
    return '/'
  end
  local join_paths = function(...)
    return table.concat({ ... }, get_separator())
  end
  local init_path = join_paths(vim.fn.stdpath 'config', 'init.vim')
  local init_url = 'https://raw.githubusercontent.com/nrobinaubertin/dotfiles/master/.config/nvim/init.vim'
  vim.cmd([[echom system('curl -Lso ]] .. init_path .. [[ ]] .. init_url .. [[')]])
  vim.cmd([[PlugUpgrade]])
end
function Update()
  vim.cmd([[PlugUpdate]])
  vim.cmd([[UpdateRemotePlugins]])
  vim.cmd([[TSUpdate]])
end
EOF

" Start in insert mode when opening a new terminal buffer
" Remember if we are in insert mode for each terminal buffer
autocmd TermOpen * startinsert
autocmd TermEnter * let b:insertMode = "yes"
autocmd BufEnter * if &buftype == 'terminal' && b:insertMode != "no" | startinsert | endif

" Use 'correct' php indentation for switch blocks
let g:PHP_vintage_case_default_indent = 1

" Vim-plug
call plug#begin(resolve(expand(stdpath('config') . '/plugged')))
Plug 'jose-elias-alvarez/null-ls.nvim'
Plug 'justinmk/vim-dirvish'
Plug 'lewis6991/gitsigns.nvim' " git
Plug 'neovim/nvim-lspconfig' " lsp
Plug 'nvim-lua/plenary.nvim' " telescope, gitsigns, null-ls
Plug 'nvim-lua/popup.nvim' " telescope
Plug 'nvim-telescope/telescope.nvim' " fuzzy finder
Plug 'nvim-treesitter/nvim-treesitter' " syntax highlighting
Plug 'sainnhe/gruvbox-material'  " colorscheme
Plug 'tpope/vim-fugitive' " git
call plug#end()

lua <<EOF

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
-- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
-- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
-- vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)
-- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

vim.diagnostic.config({
    underline = true,
    signs = true,
    virtual_text = true,
    float = {
        show_header = true,
        source = 'always', -- could be 'if_many'
        border = 'rounded',
        focusable = false,
    },
    update_in_insert = false, -- default to false
    severity_sort = false, -- default to false
})

---------
-- LSP --
---------

-- PYTHON
require("lspconfig").pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        flake8 = {
          enabled = true,
          -- pflake8 is used to read pyproject.toml
          executable = "pflake8",
        },
        jedi_definition = { enabled = true },
        jedi_reference = { enabled = true },
        mypy = {
          enabled = true,
          live_mode = false,
        },
        pylint = {
          enabled = true,
          args = {'--rcfile', 'pyproject.toml'},
        },
        pydocstyle = { enabled = true },
        -- disabled plugins
        autopep8 = { enabled = false },
        jedi_completion = { enabled = false },
        jedi = { enabled = false },
        jedi_hover = { enabled = false },
        jedi_signature_help = { enabled = false },
        jedi_symbols = { enabled = false },
        mccabe = { enabled = false },
        preload = { enabled = false },
        pycodestyle = { enabled = false },
        pyflakes = { enabled = false },
        rope_autoimport = { enabled = false },
        yapf = { enabled = false },
      },
    }
  }
}

local null_ls = require("null-ls")
local sources = {
    require("null-ls").builtins.code_actions.gitsigns,
    require("null-ls").builtins.diagnostics.shellcheck,
}
require("null-ls").setup({ sources = sources })

-- Colorscheme
vim.o.termguicolors = true -- doesn't work without it
vim.o.background = "light"
vim.g.gruvbox_material_enable_italic = 0
vim.g.gruvbox_material_enable_bold = 1
vim.g.gruvbox_material_disable_italic_comment = 1
vim.g.gruvbox_material_better_performance = 1
vim.g.gruvbox_material_background = "hard"
vim.g.gruvbox_material_foreground = "original"
vim.cmd([[colorscheme gruvbox-material]])

-- Treesitter highlighting
require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "dockerfile",
    "hcl",
    "html",
    "javascript",
    "json",
    "lua",
    "make",
    "php",
    "python",
    "rust",
    "scss",
    "toml",
    "vim",
    "yaml"
  }, highlight = { enable = true },
}

-- Telescope
-- https://news.ycombinator.com/item?id=27164343
local keymap_opts = { noremap = true, silent = true }

require('telescope').setup{
  vimgrep_arguments = {
    'rg',
    '--color=never',
    '--no-heading',
    '--with-filename',
    '--line-number',
    '--column',
    '--smart-case',
  },
}

vim.api.nvim_set_keymap("n", "<A-b>", [[:lua require('telescope.builtin').buffers()<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<A-b>", [[<C-\><C-n>:lua require('telescope.builtin').buffers()<CR>]], keymap_opts)
vim.api.nvim_set_keymap("n", "<A-g>", [[:lua require('telescope.builtin').live_grep()<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<A-g>", [[<C-\><C-n>:lua require('telescope.builtin').live_grep()<CR>]], keymap_opts)
vim.api.nvim_set_keymap("n", "<A-m>", [[:lua require('telescope.builtin').man_pages()<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<A-m>", [[<C-\><C-n>:lua require('telescope.builtin').man_pages()<CR>]], keymap_opts)
vim.api.nvim_set_keymap("n", "gd", [[:lua require('telescope.builtin').lsp_definitions()<CR>]], keymap_opts)
vim.api.nvim_set_keymap('n', "gr", [[:lua require('telescope.builtin').lsp_references()<CR>]], keymap_opts)

-- gitsigns
require('gitsigns').setup()
EOF

" Open todo file
" os.getenv("HOME")
command! Todo execute ':vsp ~/.TODO.md' <Bar> :set ft=markdown

" Open init.vim file
command! Init execute ":tabe `=stdpath('config').'/init.vim'`"

" Output 50 random alphanumeric characters (excluding look-alikes)
command! Rand execute ":read! tr -dc a-zA-Z0-9 < /dev/urandom | tr -d iIlLoO0 | head -c 50"

" cd to current open file
command! Relocate execute ":cd %:h"
