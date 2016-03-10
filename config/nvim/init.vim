" VIMrc
" =====
set nocompatible " No VI compatibility
set autoread " Detect file changes outside vim

" Plug all the Plugins
" ====================
call plug#begin('~/.config/nvim/bundle')

" Can't live without colors
" Plug 'nanotech/jellybeans.vim'
Plug 'w0ng/vim-hybrid'
Plug 'frankier/neovim-colors-solarized-truecolor-only'
Plug 'morhetz/gruvbox'
" Plug 'AlessandroYorba/Alduin'
" Plug 'AlessandroYorba/Sierra'
" Plug 'tpope/vim-vividchalk'
" Plug 'junegunn/seoul256.vim'
" Plug 'vim-scripts/wombat256.vim'
" Plug 'vim-scripts/xoria256.vim'

" Experimental
" Plug 'Olical/vim-enmasse'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
" Plug 'Valloric/YouCompleteMe', { 'do': './install.py' }

Plug 'SirVer/ultisnips' " Snippets
Plug 'benekastah/neomake' " Async execution engine for syntax checking
Plug 'bronson/vim-visual-star-search' " Visual star search
" Plug '0x0dea/vim-molasses' " For not being efficient...
" Plug 'ap/vim-buftabline' " Display open buffers
" Plug 'ervandew/supertab' " Tab completion instead of ctrl p and n
Plug 'Raimondi/delimitMate' " Auto insert paired characters
Plug 'rking/ag.vim'
Plug 'mhinz/vim-signify' " 'airblade/vim-gitgutter' Nice git lines at the side
Plug 'rizzatti/dash.vim' " Dash integration
Plug 'vim-airline/vim-airline' " Very powerline
Plug 'vim-airline/vim-airline-themes' " Such themes

Plug 'tpope/vim-commentary' " Commentary
Plug 'tpope/vim-fugitive' " Git interactions within VIM (blame and diff)
Plug 'tpope/vim-surround' " Surround
Plug 'tpope/vim-repeat' " Repeat last command with .
Plug 'tpope/vim-unimpaired' " Additional paired mappings
Plug 'tpope/vim-abolish' " Better abbrev

Plug 'junegunn/limelight.vim', { 'on': 'Limelight' } " Focusing tool
Plug 'junegunn/goyo.vim', { 'on': 'Limelight' } " Focusing tool

Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript']} " Zen coding at it's best
Plug 'othree/html5.vim', { 'for': 'html' }

Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'othree/yajs.vim', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'javascript' }
Plug 'moll/vim-node', { 'for': 'javascript' }
" Plug 'helino/vim-json', { 'for': 'json' }

Plug 'leafgarland/typescript-vim', { 'for': 'typescript' } " Might come handy
Plug 'mustache/vim-mustache-handlebars'
" Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
" Plug 'wavded/vim-stylus', { 'for': 'stylus' }
" Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'ap/vim-css-color', { 'for': 'css' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'tpope/vim-markdown', { 'for': 'markdown' }
Plug 'fatih/vim-go', { 'for': 'go' }
Plug 'rust-lang/rust.vim', { 'for': 'rust' }

call plug#end()

" General settings
" ================
let mapleader="\<Space>"
set hidden " Some kind of buffer tweak
set history=1000
set undofile
set undolevels=1000
set title " Set title of the window
set clipboard=unnamed " Use OS clipboard
" set encoding=utf-8
set mouse=a
set backspace=indent,eol,start
set lazyredraw
set ttyfast
set showmatch " Highlight matching pair
set list " Display invisibles
set listchars=tab:▸\ ,eol:¬,extends:❯,precedes:❮
set showbreak=↪
set visualbell " No noise just flash

let $NVIM_TUI_ENABLE_TRUE_COLOR=1 " True color palette
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1 " Cursor based on modes

" Backup
set nobackup
set noswapfile
set autowrite
if has('persistent_undo')
  set undolevels=5000
  set undodir=$HOME/.VIM_UNDO_FILES
  set undofile
endif


" Syntax highlighting
" ===================
filetype on
filetype plugin on
filetype indent on
syntax enable
syntax on

" Command completion
" ==================
set wildmenu
set wildmode=longest,list,full
set wildignore+=build,cache,dist,*.min.*,coverage,node_modules

" Grep
" ====
" http://robots.thoughtbot.com/faster-grepping-in-vim/
set grepprg=ag\ --nogroup\ --nocolor
let g:ag_working_path_mode="r"

