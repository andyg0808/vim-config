" Up here to avoid interfering with auto-guessed indent
set encoding=utf8
set tabstop=2
set shiftwidth=2
set expandtab

function s:assembly_config()
  set tabstop=8
  set noexpandtab
  set shiftwidth=8
endfunction

autocmd BufNewFile,BufRead *.S,*.s call s:assembly_config()

" This needs to be overridden by the jedi plugin for python, so we set it
" before loading plugins.
set omnifunc=syntaxcomplete#Complete

call plug#begin(stdpath('data') . '/plugged')

Plug 'airblade/vim-gitgutter'
Plug 'altercation/vim-colors-solarized'
Plug 'dense-analysis/ale'
Plug 'easymotion/vim-easymotion'
Plug 'haya14busa/incsearch-easymotion.vim'
Plug 'haya14busa/incsearch-fuzzy.vim'
Plug 'haya14busa/incsearch.vim'
Plug 'jlanzarotta/bufexplorer'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'mbbill/undotree'
Plug 'mg979/vim-visual-multi', {'branch': 'master'}
Plug 'preservim/nerdtree'
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-sensible'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-surround'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'wellle/targets.vim'

" Initialize plugin system
call plug#end()

" Set up Solarized
syntax enable
set background=light
colorscheme solarized

" bufexplorer
nnoremap <silent> <leader>bb :BufExplorer<CR>

" Enable filetype detection
filetype plugin on

" Enable reading manpages in vim.
runtime ftplugin/man.vim

" Make % know about tags and other paired things.
runtime macros/matchit.vim

" Set folding to be based on indents, and disable it to start with.
set foldmethod=indent
set nofoldenable

" Number file lines
set number

function ColumnMark()
  " Display the 81st column, or the column after textwidth.
  if &textwidth != 0
    " Display the column after textwidth. Since we're going to automatically
    " wrap here, it makes sense that we would want to display that instead of
    " the standard 80-char point
    set colorcolumn=+1
  else
    set colorcolumn=81
  endif
  " set textwidth=80 " Hard wrapping
endfunction

call ColumnMark()
" Reset the ColumnMark position after reading a buffer. Supposed to make sure
" that it updates for per-filetype textwidths.
autocmd BufNewFile,BufRead * call ColumnMark()

" Derived from http://shallowsky.com/blog/linux/editors/vim-ctrl-space.html
" Keeps Ctrl-space from causing strange destruction, and instead makes it like
" Tab. Keeps my brain happier when switching from Eclipse.
imap <Nul> <Tab>

" Create a command that will paste from the clipboard in paste mode, without
" leaving it on.
function Paste()
  set paste
  normal "+p
  set nopaste
endfunction

command Paste call Paste()

" Disable arrow keys to force using HJKL
inoremap  <Up>     <NOP>
inoremap  <Down>   <NOP>
inoremap  <Left>   <NOP>
inoremap  <Right>  <NOP>
noremap   <Up>     <NOP>
noremap   <Down>   <NOP>
noremap   <Left>   <NOP>
noremap   <Right>  <NOP>

" Provide mapping to allow scrolling the other pane with two-pane view
noremap  <c-n> <c-w>w<c-e><c-w>p
noremap  <c-p> <c-w>w<c-y><c-w>p
inoremap <c-n> <esc><c-w>w<c-e><c-w>pa
inoremap <c-p> <esc><c-w>w<c-y><c-w>pa

" Handles the backspace key, creating a new undo point when the backspace key
" is pressed after a time of not pressing it. See code for details. Very helpful
" when writing, as it keeps backspacing from permanently loosing whatever
" you'd written
function TimeUndo(key)
  if b:lastundo >= localtime()
    " This keeps the lastundo timeout ahead of the last backspace press
    " (allows consecutive character removals to result in one undo point). The
    " amount added changes how long after a second (or third, or fourth, or
    " fifth...) keypress the backspace key will revert to creating an undo
    " point on press
    let b:lastundo = localtime() + 2
    return a:key
  else
    " This sets the initial timeout of undo points. If the backspace key is
    " pressed before this, it will not create a new undo point, thus keeping
    " the undo from being mostly backspacing
    let b:lastundo = localtime() + 2
    return "\<C-G>u" . a:key
  endif
endfunction
" Map the backspace key and <C-W> to create undo points
inoremap <expr> <BS> TimeUndo("\<BS>")
inoremap <expr> <C-W> TimeUndo("\<C-W>")
" As below, sets up the variable that TimeUndo is expecting. Sets it to 1
" second ago, to ensure that on the first run of TimeUndo an undo point will
" be saved.
autocmd BufEnter * if !exists('b:lastundo') | let b:lastundo = localtime() - 1 | endif

