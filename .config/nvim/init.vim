" Rationale

" - No support for vim, only neovim in mind
" - Keep it minimal: we need a good reason to change default behavior
" - Multiplatform: should work on POSIX systems
" - Lua: vimscript is only nice for vim compatibility (transition to lua is not complete)

lua <<EOF
-- Don't mess with 'tabstop', with 'expandtab' it isn't used.
-- Instead set softtabstop=-1, then 'shiftwidth' is used.
vim.o.tabstop = 2
vim.o.softtabstop = -1
vim.o.shiftwidth = 2
vim.o.expandtab = true  -- Use spaces instead of tabs
vim.o.softtabstop = 2

-- set tabstop to 4 in php files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "php" },
    command = "setlocal ts=4 sts=4 sw=4 et",
})

-- set tabstop to 4 in go files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "go" },
    command = "setlocal ts=2 sts=2 sw=2 noet",
})

-- Use 'correct' php indentation for switch blocks
vim.g.PHP_vintage_case_default_indent = 1

vim.g.editorconfig = false
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
vim.o.fsync = true -- default since https://github.com/neovim/neovim/releases/tag/v0.9.5
vim.o.lazyredraw = true

vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
-- vim.o.foldmethod = "indent"
vim.opt.foldexpr = [[nvim_treesitter#foldexpr()]] -- take advantage of treesitter for foldexpr

local keymap_opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap("n", "<C-l>", [[:tabnext<CR>]], keymap_opts)
vim.api.nvim_set_keymap("i", "<C-l>", [[<Esc>:tabnext<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<C-l>", [[<C-\><C-n>:tabnext<CR>]], keymap_opts)
vim.api.nvim_set_keymap("n", "<C-h>", [[:tabprevious<CR>]], keymap_opts)
vim.api.nvim_set_keymap("i", "<C-h>", [[<Esc>:tabprevious<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<C-h>", [[<C-\><C-n>:tabprevious<CR>]], keymap_opts)
vim.api.nvim_set_keymap("n", "<C-k>", [[:tabmove +1<CR>]], keymap_opts)
vim.api.nvim_set_keymap("i", "<C-k>", [[<Esc>:tabmove +1<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<C-k>", [[<C-\><C-n>:tabmove +1<CR>]], keymap_opts)
vim.api.nvim_set_keymap("n", "<C-j>", [[:tabmove -1<CR>]], keymap_opts)
vim.api.nvim_set_keymap("i", "<C-j>", [[<Esc>:tabmove -1<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<C-j>", [[<C-\><C-n>:tabmove -1<CR>]], keymap_opts)

EOF

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

lua <<EOF

-- vim-plug
local vim = vim
local Plug = vim.fn['plug#']

vim.call('plug#begin')
Plug('https://github.com/justinmk/vim-dirvish', { ['tag'] = 'v1.0' })
Plug('https://github.com/lewis6991/gitsigns.nvim', { ['tag'] = 'v0.9.0' }) -- git
Plug('https://github.com/neovim/nvim-lspconfig', { ['tag'] = 'v0.1.8' }) -- lsp
Plug('https://github.com/nvim-lua/plenary.nvim', { ['branch'] = 'v0.1.4' }) -- [telescope, gitsigns]
Plug('https://github.com/nvim-telescope/telescope.nvim', { ['tag'] = 'v0.1.8' }) -- fuzzy finder
Plug('https://github.com/nvim-treesitter/nvim-treesitter', { ['tag'] = 'v0.9.2' }) -- syntax highlighting
Plug('https://github.com/sainnhe/gruvbox-material', { ['tag'] = 'v1.2.5' })  -- colorscheme
Plug('https://github.com/tpope/vim-fugitive', { ['tag'] = 'v3.7' }) -- git
vim.call('plug#end')

-- GOLANG
vim.cmd [[autocmd BufWritePost *.go :silent! exec '!go fmt %:p' | edit!]]
require('lspconfig').gopls.setup{}

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
-- Parser issues: https://github.com/nvim-treesitter/nvim-treesitter/issues/3092
require("nvim-treesitter.configs").setup {
  ensure_installed = {
    "bash",
    "c",
    "cpp",
    "css",
    "dockerfile",
    "go",
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
vim.api.nvim_set_keymap("n", "<A-f>", [[:lua require('telescope.builtin').git_files()<CR>]], keymap_opts)
vim.api.nvim_set_keymap("t", "<A-f>", [[<C-\><C-n>:lua require('telescope.builtin').git_files()<CR>]], keymap_opts)
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

lua <<EOF

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
-- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)

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
-- vim.lsp.set_log_level("debug")

-- only used for mypy
require("lspconfig").pylsp.setup{
  settings = {
    pylsp = {
      plugins = {
        mypy = {
          enabled = true,
          live_mode = false,
        },
        -- disabled plugins
        jedi_definition = { enabled = false },
        jedi_reference = { enabled = false },
        autopep8 = { enabled = false },
        flake8 = { enabled = false },
        jedi_completion = { enabled = false },
        jedi = { enabled = false },
        jedi_hover = { enabled = false },
        jedi_signature_help = { enabled = false },
        jedi_symbols = { enabled = false },
        mccabe = { enabled = false },
        preload = { enabled = false },
        pycodestyle = { enabled = false },
        pydocstyle = { enabled = false },
        pyflakes = { enabled = false },
        pylint = { enabled = false },
        rope_autoimport = { enabled = false },
        ruff = { enabled = false },
        yapf = { enabled = false },
      },
    }
  }
}

-- Creates a jedi env dir to be used to install python packages to
local function create_jedi_env()
  local home_dir = vim.fn.expand('~')
  local consolidated_env_path = home_dir .. "/.local/share/nvim/jedi/env"
  if vim.fn.isdirectory(consolidated_env_path) == 0 then
      print("Creating consolidated environment at " .. consolidated_env_path)
      vim.fn.system("python3 -m venv " .. consolidated_env_path)
      if vim.v.shell_error ~= 0 then
          print("Error creating the consolidated environment.")
          return
      end
  end
end

-- Fn used to install dependencies from the current env to an env used to query definitions
local function UpdateJediEnvironment()
    local home_dir = vim.fn.expand('~')
    local consolidated_env_path = home_dir .. "/.local/share/nvim/jedi/env"
    local tox_dir = vim.fn.getcwd() .. '/.tox'

    if vim.fn.isdirectory(tox_dir) == 0 then
        print("No .tox directory found.")
        return
    end

    create_jedi_env()

    local envs = vim.fn.readdir(tox_dir)
    for _, env in ipairs(envs) do
        local env_path = tox_dir .. '/' .. env
        if vim.fn.isdirectory(env_path) == 1 then
            -- Skip directories starting with a dot
            if string.sub(env, 1, 1) == "." then
                goto continue
            end
            local pip_freeze_cmd = "pip freeze --path " .. env_path .. '/lib/python3.10/site-packages/'
            local packages = vim.fn.system(pip_freeze_cmd)
            packages = packages:gsub("\n", " ")

            if vim.v.shell_error == 0 then
                local install_cmd = consolidated_env_path .. "/bin/pip install " .. packages
                vim.fn.system(install_cmd)
                if vim.v.shell_error ~= 0 then
                    print("Error installing packages from [" .. install_cmd .. "]: " .. env)
                end
            else
                print("Error extracting packages from: " .. env)
            end
        end
        ::continue::
    end

    print("Aggregation complete.")
end
vim.api.nvim_create_user_command('UpdateJediEnv', UpdateJediEnvironment, {})

require('lspconfig').jedi_language_server.setup{
  init_options = {
    workspace = {
      environmentPath = vim.fn.expand('~') .. "/.local/share/nvim/jedi/env/bin/python"
    }
  }
}

-- Configure `ruff-lsp`.
-- See: https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#ruff_lsp
-- For the default config, along with instructions on how to customize the settings
require('lspconfig').ruff_lsp.setup {
  on_attach = on_attach,
  init_options = {
    settings = {
      -- Any extra CLI arguments for `ruff` go here.
      args = {},
    }
  }
}

-- https://github.com/hashicorp/terraform-ls/blob/main/docs/USAGE.md#neovim-v080
require'lspconfig'.terraformls.setup{}
vim.api.nvim_create_autocmd({"BufWritePre"}, {
  pattern = {"*.tf", "*.tfvars"},
  callback = function()
    vim.lsp.buf.format()
  end,
})

-- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#tflint
require'lspconfig'.tflint.setup{}

vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)

EOF
