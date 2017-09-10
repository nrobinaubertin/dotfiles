set nu
set showcmd
set ruler
set showmatch
set mat=2
set novisualbell
set noerrorbells
set shiftwidth=4
set tabstop=4
set softtabstop=4
set expandtab
set noshowmode
set background=dark
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set laststatus=2

" ignore some files
set wildignore+=*/.git/*,*.swp,*.orig

"Remap leader Key
let mapleader=","

" I need the 'Ç' sometimes...
inoremap çç Ç

"" Windows commands
noremap <C-Up> :wincmd k<CR>
inoremap <C-Up> <Esc>:wincmd k<CR>i
tnoremap <C-Up> <C-\><C-n>:wincmd k<CR>i
noremap <C-Down> :wincmd j<CR>
inoremap <C-Down> <Esc>:wincmd j<CR>i
tnoremap <C-Down> <C-\><C-n>:wincmd j<CR>i
noremap <C-Left> :wincmd h<CR>
inoremap <C-Left> <Esc>:wincmd h<CR>i
tnoremap <C-Left> <C-\><C-n>:wincmd h<CR>i
noremap <C-Right> :wincmd l<CR>
inoremap <C-Right> <Esc>:wincmd l<CR>i
tnoremap <C-Right> <C-\><C-n>:wincmd l<CR>i

" resize windows
nnoremap <silent> <Leader>> :exe "vertical resize " . (winwidth(0) * 3/2)<CR>
inoremap <silent> <Leader>> :exe "vertical resize " . (winwidth(0) * 3/2)<CR>i
tnoremap <silent> <Leader>> :exe "vertical resize " . (winwidth(0) * 3/2)<CR>i
nnoremap <silent> <Leader>< :exe "vertical resize " . (winwidth(0) * 2/3)<CR>
inoremap <silent> <Leader>< :exe "vertical resize " . (winwidth(0) * 2/3)<CR>i
tnoremap <silent> <Leader>< :exe "vertical resize " . (winwidth(0) * 2/3)<CR>i

"" Tabs commands
noremap <C-k> :tabnext<CR>
nnoremap <C-k> :tabnext<CR>
inoremap <C-k> <Esc>:tabnext<CR>i
tnoremap <C-k> <C-\><C-n>:tabnext<CR>i
noremap <C-j> :tabprevious<CR>
nnoremap <C-j> :tabprevious<CR>
inoremap <C-j> <Esc>:tabprevious<CR>i
tnoremap <C-j> <C-\><C-n>:tabprevious<CR>i

" force writing with sudo
cnoremap w!! %!sudo tee >/dev/null %

" space bar un-highlights search
:noremap <silent> <Space> :silent noh<Bar>echo<CR>

" update plugins
command Update execute "PlugUpgrade | PlugUpdate"

" vim-plug
call plug#begin('~/.config/nvim/plugged')
Plug 'itchyny/lightline.vim'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --key-bindings --completion --no-update-rc' }
Plug 'junegunn/fzf.vim'
Plug 'junegunn/gv.vim'
Plug 'mhinz/vim-signify'
Plug 'morhetz/gruvbox'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-fugitive'
Plug 'w0rp/ale'
Plug 'xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }

Plug 'amadeus/vim-mjml'
call plug#end()

" NERDTree options
map <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd FileType nerdtree noremap <buffer> <C-k> :tabnext<CR>
autocmd FileType nerdtree noremap <buffer> <C-j> :tabprevious<CR>

" fzf
let $FZF_DEFAULT_COMMAND = 'find . 2>/dev/null'
noremap <Leader>b :Buffers<CR>
noremap <Leader>h :History<CR>
noremap <Leader>f :FZF<CR>
"noremap <Leader>d :exe ':FZF ' . expand('<cword>')<CR>
if executable('rg')
    set grepprg=rg\ --vimgrep
    let $FZF_DEFAULT_COMMAND = 'rg . --files --color=never --hidden --glob "!.git/*" 2>/dev/null'
endif

" lightline
let g:lightline = {'colorscheme': 'gruvbox'}

" vim-signify
let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_change = '~'

" gruvbox
colors gruvbox
