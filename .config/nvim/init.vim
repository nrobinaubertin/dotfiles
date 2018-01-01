set nu
set showcmd
set ruler
set showmatch
set mouse=
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
set shell=/bin/bash

match ErrorMsg "\s\+$"

" ignore some files
set wildignore+=*/.git/*,*.swp,*.orig

"Remap leader Key
let mapleader=" "

" The french keyboard is awesome
inoremap çç Ç
inoremap àà À
inoremap éé É
inoremap êê Ê

"" Windows commands
nnoremap <C-Up> :wincmd k<CR>
inoremap <C-Up> <Esc>:wincmd k<CR>i
tnoremap <C-Up> <C-\><C-n>:wincmd k<CR>i
nnoremap <C-Down> :wincmd j<CR>
inoremap <C-Down> <Esc>:wincmd j<CR>i
tnoremap <C-Down> <C-\><C-n>:wincmd j<CR>i
nnoremap <C-Left> :wincmd h<CR>
inoremap <C-Left> <Esc>:wincmd h<CR>i
tnoremap <C-Left> <C-\><C-n>:wincmd h<CR>i
nnoremap <C-Right> :wincmd l<CR>
inoremap <C-Right> <Esc>:wincmd l<CR>i
tnoremap <C-Right> <C-\><C-n>:wincmd l<CR>i

"" Tabs commands
nnoremap <C-k> :tabnext<CR>
inoremap <C-k> <Esc>:tabnext<CR>i
tnoremap <C-k> <C-\><C-n>:tabnext<CR>i
nnoremap <C-j> :tabprevious<CR>
inoremap <C-j> <Esc>:tabprevious<CR>i
tnoremap <C-j> <C-\><C-n>:tabprevious<CR>i
nnoremap <A-j> :tabmove -1<CR>
nnoremap <A-k> :tabmove +1<CR>
inoremap <A-j> :tabmove -1<CR>i
inoremap <A-k> :tabmove +1<CR>i
tnoremap <A-j> :tabmove -1<CR>i
tnoremap <A-k> :tabmove +1<CR>i

" force writing with sudo
cnoremap w!! %!sudo tee >/dev/null %

if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat^=%f:%l:%c:%m
endif

" super vim search
function! SuperSearch(...)
    let search = a:1
    let location = a:0 > 1 ? a:2 : '.'
    tabe
    if executable('rg')
        execute 'silent grep --hidden --glob "!.git/*" ' . search . ' ' . location
    else
        execute 'silent grep -srnw --binary-files=without-match --exclude-dir=.git ' . search . ' ' . location
    endif
    try
        cwindow
        cc
    catch /E42/
        echo "Nothing found"
        quit
    endtry
endfunction
command -nargs=+ SuperSearch call SuperSearch(<f-args>)
map <Leader>s :execute SuperSearch(expand("<cword>"))<CR>

" space bar un-highlights search
nnoremap <silent> <Leader> <Space> :silent noh<Bar>echo<CR>

" update plugins
command Update execute "PlugUpgrade | PlugUpdate"

if !filereadable(expand("$HOME/.config/nvim/autoload/plug.vim"))
    echo system("curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim")
endif

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
" testing
Plug 'amadeus/vim-mjml'
call plug#end()

" NERDTree options
noremap <C-n> :NERDTreeToggle<CR>
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | endif
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
autocmd FileType nerdtree noremap <buffer> <C-k> :tabnext<CR>
autocmd FileType nerdtree noremap <buffer> <C-j> :tabprevious<CR>

" fzf
let $FZF_DEFAULT_COMMAND = 'find . 2>/dev/null'
nnoremap <Leader>b :Buffers<CR>
nnoremap <Leader>h :History<CR>
nnoremap <Leader>f :FZF<CR>
if executable('rg')
    let $FZF_DEFAULT_COMMAND = 'rg . --files --color=never --hidden --glob "!.git/*" 2>/dev/null'
endif

" lightline
let g:lightline = {'colorscheme': 'gruvbox'}

" vim-signify
let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_change = '~'

" gruvbox
colors gruvbox

" ale
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_maximum_file_size = 16384

" load phpstan and phpcs phar
if !filereadable(expand("$HOME/.config/nvim/bin/phpstan"))
    echo system("mkdir -p $HOME/.config/nvim/bin")
    echo system("wget -q -O $HOME/.config/nvim/bin/phpstan https://github.com/phpstan/phpstan/releases/download/0.8.5/phpstan.phar")
endif
if !filereadable(expand("$HOME/.config/nvim/bin/phpcs"))
    echo system("mkdir -p $HOME/.config/nvim/bin")
    echo system("wget -q -O $HOME/.config/nvim/bin/phpcs https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.1.1/phpcs.phar")
endif
let g:ale_php_phpstan_executable = expand("$HOME/.config/nvim/bin/phpstan")
let g:ale_php_phpcs_executable = expand("$HOME/.config/nvim/bin/phpcs")
let g:ale_php_phpcs_standard = 'PSR2'
