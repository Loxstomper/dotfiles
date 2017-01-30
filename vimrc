" COLOURS
set t_Co=256
set background=dark
color solarized 
syntax on

execute pathogen#infect()
filetype plugin indent on

" NERDTree
autocmd VimEnter * wincmd p

" CTRL-P
set runtimepath^=~/.vim/bundle/ctrlp.vim
let g:ctrlp_map = '<c-p>'
let g:ctrlp_cmd = 'CtrlP'
let g:ctrlp_working_path_mode = 'a'
let g:ctrlp_user_command = ['.git', 'cd %s && git ls-files -co --exclude-standard']

" Syntastic
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

" ME
set colorcolumn=110
set number
set rnu
set tabstop=4
set softtabstop=4
set expandtab
set cursorline
set lazyredraw
set showmatch

set incsearch
set hlsearch 

set foldenable
set foldlevelstart=99
set foldnestmax=10
set foldmethod=indent

autocmd InsertEnter * :set norelativenumber
autocmd InsertLeave * :set rnu 

" MAPS
let mapleader=','
map <S-h> <Home>
map <S-l> <End>
nnoremap <CR> :noh<CR><CR>
nnoremap <space> za
map <C-j> <C-W>j
map <C-k> <C-W>k
map <C-h> <C-W>h
map <C-l> <C-W>l
map <up> <nop>
map <down> <nop>
map <Leader>t :NERDTreeToggle<CR>
map <Leader>w :w <CR>
map <Leader>q :q!<CR>
map <Leader>wq :wq<CR>

" MACROS
map cfl ifor(int i = 0; i < ; i ++)<CR>{<CR><esc>kk19li
