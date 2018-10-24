" general configuration
colors gruvbox
set background=dark
set clipboard+=unnamedplus " Use the clipboard for all operations
set expandtab
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set mat=2
set mouse=
set noshowmode
set nu
set shell=/bin/bash
set showmatch
set showtabline=2
set laststatus=2
set undofile

""" statusline
set statusline=
set statusline+=[%n%H%M%R%W]\       " flags and buf no
set statusline+=\ %f\               " path
set statusline+=%=                  " switch to right side
set statusline+=%y\                 " file type
set statusline+=[%l,%c]\ %p%%       " line, column and percentage

""" ctags
if executable('ctags')
    command! MakeTags !ctags -R -f ./.git/tags .
endif
set tags+=,./.git/tags,

""" rg
if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat^=%f:%l:%c:%m
    let g:list_files_function = 'rg --files --color=never --hidden --glob "!.git/*"'
    let g:search_function = 'silent! grep --hidden --glob "!.git/*" '
else
    let g:list_files_function = "find -type f -not -path '*/\.*'"
    let g:search_function = 'silent! grep -srnw --binary-files=without-match --exclude-dir=.git '
endif

" Use 'correct' php indentation for switch blocks
let g:PHP_vintage_case_default_indent = 1

" The following options are good only if:
" - umask is restrictive (something like 077 to avoid security issues)
" - /tmp is mounted as tmpfs (the idea is to avoid disk writing)
let g:whoami = system("id -unz")
let &undodir="/tmp/".g:whoami."/nvim/undo"

" Set the background to red for trailing spaces
match ErrorMsg "\s\+$"

" Remap leader key
let mapleader=" "

" Set tab spaces
function! SetTabSpaces(...)
    let &tabstop = a:1
    let &shiftwidth = a:1
endfunction
call SetTabSpaces(4)

" Super vim search
function! SuperSearch(...)
    let location = a:0 > 1 ? a:2 : '.'
    execute g:search_function . a:1 . ' ' . location
    cw
    if !len(getqflist())
        echo "No match found for " . a:1
    endif
endfunction
command! -nargs=+ SuperSearch call SuperSearch(<f-args>)
map <Leader>s :execute SuperSearch(expand("<cword>"))<CR>:cc<CR>

" when in a neovim terminal, add a buffer to the existing vim session
" instead of nesting (credit justinmk)
" You need socat to do this
if executable('socat')
    autocmd VimEnter * if &ft != 'man' && !&diff && !empty($NVIM_LISTEN_ADDRESS) && $NVIM_LISTEN_ADDRESS !=# v:servername
                \ |let g:r=jobstart(['socat', '-', 'UNIX-CLIENT:'.$NVIM_LISTEN_ADDRESS],{'rpc':v:true})
                \ |let g:f=fnameescape(expand('%:p'))
                \ |noau bwipe
                \ |call rpcrequest(g:r, "nvim_command", "edit ".g:f)
                \ |qa
                \ |endif
endif

" Don't show tabline and statusline on a man page
autocmd VimEnter * if &ft == 'man'
            \ |set showtabline=0
            \ |set laststatus=0
            \ |endif

" start in insert mode when opening a new terminal buffer
autocmd TermOpen * startinsert

"" Terminal commands
tnoremap <A-q> <C-\><C-n>
tnoremap <A-t> <C-\><C-n>:tabe<CR>:term<CR>
noremap <A-t> <C-\><C-n>:tabe<CR>:term<CR>
tnoremap <A-c> <C-\><C-n>:tabe<CR>
noremap <A-c> <C-\><C-n>:tabe<CR>

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

" Force writing with sudo
command! SaveSudo :execute ':silent w !sudo tee % > /dev/null' <Bar> :edit!

" Open todo file
command! Todo execute ":tabe $HOME/data/niels-data/.TODO"

" Space bar un-highlights search
nnoremap <Space><Space> :silent noh<Bar>echo<CR>

" Get vim-plug
if !filereadable(expand("$HOME/.config/nvim/autoload/plug.vim"))
    echo system("curl -fLo $HOME/.config/nvim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim")
endif

" Update plugins
function! Update()
    PlugUpgrade
    PlugUpdate
endfunction

" Vim-plug
if filereadable(expand("$HOME/.config/nvim/autoload/plug.vim"))
    call plug#begin('~/.config/nvim/plugged')
    Plug 'junegunn/gv.vim'
    Plug 'justinmk/vim-dirvish'
    Plug 'mhinz/vim-signify'
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-fugitive'
    Plug 'w0rp/ale'
    call plug#end()
endif

" Dirvish, hide dotfiles
autocmd FileType dirvish silent keeppatterns g@\v/\.[^\/]+/?$@d _

" Vim-signify
let g:signify_sign_change = '~'

" w0rp/Ale
let g:ale_linters = {'python': 'autopep8'}
let g:ale_lint_on_text_changed = 'never'

if executable('fzy')
    function! FzyCommand(choice_command, vim_command) abort
        let l:callback = {
                    \ 'window_id': win_getid(),
                    \ 'filename': tempname(),
                    \  'vim_command':  a:vim_command
                    \ }

        function! l:callback.on_exit(job_id, data, event) abort
            bdelete!
            call win_gotoid(self.window_id)
            if filereadable(self.filename)
                try
                    let l:selected_filename = readfile(self.filename)[0]
                    exec self.vim_command . l:selected_filename
                catch /E684/
                endtry
            endif
            call delete(self.filename)
        endfunction

        botright 10 new
        let l:term_command = a:choice_command . ' | fzy > ' .  l:callback.filename
        silent call termopen(l:term_command, l:callback)
        setlocal nonumber norelativenumber
        startinsert
    endfunction
    nnoremap <A-f> :call FzyCommand(g:list_files_function, ":tabe ")<CR>
    tnoremap <A-f> <C-\><C-n>:call FzyCommand(g:list_files_function, ":tabe ")<CR>
    inoremap <A-f> <Esc>:call FzyCommand(g:list_files_function, ":tabe ")<CR>
    nnoremap <A-e> :call FzyCommand(g:list_files_function, ":e ")<CR>
    tnoremap <A-e> <C-\><C-n>:call FzyCommand(g:list_files_function, ":e ")<CR>
    inoremap <A-e> <Esc>:call FzyCommand(g:list_files_function, ":e ")<CR>
    nnoremap <A-v> :call FzyCommand(g:list_files_function, ":vsp ")<CR>
    tnoremap <A-v> <C-\><C-n>:call FzyCommand(g:list_files_function, ":vsp ")<CR>
    inoremap <A-v> <Esc>:call FzyCommand(g:list_files_function, ":vsp ")<CR>
endif

" The french keyboard is awesome
inoremap àà À
inoremap éé É
inoremap êê Ê
inoremap èè È
inoremap çç Ç

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
