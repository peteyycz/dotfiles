" ============================================================================
" Plugins Setup
" ============================================================================

call plug#begin('~/.nvim/plugged')

" Can't live without colors
Plug 'chriskempson/base16-vim'
" Plug 'w0ng/vim-hybrid'
" Plug  'altercation/vim-colors-solarized'
" Plug 'tomasr/molokai'
" Plug 'Lokaltog/vim-distinguished'
" Plug 'tpope/vim-vividchalk'
" Plug 'chriskempson/tomorrow-theme', {'rtp': 'vim'}
" Plug 'rainux/vim-desert-warm-256'
" Plug 'nanotech/jellybeans.vim'
" Plug 'junegunn/seoul256.vim'
" Plug 'vim-scripts/wombat256.vim'

" Shiny sword that breaks sometimes
" Plug 'Shougo/unite.vim'
" Plug 'Shougo/vimproc', { 'do': 'make' }

" Snippets
" Plug 'SirVer/ultisnips'
" Plug 'honza/vim-snippets'

" Code checker
Plug 'scrooloose/syntastic'

" Rainbox parentheses
Plug 'oblitum/rainbow'

" File explorer
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'ctrlpvim/ctrlp.vim'

" Statusline
Plug 'edkolev/tmuxline.vim'

" The silver searcher AKA grep
Plug 'mileszs/ack.vim'

" Better commenting
Plug 'scrooloose/nerdcommenter'

" Focusing tool
Plug 'junegunn/limelight.vim', { 'on': 'Limelight' }

" Git lines
Plug 'airblade/vim-gitgutter'

" Pair parentheses
Plug 'Raimondi/delimitMate'

" Better tab completion
Plug 'ervandew/supertab'

" Dash documentation tool
Plug 'rizzatti/dash.vim'

" ??
Plug 'sickill/vim-pasta'

" Text objects
Plug 'tpope/vim-surround'
Plug 'tpope/vim-repeat'

" Language specific
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'jelera/vim-javascript-syntax', { 'for': 'javascript' }
Plug 'mxw/vim-jsx', { 'for': 'jsx' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'leafgarland/typescript-vim', { 'for': 'typescript' }
Plug 'juvenn/mustache.vim', { 'for': 'mustache' }
Plug 'digitaltoad/vim-jade', { 'for': 'jade' }
Plug 'cakebaker/scss-syntax.vim', { 'for': 'scss' }
Plug 'wavded/vim-stylus', { 'for': ['stylus', 'markdown'] }
Plug 'groenewege/vim-less', { 'for': 'less' }
Plug 'ap/vim-css-color', { 'for': 'css' }
Plug 'hail2u/vim-css3-syntax', { 'for': 'css' }
Plug 'tpope/vim-markdown', { 'for': 'markdown' }
Plug 'fatih/vim-go', { 'for': 'go' }

call plug#end()

