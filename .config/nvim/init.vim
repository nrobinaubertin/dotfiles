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
set clipboard+=unnamedplus " use the clipboard for all operations

" the following options are good only if:
" - umask is restrictive (something like 077)
" - /tmp is mounted as tmpfs
let g:whoami = system("id -unz")
set undofile
let &undodir="/tmp/".g:whoami."/nvim/undo"

" set the background to red for trailing spaces
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

"" Terminal commands
tnoremap <C-q> <C-\><C-n>
noremap <Leader>c :tab new<CR>:term<CR>i
noremap <Leader>% :vsp<CR><C-w><C-w>:term<CR>i
noremap <Leader>" :sp<CR><C-w><C-w>:term<CR>i

" when in a neovim terminal, add a buffer to the existing vim session
" instead of nesting (credit justinmk)
" You need socat to do this
if executable('socat')
    autocmd VimEnter * if !empty($NVIM_LISTEN_ADDRESS) && $NVIM_LISTEN_ADDRESS !=# v:servername
        \ |let g:r=jobstart(['socat', '-', 'UNIX-CLIENT:'.$NVIM_LISTEN_ADDRESS],{'rpc':v:true})
        \ |let g:f=fnameescape(expand('%:p'))
        \ |noau bwipe
        \ |call rpcrequest(g:r, "nvim_command", "edit ".g:f)
        \ |qa
        \ |endif
endif

" start in insert mode when opening a terminal buffer
autocmd BufEnter * if &buftype == 'terminal' | startinsert | endif

"" Windows commands
nnoremap <C-k> :wincmd k<CR>
inoremap <C-k> <Esc>:wincmd k<CR>
tnoremap <C-k> <C-\><C-n>:wincmd k<CR>
nnoremap <C-j> :wincmd j<CR>
inoremap <C-j> <Esc>:wincmd j<CR>
tnoremap <C-j> <C-\><C-n>:wincmd j<CR>
nnoremap <C-h> :wincmd h<CR>
inoremap <C-h> <Esc>:wincmd h<CR>
tnoremap <C-h> <C-\><C-n>:wincmd h<CR>
nnoremap <C-l> :wincmd l<CR>
inoremap <C-l> <Esc>:wincmd l<CR>
tnoremap <C-l> <C-\><C-n>:wincmd l<CR>

"" Tabs commands
nnoremap <A-l> :tabnext<CR>
inoremap <A-l> <Esc>:tabnext<CR>
tnoremap <A-l> <C-\><C-n>:tabnext<CR>
nnoremap <A-h> :tabprevious<CR>
inoremap <A-h> <Esc>:tabprevious<CR>
tnoremap <A-h> <C-\><C-n>:tabprevious<CR>
nnoremap <A-j> :tabmove -1<CR>
inoremap <A-j> <Esc>:tabmove -1<CR>
tnoremap <A-j> <C-\><C-n>:tabmove -1<CR>
nnoremap <A-k> :tabmove +1<CR>
inoremap <A-k> <Esc>:tabmove +1<CR>
tnoremap <A-k> <C-\><C-n>:tabmove +1<CR>

" force writing with sudo
cnoremap w!! %!sudo tee >/dev/null %

" super vim search
function! SuperSearch(...)
    let search = a:1
    let location = a:0 > 1 ? a:2 : '.'
    if executable('rg')
        execute 'silent! grep --hidden --glob "!.git/*" ' . search . ' ' . location
    else
        execute 'silent! grep -srnw --binary-files=without-match --exclude-dir=.git ' . search . ' ' . location
    endif
    if len(getqflist())
        copen
        redraw!
        cc
    else
        cclose
        redraw!
        echo "No match found for " . search
    endif
endfunction
command -nargs=+ SuperSearch call SuperSearch(<f-args>)
map <Leader>s :execute SuperSearch(expand("<cword>"))<CR>

" space bar un-highlights search
nnoremap <silent> <Leader> <Space> :silent noh<Bar>echo<CR>

" get vim-plug
if !filereadable(expand("$HOME/.config/nvim/autoload/plug.vim"))
    echo system("curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim")
endif

" update plugins
command Update execute Update()
function! Update()
    " load phpstan and phpcs phar to be used with ale
    if !filereadable(expand("$HOME/.config/nvim/bin/phpstan"))
        echo system("mkdir -p $HOME/.config/nvim/bin")
        echo system("wget -q -O $HOME/.config/nvim/bin/phpstan https://github.com/phpstan/phpstan/releases/download/0.8.5/phpstan.phar")
    endif
    if !filereadable(expand("$HOME/.config/nvim/bin/phpcs"))
        echo system("mkdir -p $HOME/.config/nvim/bin")
        echo system("wget -q -O $HOME/.config/nvim/bin/phpcs https://github.com/squizlabs/PHP_CodeSniffer/releases/download/3.1.1/phpcs.phar")
    endif
    PlugUpgrade
    PlugUpdate
endfunction

" vim-plug
if filereadable(expand("$HOME/.config/nvim/autoload/plug.vim"))
    call plug#begin('~/.config/nvim/plugged')
    Plug 'itchyny/lightline.vim'
    Plug 'jremmen/vim-ripgrep'
    Plug 'jremmen/vim-ripgrep'
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --key-bindings --completion --no-update-rc' }
    Plug 'junegunn/fzf.vim'
    Plug 'junegunn/gv.vim'
    Plug 'justinmk/vim-sneak'
    Plug 'mhinz/vim-signify'
    Plug 'morhetz/gruvbox'
    Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-fugitive'
    Plug 'w0rp/ale'
    Plug 'xuyuanp/nerdtree-git-plugin', { 'on': 'NERDTreeToggle' }
    call plug#end()
endif

" vim-sneak
let g:sneak#label = 1

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

" vim-signify
let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_change = '~'

" ale
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_text_changed = 'never'
let g:ale_maximum_file_size = 16384

if filereadable(expand("$HOME/.config/nvim/bin/phpstan"))
    let g:ale_php_phpstan_executable = expand("$HOME/.config/nvim/bin/phpstan")
endif
if filereadable(expand("$HOME/.config/nvim/bin/phpcs"))
    let g:ale_php_phpcs_executable = expand("$HOME/.config/nvim/bin/phpcs")
    let g:ale_php_phpcs_standard = 'PSR2'
endif

" Rg
nnoremap <leader>a :Rg<space>
nnoremap <leader>A :exec "Rg ".expand("<cword>")<cr>
autocmd VimEnter * command! -nargs=* Rg
    \ call fzf#vim#grep(
    \   'rg --column --line-number --no-heading --fixed-strings --ignore-case --hidden --follow --glob "!.git/*" --color "always" 2>/dev/null '.shellescape(<q-args>), 1,
    \   <bang>0 ? fzf#vim#with_preview('up:60%')
    \           : fzf#vim#with_preview('right:50%:hidden', '?'),
    \   <bang>0)

if executable('rg')
    let $FZF_DEFAULT_COMMAND = 'rg . --files --color=never --hidden --glob "!.git/*" 2>/dev/null'
    set grepprg=rg\ --vimgrep
    set grepformat^=%f:%l:%c:%m
endif

" gruvbox
if filereadable(expand("$HOME/.config/nvim/plugged/gruvbox/autoload/gruvbox.vim"))
    colors gruvbox
    let g:lightline = {'colorscheme': 'gruvbox'}
endif
