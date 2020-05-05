set nocompatible
set viminfo='100,<50,s10,h,n~/.config/nvim/info

source ~/.config/nvim/functions.vim 
py3 from my_snippet_helpers import *
"Plugins
call plug#begin('~/.config/nvim/plugged')
    Plug 'morhetz/gruvbox'
    "Plug 'vim-airline/vim-airline'
    "Plug 'vim-airline/vim-airline-themes'
    Plug 'lervag/vimtex'
    Plug 'SirVer/ultisnips'
    Plug 'pietropate/vim-tex-conceal'
    "Plug 'https://gitlab.com/Dica-Developer/vim-jdb.git'
    Plug 'tpope/vim-fugitive'
    "Plug 'ycm-core/youCompleteMe'
    "Plug 'vim-scripts/OmniCppComplete'
call plug#end()

autocmd BufNewFile,BufRead * 
            \if !exists("b:gradleLoaded") && filereadable("build.gradle") | 
                \source /home/simon/.config/nvim/gradle.vim | 
                \let b:gradleLoaded=1 | 
            \endif

autocmd BufNewFile,BufRead *.alpha 
            \if !exists("b:alphaLoaded") | 
                \source /home/simon/.config/nvim/alpha.vim | 
                \let b:alphaLoaded=1 | 
            \endif

autocmd BufNewFile,BufRead *.py 
            \if !exists("b:pyLoaded") | 
                \source /home/simon/.config/nvim/python.vim | 
                \let b:pyLoaded=1 | 
            \endif

autocmd BufNewFile,BufRead *.xml 
            \if !exists("b:xmlLoaded") | 
                \source /home/simon/.config/nvim/xml.vim | 
                \let b:xmlLoaded=1 | 
            \endif

autocmd BufNewFile,BufRead *.cpp,*.hpp,*.tpp 
            \if !exists("b:cppLoaded") | 
                \source /home/simon/.config/nvim/cpp.vim | 
                \let b:cppLoaded=1 | 
            \endif

autocmd BufNewFile,BufRead CMakeLists.txt 
            \if !exists("b:CMakeListsLoaded") | 
                \source /home/simon/.config/nvim/CMakeLists.txt.vim | 
                \let b:CMakeListsLoaded=1 | 
            \endif

autocmd BufNewFile,BufRead *.java 
            \if !exists("b:javaLoaded") | 
                \source /home/simon/.config/nvim/java.vim | 
                \let b:javaLoaded=1 | 
            \endif

autocmd BufNewFile,BufRead *.vim 
            \if !exists("b:vimLoaded") | 
                \source /home/simon/.config/nvim/vim.vim | 
                \let b:vimLoaded=1 | 
            \endif

autocmd BufWinEnter,WinEnter,TermOpen term://* startinsert | 
            \setlocal nonumber | 
            \setlocal norelativenumber

autocmd BufLeave term://* stopinsert

let w:stFt=""
let w:stFn=""
let w:fpRel=""
autocmd BufWrite,BufRead,WinNew,TermOpen,SourcePost * 
            \let w:stFt=FiletypeClean() |
            \let w:stFn=FilenameClean() |
            \let w:fpRel=FilepathClean() |
            \setlocal statusline=%!Statusline()

autocmd BufWrite,BufRead,TabNew * let g:branches=BranchClean()

autocmd VimEnter * let g:branches=['']

"Style
syntax enable
let g:gruvbox_italic=1
set background=dark
colorscheme gruvbox

"on kitty, fixes Backlight bleed
let &t_ut=''

""airline
"let g:airline_powerline_fonts=1
"let g:airline_theme='gruvbox'
"let g:airline#extensions#tabline#enabled = 1
"let g:airline#extensions#tabline#tab_nr_type = 1
"let g:airline#extensions#tabline#show_splits = 1
"let g:airline#extensions#tabline#show_buffers = 0
"let g:airline#extensions#tabline#exclude_preview = 1
"let g:airline#extensions#tabline#show_close_button = 0
"let g:airline#extensions#tabline#show_splits = 0
"let g:airline#extensions#tabline#show_tab_count = 0

"Statusline
hi StatusLine ctermbg=239 ctermfg=239 cterm=inverse
hi StatusLineNC ctermbg=237 ctermfg=239 cterm=inverse

hi StatusLineTerm ctermbg=239 ctermfg=239 cterm=inverse
hi StatusLineTermNC ctermbg=237 ctermfg=239 cterm=inverse

hi User1 ctermbg=239 ctermfg=255

"Tabline
hi TabLine ctermbg=235 ctermfg=245 cterm=none
hi TabLineSel ctermbg=235 ctermfg=229 cterm=none

set laststatus=2
set showtabline=2

let g:branches=BranchClean()
set tabline=%!MyTabLine()
    
"Searching
set hlsearch
set incsearch
set showmatch 

"Tabstops
set tabstop=4
set softtabstop=4
set expandtab
set shiftwidth=4
set autoindent
set nocindent

"Misc
set relativenumber
set number
set numberwidth=2
set wildmode=longest,list
set lazyredraw
set mouse=v
set splitbelow
set splitright
set switchbuf+=useopen
set noequalalways

"Ultisnips
let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"
let g:UltiSnipsExpandTrigger="<Tab>"
let g:UltiSnipsJumpForwardTrigger="<Tab>"
let g:UltiSnipsSnippetDirectories=["mySnippets"]
let g:UltiSnipsSnippetsDir="/home/simon/.config/nvim/mySnippets"

"VimTex
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

"Keymappings
let mapleader=","
let maplocalleader=";"

noremap <silent> <Leader>a <C-A>
noremap <silent> <Leader>x <C-X>
noremap <silent> <C-v> :vsp<CR>
noremap <silent> <C-b> :sp<CR>
noremap <silent> <C-x> :q!<CR>

nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

noremap <silent> <F11> :vnew<Cr>:term<Cr>
noremap <silent> <F23> :new<Cr>:term<Cr>

nnoremap <silent> <F9> :vert res +2<Cr>
nnoremap <silent> <F21> :vert res -2<CR>
nnoremap <silent> <F10> :res +2<CR>
nnoremap <silent> <F22> :res -2<CR>

nnoremap <silent> <Leader>ev :tabedit $MYVIMRC<CR>
nnoremap <silent> <Leader>sv :source $MYVIMRC<CR>

nnoremap <silent> <Leader>l <Esc>viwu<Esc>e
nnoremap <silent> <Leader>u <Esc>viwU<Esc>e

nnoremap <silent> gb :ls<CR>:b<Space> 

inoremap <C-C> <Esc>g~iwea
inoremap <C-U> <Esc>viwU<Esc>ea
inoremap <C-L> <Esc>viwu<Esc>ea

inoremap <C-F> <C-X><C-F>

tnoremap <C-J> <C-\><C-N><C-w>j
tnoremap <C-K> <C-\><C-N><C-w>k
tnoremap <C-L> <C-\><C-N><C-w>l
tnoremap <C-H> <C-\><C-N><C-w>h

tnoremap <C-W> <C-\><C-N><C-w>

tnoremap <C-N> <C-\><C-N>
tnoremap <C-X> <C-\><C-N>:q!<Cr>

tnoremap <silent> <F9> <C-\><C-N>:vert res +2<Cr>a
tnoremap <silent> <F21> <C-\><C-N>:vert res -2<CR>a
tnoremap <silent> <F10> <C-\><C-N>:res +2<CR>a
tnoremap <silent> <F22> <C-\><C-N>:res -2<CR>a

cabbr <expr> && expand('%:h')
