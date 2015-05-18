" ============================================================================
" Plugins Setup
" ============================================================================

" Required Vundle setup
filetype off

set rtp+=~/.vim/bundle/vundle/
call vundle#begin()

" Let Vundle manage itself
Plugin 'gmarik/vundle'

" Common plugins
Plugin 'bling/vim-airline'
Plugin 'scrooloose/syntastic'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'mileszs/ack.vim'
Plugin 'tpope/vim-repeat'
Plugin 'Lokaltog/vim-easymotion'

" Markdown
Plugin 'plasticboy/vim-markdown'

" Javascript
Plugin 'pangloss/vim-javascript'
Plugin 'jelera/vim-javascript-syntax'
Plugin 'Raimondi/delimitMate'
Plugin 'moll/vim-node'

" JSX
Plugin 'mxw/vim-jsx'

" Color schemes
Plugin 'chriskempson/base16-vim'
Plugin 'morhetz/gruvbox'
Plugin 'altercation/vim-colors-solarized'
Plugin 'sickill/vim-monokai'
Plugin 'romainl/flattened'
Plugin 'sandeepsinghmails/Dev_Delight'

call vundle#end()

filetype plugin indent on
