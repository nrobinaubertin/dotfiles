-- Don't mess with 'tabstop', with 'expandtab' it isn't used.
-- Instead set softtabstop=-1, then 'shiftwidth' is used.
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.expandtab = true  -- Use spaces instead of tabs
vim.o.softtabstop = 2

-- set tabstop to 4 in php files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "php" },
    command = "setlocal ts=4 sts=4 sw=4 et",
})

-- set tabstop to 2 in go files
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
vim.o.matchtime = 2
vim.o.nu = true
vim.o.showtabline = 2
vim.o.laststatus = 3
vim.o.inccommand = "split"
vim.o.undofile = true -- undo-persistence
vim.o.modeline = false -- can be a security issue
vim.o.smartindent = true
vim.o.list = true -- show unprintable characters
vim.o.lazyredraw = true
vim.o.mouse = ""

vim.opt.foldlevel = 99
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = [[nvim_treesitter#foldexpr()]] -- take advantage of treesitter for foldexpr

local keymap_opts = { noremap = true, silent = true }

-- Tab keymaps
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

-- Statusline
vim.o.statusline = "[%n%H%M%R%W]" -- flags and buf no
vim.o.statusline = vim.o.statusline .. " %f" -- path
vim.o.statusline = vim.o.statusline .. "%=" -- switch to right side
vim.o.statusline = vim.o.statusline .. " %y" -- file type
vim.o.statusline = vim.o.statusline .. " [%l,%c] %p%%" -- line, column and percentage

-- Retab the file (fix tab spaced files)
local function retab()
  vim.o.expandtab = false
  vim.cmd("retab!")
  vim.o.expandtab = true
  vim.cmd("retab!")
end

function Update()
  vim.cmd([[PlugUpdate]])
  vim.cmd([[UpdateRemotePlugins]])
  vim.cmd([[TSUpdate]])
end

-- Start in insert mode when opening a new terminal buffer
-- Remember if we are in insert mode for each terminal buffer
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "startinsert"
})

vim.api.nvim_create_autocmd("TermEnter", {
  pattern = "*",
  callback = function()
    vim.b.insertMode = "yes"
  end
})

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    if vim.bo.buftype == 'terminal' and (vim.b.insertMode or "yes") ~= "no" then
      vim.cmd("startinsert")
    end
  end
})

-- Plugins
vim.call('plug#begin')
vim.fn['plug#']('https://github.com/stevearc/oil.nvim', { ['tag'] = 'v2.15.0' }) -- navigate
vim.fn['plug#']('https://github.com/lewis6991/gitsigns.nvim', { ['tag'] = 'v1.0.2' }) -- git
vim.fn['plug#']('https://github.com/mason-org/mason.nvim', { ['tag'] = 'v1.11.0' }) -- easy install of tools
vim.fn['plug#']('https://github.com/nvim-lua/plenary.nvim', { ['tag'] = 'v0.1.4' }) -- [telescope, gitsigns]
vim.fn['plug#']('https://github.com/nvim-telescope/telescope.nvim', { ['tag'] = '0.1.8' }) -- fuzzy finder
vim.fn['plug#']('https://github.com/nvim-treesitter/nvim-treesitter', { ['tag'] = 'v0.9.3' }) -- syntax highlighting
vim.fn['plug#']('https://github.com/ellisonleao/gruvbox.nvim', { ['tag'] = '2.0.0' })  -- colorscheme
vim.fn['plug#']('https://github.com/tpope/vim-fugitive', { ['tag'] = 'v3.7' }) -- git
vim.fn['plug#']('https://github.com/dense-analysis/ale') -- static analysis
vim.call('plug#end')

-- nvim LSP
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

vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, keymap_opts)
vim.keymap.set("n", "]g", vim.diagnostic.goto_next)
vim.keymap.set("n", "[g", vim.diagnostic.goto_prev)

require('mason').setup()

-- Colorscheme
-- https://gist.github.com/andersevenrud/015e61af2fd264371032763d4ed965b6
vim.o.background = "dark"
require("gruvbox").setup({
  italic = {
    strings = false,
    emphasis = false,
    comments = true,
    operators = false,
    folds = false,
  },
  palette_overrides = {light0 = "#ffffff"},
})
vim.cmd("colorscheme gruvbox")