" Autoscroll
" ==========
set scrolloff=10
set sidescrolloff=15
set sidescroll=1

" Status Line
" ===========
set laststatus=2

" Autocommands
" ============
" Resize vim on window resize
au VimResized * :wincmd =
" Save when losing focus
au FocusLost * :silent! :wall
" Strip trailing whitespaces
au BufWritePre * :silent :%s/\s\+$//e

" Only show cursorcolumn in the current window and in normal mode.
augroup cline
    au!
    au WinLeave * set nocursorcolumn
    au WinEnter * set cursorcolumn
augroup END

" Visual tweaks
" =============
set cursorcolumn " Highlight the coloumn of the cursor
set number " Display number on the sidebar
set relativenumber
set textwidth=80
set colorcolumn=+1
" set nowrap
set wrap
set linebreak

" Folding
" =======
set foldmethod=indent
set foldnestmax=3
set nofoldenable

" Real programmers don't use TABs but spaces
" ==========================================
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set autoindent
set smartindent
set smarttab

" Search tweaks
" =============
set hlsearch
set incsearch
set ignorecase
set smartcase
set gdefault " Set /g flag regex search

" Mappings
" ========
" Hide search highlights
nmap <silent> <BS>  :nohlsearch<CR>
" Sort lines
nnoremap <leader>s vip:!sort<cr>
vnoremap <leader>s :!sort<cr>
" Easier moving of code blocks
vnoremap < <gv
vnoremap > >gv
" Use jk in insert mode to quickly switch to normal mode
inoremap jk <esc>
" Better navigation
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
" Make y behave like other capitals
map Y y$
" Select all text in current buffer
map <Leader>a ggVG
nnoremap <leader>t :!npm t<CR>

" Commands
" ========
command! JSON :%!python -mjson.tool
command! XML :%!xmllint --format -
command! STANDARD :!standard % --format

" Typo protector lvl: 99999
" =========================
command! -bang -nargs=? -complete=file E e<bang> <args>
command! -bang -nargs=? -complete=file W w<bang> <args>
command! -bang -nargs=? -complete=file Wq wq<bang> <args>
command! -bang -nargs=? -complete=file WQ wq<bang> <args>
command! -bang Wa wa<bang>
command! -bang WA wa<bang>
command! -bang Q q<bang>
command! -bang QA qa<bang>
command! -bang Qa qa<bang>

" Custom functions
" ================

" Adds only to a describe line
function! MochaAddOnly()
    normal ^wi.only^
endfunction

" Removes only from a describe line
function! MochaRemoveOnly()
    normal ^wde^
endfunction

nnoremap <silent> <leader>mo :call MochaAddOnly()<CR>
nnoremap <silent> <leader>md :call MochaRemoveOnly()<CR>

" Colorscheme
" ===========
set t_Co=256
set background=dark
colorscheme gruvbox

" The silver searcher (ACK)
" =========================
nmap <leader>/ :Ag<space>

" Dash
" ====
noremap <leader>d :Dash<CR>

" Limelight
" =========
let g:limelight_default_coefficient=0.7
nmap <leader>f :Limelight!!<cr>

" Fugitive
" ========
set diffopt+=vertical
nnoremap <leader>gd :Gdiff<CR>
nnoremap <leader>gb :Gblame<CR>
nnoremap <leader>gs :Gstatus<CR>

" Gitgutter
" =========
let g:gitgutter_eager=1

" UltiSnips
" =======
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"
let g:UltiSnipsSnippetDirectories=["UltiSnips"]

" Neomake
" =======
let g:neomake_javascript_enabled_makers = ['eslint']
let g:neomake_error_sign = {
            \ 'texthl': 'ErrorMsg',
            \ }
let g:neomake_warning_sign = {
            \ 'texthl': 'ErrorMsg',
            \ }
autocmd! BufWritePost * Neomake

" Fzf
" =======
imap <c-x><c-l> <plug>(fzf-complete-line)
imap <c-x><c-f> <plug>(fzf-complete-path)
let g:fzf_layout = { 'up': '20%' }
nnoremap <C-p> :Files<CR>
nnoremap <leader>b :Buffers<CR>

" Airline
" =======
let g:airline_powerline_fonts = 1
let g:airline_theme = 'gruvbox'

" Let me see that lineNr DROP
highlight LineNr ctermfg=grey ctermbg=white guibg=NONE guifg=#fdf4c1
