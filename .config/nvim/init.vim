" general configuration
set background=dark
set clipboard+=unnamedplus " Use the clipboard for all operations
set expandtab
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set laststatus=2
set mat=2
set mouse=
set noshowmode
set nu
set shell=/bin/bash
set showmatch
set showtabline=2

""" ctags
if executable('ctags')
    command! MakeTags !ctags -R -f ./.git/tags .
endif
set tags+=,./.git/tags,

" Use 'correct' php indentation for switch blocks
let g:PHP_vintage_case_default_indent = 1

" The following options are good only if:
" - umask is restrictive (something like 077 to avoid security issues)
" - /tmp is mounted as tmpfs (the idea is to avoid disk writing)
let g:whoami = system("id -unz")
set undofile
let &undodir="/tmp/".g:whoami."/nvim/undo"

" Set the background to red for trailing spaces
match ErrorMsg "\s\+$"

" Ignore some files
" set wildignore+=,**/.git/*,*.swp,*.orig,

" Remap leader key
let mapleader=" "

" Set tab spaces
function! SetTabSpaces(...)
    let &tabstop = a:1
    let &shiftwidth = a:1
endfunction
command -nargs=+ SetTabSpaces call SetTabSpaces(<f-args>)
call SetTabSpaces(4)

" Super vim search
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

" Get vim-plug
if !filereadable(expand("$HOME/.config/nvim/autoload/plug.vim"))
    echo system("curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim")
endif

" Update plugins
command Update execute Update()
function! Update()
    PlugUpgrade
    PlugUpdate
endfunction

" Vim-plug
if filereadable(expand("$HOME/.config/nvim/autoload/plug.vim"))
    call plug#begin('~/.config/nvim/plugged')
    Plug 'itchyny/lightline.vim'
    Plug 'junegunn/gv.vim'
    Plug 'mhinz/vim-signify'
    Plug 'morhetz/gruvbox'
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-fugitive'
    Plug 'justinmk/vim-dirvish'
    call plug#end()
endif

" The french keyboard is awesome
inoremap àà À
inoremap ää Ä
inoremap ââ Â
inoremap éé É
inoremap êê Ê
inoremap èè È
inoremap çç Ç

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

"" Terminal commands
tnoremap <A-q> <C-\><C-n>
tnoremap <A-t> <C-\><C-n>:tabe<CR>:term<CR>i
tnoremap <A-c> <C-\><C-n>:tabe<CR>
tnoremap <A-v> <C-\><C-n>:vsp<CR><C-w><C-w>:term<CR>i
noremap <A-t> <C-\><C-n>:tabe<CR>:term<CR>i
noremap <A-c> <C-\><C-n>:tabe<CR>
noremap <A-v> :vsp<CR><C-w><C-w>:term<CR>i

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

"" Vue manipulation
nnoremap <A-z> :-tabe %<CR>

" Force writing with sudo
command! SaveSudo :execute ':silent w !sudo tee % > /dev/null' | :edit!

" Open todo file
command Todo execute ":tabe $HOME/.TODO"

" Space bar un-highlights search
nnoremap <Space><Space> :silent noh<Bar>echo<CR>

" Vim-dirwish
let g:loaded_netrwPlugin = 1
command! VleftDirvish leftabove vsplit | vertical resize 50 | silent Dirvish
nnoremap <C-n> :VleftDirvish<CR>
tnoremap <C-n> <C-\><C-n> :VleftDirvish<CR>
nnoremap <buffer> ~ :edit ~/<CR>

" Vim-signify
let g:signify_vcs_list = [ 'git' ]
let g:signify_sign_change = '~'

if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat^=%f:%l:%c:%m
endif

" Lightline & Gruvbox
if filereadable(expand("$HOME/.config/nvim/plugged/gruvbox/autoload/gruvbox.vim"))
    if filereadable(expand("$HOME/bin/get"))

        let s:status = system("$HOME/bin/get 'status' '|'")
        let s:status_timestamp = strftime('%s')

        function! GetStatus()
            if s:status_timestamp + 20 < strftime('%s')
                let s:status = system("$HOME/bin/get 'status' '|'")
                let s:status_timestamp = strftime('%s')
            endif
            return s:status
        endfunction

        let g:lightline = {
                    \   'tabline': {
                    \       'left': [['tabs']],
                    \       'right': [['get_status']]
                    \   },
                    \   'component_function': {
                    \       'get_status': 'GetStatus',
                    \   },
                    \   'colorscheme': 'gruvbox',
                    \ }
    endif
    colors gruvbox
endif

" learn vim the hard way
nnoremap <up> <nop>
nnoremap <down> <nop>
nnoremap <left> <nop>
nnoremap <right> <nop>
inoremap <up> <nop>
inoremap <down> <nop>
inoremap <left> <nop>
inoremap <right> <nop>
vnoremap <up> <nop>
vnoremap <down> <nop>
vnoremap <left> <nop>
vnoremap <right> <nop>