-- Treesitter
require("nvim-treesitter.configs").setup {
  -- We don't install everything because of parser issues:
  -- https://github.com/nvim-treesitter/nvim-treesitter/issues/3092
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
    "terraform",
    "toml",
    "vim",
    "vimdoc",  -- Required for Vim help files
    "yaml"
  },
  -- Indentation doesn't work well for python
  -- You have to disable highlighting as well for it
  -- as they are tied together
  highlight = {
    enable = true,
    disable = { "python" },
  },
  indent = {
    enable = true,
    disable = { "python" },
  },
}

-- Telescope
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

-- Mason (manually installed through it)
-- gofumpt
-- golangci-lint
-- gopls
-- mypy
-- python-lsp-server
-- jedi-language-server
-- ruff
-- tflint

-- Ale
-- Only use linters with Ale, LSPs are handled manually
vim.g.ale_use_neovim_diagnostics_api = 1 -- make ALE display errors and warnings via the Neovim diagnostics API
vim.g.ale_linters_explicit = 1 -- Only run linters named in ale_linters settings.
vim.g.ale_linters = {
  go = { 'gofumpt', 'golangci-lint' },
  sh = { 'shellcheck' },
  python = { 'mypy', 'ruff' },
}

-- Add LSP for go files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { 'go', 'gomod', 'gowork', 'gotmpl' },
    callback = function(ev)
      vim.lsp.start({
        name = 'gopls',
        cmd = { vim.fn.exepath('gopls') },
        root_dir = vim.fs.dirname(vim.fs.find(
          {
            'go.mod',
            'go.sum',
            '.git'
          },
          {
            upward = true,
            stop = vim.loop.os_homedir(),
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
          })[1]),
        })
    end
})

-- Add LSP for python files
vim.api.nvim_create_autocmd("FileType", {
    pattern = { "python" },
    callback = function(ev)
      vim.lsp.start({
        name = 'jedi-language-server',
        cmd = { vim.fn.exepath('jedi-language-server') },
        root_dir = vim.fs.dirname(vim.fs.find(
          {
            'setup.py',
            'pyproject.toml',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            '.git'
          },
          {
            upward = true,
            stop = vim.loop.os_homedir(),
            path = vim.fs.dirname(vim.api.nvim_buf_get_name(0)),
          })[1]),
        })
    end
})

-- Oil
require("oil").setup({
	default_file_explorer = true,
  columns = {  -- See :help oil-columns
    -- "icon",
    -- "permissions",
    -- "size",
    -- "mtime",
  },
  keymaps = {
    ["g?"] = { "actions.show_help", mode = "n" },
    ["<CR>"] = "actions.select",
    ["<C-s>"] = { "actions.select", opts = { vertical = true } },
    ["<C-h>"] = false,
    ["<C-t>"] = { "actions.select", opts = { tab = true } },
    ["<C-p>"] = false,
    ["<C-c>"] = { "actions.close", mode = "n" },
    ["<C-l>"] = false,
    ["-"] = { "actions.parent", mode = "n" },
    ["_"] = { "actions.open_cwd", mode = "n" },
    ["`"] = { "actions.cd", mode = "n" },
    ["~"] = { "actions.cd", opts = { scope = "tab" }, mode = "n" },
    ["gs"] = { "actions.change_sort", mode = "n" },
    ["gx"] = "actions.open_external",
    ["g."] = { "actions.toggle_hidden", mode = "n" },
    ["g\\"] = { "actions.toggle_trash", mode = "n" },
  },
})
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

-- Open todo file
vim.api.nvim_create_user_command('Todo', function()
    vim.cmd('vsp ~/.TODO.md')
    vim.cmd('set ft=markdown')
end, {})

-- Open init.vim file
vim.api.nvim_create_user_command('Init', function()
    local init_file = vim.fn.stdpath('config') .. '/init.lua'
    vim.cmd('tabe ' .. vim.fn.fnameescape(init_file))
end, {})