" Map <C-U> to always start an undo sequence when it is typed
inoremap <C-U> <C-G>u<C-U>

" Allow toggling autowrapping with F12
function ToggleWrap()
  if match(&formatoptions, 'a') > 0
    set formatoptions-=a
  else
    set formatoptions+=a
  endif
endfunction

" http://stackoverflow.com/q/11337129/2243495 really helped here
nnoremap <F12> :call ToggleWrap()<CR>
inoremap <F12> <esc>:call ToggleWrap()<CR>a

" For vim-latex
let g:tex_flavor='latex'

" Use rg; for most things it's the right thing to do.
set grepprg=rg\ -n
nnoremap g* yiw:grep <C-R>"<CR>

"set spell
set spelllang=en_us,en_gb

set keywordprg=dict
set dictionary=/usr/share/dict/words

" Highlight searches
set hlsearch

" Case-insensitive matching
set ignorecase
set smartcase

set smartindent

set backupcopy=yes

" Taken from http://vim.wikia.com/wiki/Search_for_visually_selected_text
" Allows searching for selection with //
vnorem // y/<c-r>"<cr>

" Enable powerline fonts
let g:airline_powerline_fonts=1

" Stolen from https://github.com/fatih/vim-go/issues/1447#issuecomment-329281855
" Makes C-l the 'fix-all' key
nnoremap <silent> <C-l> :nohlsearch<CR>:diffupdate<CR>:syntax sync fromstart<CR><C-l>

" Easymotion config. Mostly cribbed from docs
map <Leader> <Plug>(easymotion-prefix)

let g:EasyMotion_smartcase = 1
" Same idea as smartcase, but for symbols. US layout
let g:EasyMotion_use_smartsign_us = 1
" keep cursor column when JK motion
let g:EasyMotion_startofline = 0
"nmap s <Plug>(easymotion-s)
"map  / <Plug>(easymotion-sn)
"omap / <Plug>(easymotion-tn)
" These `n` & `N` mappings are options. You do not have to map `n` & `N` to
" EasyMotion.
" Without these mappings, `n` & `N` works fine. (These mappings just provide
" different highlight method and have some other features )
"map  n <Plug>(easymotion-next)
"map  N <Plug>(easymotion-prev)
map <Leader>n <Plug>(easymotion-n)
map <Leader>p <Plug>(easymotion-p)

let g:EasyMotion_startofline = 0 " keep cursor column when JK motion

nmap f <Plug>(easymotion-f)
nmap F <Plug>(easymotion-F)

" Ale config
let g:ale_fixers = {
\   'python': ['isort', 'black'],
\   'javascript': ['prettier'],
\   'perl': ['perltidy'],
\   'ruby': ['rufo'],
\   'rust': ['rustfmt'],
\}

let g:ale_linters = {
\   'javascript': ['eslint'],
\   'ruby': ['rubocop']
\}

nnoremap <C-k> :FZF<CR>

" incsearch config

" From https://github.com/easymotion/vim-easymotion
" You can use other keymappings like <C-l> instead of <CR> if you want to
" use these mappings as default search and sometimes want to move cursor with
" EasyMotion.
function! s:incsearch_config(...) abort
  return incsearch#util#deepextend(deepcopy({
  \   'modules': [incsearch#config#easymotion#module({'overwin': 1})],
  \   'keymap': {
  \     "\<CR>": '<Over>(easymotion)'
  \   },
  \   'is_expr': 0
  \ }), get(a:, 1, {}))
endfunction

noremap <silent><expr> /  incsearch#go(<SID>incsearch_config())
noremap <silent><expr> ?  incsearch#go(<SID>incsearch_config({'command': '?'}))
noremap <silent><expr> g/ incsearch#go(<SID>incsearch_config({'is_stay': 1}))

" From https://github.com/haya14busa/incsearch-easymotion.vim
function! s:config_easyfuzzymotion(...) abort
  return extend(copy({
  \   'converters': [incsearch#config#fuzzy#converter()],
  \   'modules': [incsearch#config#easymotion#module()],
  \   'keymap': {"\<CR>": '<Over>(easymotion)'},
  \   'is_expr': 0,
  \   'is_stay': 1
  \ }), get(a:, 1, {}))
endfunction

noremap <silent><expr> <Space>/ incsearch#go(<SID>config_easyfuzzymotion())
