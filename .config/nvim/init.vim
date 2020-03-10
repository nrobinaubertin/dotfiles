" General configuration
colors gruvbox
set tabstop=4 shiftwidth=4 expandtab
set clipboard=unnamedplus " Use the clipboard for all operations
set fillchars=vert:\ ,stl:\ ,stlnc:\ 
set showmatch mat=2 mouse= nu showtabline=2 laststatus=2
set inccommand=split
set shell=/bin/bash
set undofile
set nomodeline " Can be a security issue
set smartindent
set list

" Statusline
set statusline=
set statusline+=\ [%n%H%M%R%W]\     " flags and buf no
set statusline+=\ %f\               " path
set statusline+=%=                  " switch to right side
set statusline+=%y\                 " file type
set statusline+=[%l,%c]\ %p%%\      " line, column and percentage

" Ctags
command! MakeTags !ctags -R -f .tags .
set tags+=,.tags,

" Set the background to red for trailing spaces
match ErrorMsg "\s\+$"

" Function to set tab spaces
function! SetTabSpaces(...)
    let &tabstop = a:1
    let &shiftwidth = a:1
endfunction
call SetTabSpaces(4)

" Retab the file
function! Retab()
    set noexpandtab
    retab!
    set expandtab
    retab!
endfunction

" When in a neovim terminal, add a buffer to the existing vim session instead of nesting (credit justinmk)
" You need socat to do this
" Nest when opening in man mode
if executable('socat')
    autocmd VimEnter * if @% != '' && &ft != 'man' && !&diff && !empty($NVIM_LISTEN_ADDRESS) && $NVIM_LISTEN_ADDRESS !=# v:servername
                \ |let g:r=jobstart(['socat', '-', 'UNIX-CLIENT:'.$NVIM_LISTEN_ADDRESS],{'rpc':v:true})
                \ |let g:f=fnameescape(expand('%:p'))
                \ |noau bwipe
                \ |call rpcrequest(g:r, "nvim_command", "tabe ".g:f)
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
autocmd TermEnter * let b:insertMode = "yes"
autocmd BufEnter * if &buftype == 'terminal' && b:insertMode != "no" | startinsert | endif

"" Terminal commands
tnoremap <A-q> <C-\><C-n>:let b:insertMode = "no"<CR>
tnoremap <A-t> <C-\><C-n>:tabe<CR>:term<CR>
noremap <A-t> <C-\><C-n>:tabe<CR>:term<CR>
tnoremap <A-c> <C-\><C-n>:tabe<CR>
noremap <A-c> <C-\><C-n>:tabe<CR>

" Tabs commands
nnoremap <A-l> :tabnext<CR>
inoremap <A-l> <Esc>:tabnext<CR>
tnoremap <A-l> <C-\><C-n>:tabnext<CR>
nnoremap <A-k> :tabmove +1<CR>
inoremap <A-k> <Esc>:tabmove +1<CR>
tnoremap <A-k> <C-\><C-n>:tabmove +1 <BAR> startinsert<CR>
nnoremap <A-j> :tabmove -1<CR>
inoremap <A-j> <Esc>:tabmove -1<CR>
tnoremap <A-j> <C-\><C-n>:tabmove -1 <BAR> startinsert<CR>
nnoremap <A-h> :tabprevious<CR>
inoremap <A-h> <Esc>:tabprevious<CR>
tnoremap <A-h> <C-\><C-n>:tabprevious<CR>

" Tab navigation shortcuts
nnoremap <A-^> :1tabnext<CR>
inoremap <A-^> <Esc>:1tabnext<CR>
tnoremap <A-^> <C-\><C-n>:1tabnext<CR>
nnoremap <A-$> :$tabnext<CR>
inoremap <A-$> <Esc>:$tabnext<CR>
tnoremap <A-$> <C-\><C-n>:$tabnext<CR>

" Windows commands
nnoremap <C-l> :wincmd l<CR>
inoremap <C-l> <Esc>:wincmd l<CR>
tnoremap <C-l> <C-\><c-n>:wincmd l<CR>
nnoremap <C-k> :wincmd k<CR>
inoremap <C-k> <Esc>:wincmd k<CR>
tnoremap <C-k> <C-\><c-n>:wincmd k<CR>
nnoremap <C-j> :wincmd j<CR>
inoremap <C-j> <Esc>:wincmd j<CR>
tnoremap <C-j> <C-\><c-n>:wincmd j<CR>
nnoremap <C-h> :wincmd h<CR>
inoremap <C-h> <Esc>:wincmd h<CR>
tnoremap <C-h> <C-\><c-n>:wincmd h<CR>

" Force writing with sudo
" Doesn't work for now: https://github.com/neovim/neovim/issues/1496
" command! SaveSudo :execute ':silent w !sudo tee % > /dev/null' <Bar> :edit!

" Open todo file
command! Todo execute ':tabe `=resolve(expand("~/.TODO"))`' <Bar> :set ft=markdown

" Output random string of 50 chars
command! Rand execute ':read! tr -dc a-zA-Z0-9 < /dev/urandom | head -c 50'

" Space bar un-highlights search
nnoremap <Space><Space> :silent noh<Bar>echo<CR>

" Netrw config, based on tpope/vinegar
let g:netrw_banner = 0
let g:netrw_browsex_viewer= "firefox"
nmap - :call Opendir('edit')<CR>
function! Opendir(cmd) abort
    if expand('%') =~# '^$\|^term:[\/][\/]'
        execute a:cmd '.'
    else
        execute a:cmd '%:h'
        let pattern = '^\%(| \)*'.escape(expand('#:t'), '.*[]~\').'[/*|@=]\=\%($\|\t\)'
        call search(pattern, 'wc')
    endif
endfunction

" Use 'correct' php indentation for switch blocks
let g:PHP_vintage_case_default_indent = 1

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
    Plug 'mhinz/vim-signify'
    Plug 'sheerun/vim-polyglot'
    Plug 'tpope/vim-fugitive'
    Plug 'w0rp/ale'
    Plug 'numirias/semshi'
    call plug#end()
endif

" disable polyglot on some languages
let g:polyglot_disabled = ['python']

" Vim-signify
let g:signify_sign_change = '~'

" w0rp/Ale
let g:ale_linters = {'python': ['pylint', 'flake8', 'autopep8']}
let g:ale_fixers = {'python': ['autopep8', 'yapf']}
let g:ale_lint_on_text_changed = 'never'

" rg
if executable('rg')
    set grepprg=rg\ --vimgrep
    set grepformat^=%f:%l:%c:%m
    let g:list_files_function = 'rg --files --color=never --hidden --glob "!.git/*"'
    let g:search_function = 'silent! grep --hidden --glob "!.git/*" '
else
    let g:list_files_function = "find -type f -not -path '*/\.*'"
    let g:search_function = 'silent! grep -srnw --binary-files=without-match --exclude-dir=.git '
endif

if executable('fzy')
    function! FzyCommand(choice_command, vim_command) abort
        let l:callback = {'window_id': win_getid(), 'filename': tempname(), 'vim_command': a:vim_command}

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
