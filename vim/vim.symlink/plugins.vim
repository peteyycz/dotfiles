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
Plugin 'scrooloose/syntastic'
Plugin 'kien/ctrlp.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'scrooloose/nerdtree'
Plugin 'Lokaltog/vim-easymotion'
Plugin 'mattn/emmet-vim'
Plugin 'tpope/vim-surround'
Plugin 'scrooloose/nerdcommenter'

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
Plugin 'sickill/vim-monokai'

call vundle#end()

filetype plugin indent on
