" ============================================================================
" Plugins Setup
" ============================================================================

call plug#begin('~/.nvim/plugged')

" Can't live without colors
Plug 'chriskempson/base16-vim'

" Common plugins
Plug 'scrooloose/syntastic'
Plug 'ervandew/supertab'
Plug 'Raimondi/delimitMate'
Plug 'scrooloose/nerdcommenter'
Plug 'airblade/vim-gitgutter'
Plug 'kien/ctrlp.vim'
Plug 'rizzatti/dash.vim'
Plug 'mileszs/ack.vim'
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] } | Plug 'Xuyuanp/nerdtree-git-plugin' | Plug 'ryanoasis/vim-devicons'
Plug 'editorconfig/editorconfig-vim'
Plug 'sickill/vim-pasta'
Plug 'junegunn/goyo.vim', { 'on': 'Goyo' } " distraction-free writing
Plug 'junegunn/limelight.vim', { 'on': 'Limelight' } " focus tool. Good for presentating with vim

" Language specific
Plug 'mattn/emmet-vim', { 'for': 'html' }
Plug 'othree/html5.vim', { 'for': 'html' }
Plug 'pangloss/vim-javascript', { 'for': 'javascript' }
Plug 'moll/vim-node', { 'for': 'javascript' }
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

" Syntastic settings
let g:syntastic_javascript_checkers = ['jshint']
let g:syntastic_check_on_open=1
let g:syntastic_warning_symbol = '⚠'
let g:syntastic_error_symbol = '⚠'
let g:syntastic_style_error_symbol = '⚠'
let g:syntastic_always_populate_loc_list = 1
let g:syntastic_loc_list_height = 5
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_wq = 0
highlight SyntasticErrorSign ctermfg=red ctermbg=237
highlight SyntasticWarningSign ctermfg=yellow ctermbg=237
highlight SyntasticStyleErrorSign ctermfg=red ctermbg=237
highlight SyntasticStyleWarningSign ctermfg=yellow ctermbg=237

" NERDTree
map <leader>m :NERDTreeToggle<CR>

" Use JSHintrc defined in the project
function s:find_jshintrc(dir)
    let l:found = globpath(a:dir, '.jshintrc')
    if filereadable(l:found)
        return l:found
    endif

    let l:parent = fnamemodify(a:dir, ':h')
    if l:parent != a:dir
        return s:find_jshintrc(l:parent)
    endif

    return "~/.jshintrc"
endfunction

function UpdateJsHintConf()
    let l:dir = expand('%:p:h')
    let l:jshintrc = s:find_jshintrc(l:dir)
    let g:syntastic_javascript_jshint_args = ("--config " . l:jshintrc)
endfunction

au BufEnter * call UpdateJsHintConf()

" Ctrl+P settings
let g:ctrlp_custom_ignore = 'node_modules\|DS_Store\|git\|coverage'
"let g:ctrlp_match_window_bottom = 0
"let g:ctrlp_match_window_reversed = 0

" The silver searcher
if executable('ag')
  let g:ackprg = 'ag --vimgrep'
endif

" Dash settings
nnoremap <leader>d :Dash<CR>
vnoremap <leader>d :Dash<CR>

" Strip trailing whitespaces
autocmd BufWritePre * :silent :%s/\s\+$//e

" Limelight
nmap <leader>f :Limelight!!<cr>

" don't hide quotes in json files
let g:vim_json_syntax_conceal = 0

" Colorscheme setttings
let base16colorspace=256
set t_Co=256
execute "set background=". $BACKGROUND
execute "colorscheme ". $THEME


