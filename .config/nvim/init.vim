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
    "Plug 'SirVer/ultisnips'
    Plug 'pietropate/vim-tex-conceal'
    Plug 'neoclide/coc.nvim'
    Plug 'jackguo380/vim-lsp-cxx-highlight'
    Plug 'puremourning/vimspector'
    "Plug 'https://gitlab.com/Dica-Developer/vim-jdb.git'
    Plug 'tpope/vim-fugitive'
    "Plug 'ycm-core/youCompleteMe'
    "Plug 'vim-scripts/OmniCppComplete'
    "Plug 'neovim/nvim-lsp'
    Plug 'vim-scripts/DoxygenToolkit.vim'
call plug#end()

autocmd BufNewFile,BufRead * 
            \if !exists("b:gradleLoaded") && filereadable("build.gradle") |
                \source /home/simon/.config/nvim/gradle.vim |
                \let b:gradleLoaded=1 |
            \endif

autocmd BufNewFile,BufRead * 
            \if !exists("b:cmakeLoaded") && filereadable("CMakeLists.txt") |
                \source /home/simon/.config/nvim/cmake.vim |
                \let b:cmakeLoaded=1 |
            \endif

autocmd BufWinEnter,WinEnter,TermOpen term://* startinsert | 
            \setlocal nonumber | 
            \setlocal norelativenumber

autocmd BufNewFile,BufRead *.sc set ft=cpp

autocmd BufLeave term://* stopinsert

let w:stFt=""
let w:stFn=""
let w:fpRel=""
"add WinEnter for floating windows.
"BufEnter for <C-O>/<C-I>
autocmd BufRead,WinNew,TermOpen,SourcePost,WinEnter,BufEnter * 
            \let w:stFt=FiletypeClean() |
            \let w:stFn=FilenameClean() |
            \let w:fpRel=FilepathClean() |
            \setlocal statusline=%!Statusline()

autocmd BufWrite,BufRead,TabNew * let g:branches=BranchClean()

autocmd VimEnter * let g:branches=['']

setlocal foldtext=MyFoldText()

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
set noexpandtab
set softtabstop=4
set shiftwidth=4
set autoindent
set nocindent
set copyindent

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

"Ultisnips
"let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"
"let g:UltiSnipsExpandTrigger="<Tab>"
"let g:UltiSnipsJumpForwardTrigger="<Tab>"
"let g:UltiSnipsSnippetDirectories=['mySnippets']

let g:coc_snippet_next = '<tab>'
let g:coc_snippet_prev = '<S-Tab>'
xmap <Tab> <Plug>(coc-snippets-select)

inoremap <silent><expr> <TAB>
  \ pumvisible() ? coc#_select_confirm() :
  \ coc#expandableOrJumpable() ?
  \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
  \ <SID>check_back_space() ? "\<TAB>" :
  \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

"VimTex
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
let g:vimtex_quickfix_mode=0
set conceallevel=1
let g:tex_conceal='abdmg'

"Keymappings
let mapleader=","
let maplocalleader="\<Space>"

"Vimspector
nnoremap <F2> :call vimspector#ToggleBreakpoint()<Cr>
nnoremap <F3> :call vimspector#StepOver()<Cr>
nnoremap <F4> :call vimspector#StepInto()<Cr>
nnoremap <F5> :call vimspector#Continue()<Cr>

"Other
noremap <silent> <C-v> :vsp<Cr>
noremap <silent> <C-b> :sp<Cr>

nnoremap <leader>n :noh<Cr>

"end on closig paranthesis.
vnoremap <leader>( <Esc>`>a)<Esc>`<i(<Esc>%
vnoremap <leader>{ <Esc>`>a}<Esc>`<i{<Esc>%
vnoremap <leader>[ <Esc>`>a]<Esc>`<i[<Esc>%
vnoremap <leader>" <Esc>`>a"<Esc>`<i"<Esc>%
vnoremap <leader>' <Esc>`>a'<Esc>`<i'<Esc>%
vnoremap <leader><Space> <Esc>`>a <Esc>`<i <Esc>%

vnoremap <leader>c <Esc>`>a*/<Esc>`<i/*<Esc>
nnoremap <leader>uc ?\/\*<Cr>2x/*/\/<Cr>2x

" Search for selected text, forwards or backwards.
vnoremap <silent> * :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy/<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '/\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>
vnoremap <silent> # :<C-U>
  \let old_reg=getreg('"')<Bar>let old_regtype=getregtype('"')<CR>
  \gvy?<C-R>=&ic?'\c':'\C'<CR><C-R><C-R>=substitute(
  \escape(@", '?\.*$^~['), '\_s\+', '\\_s\\+', 'g')<CR><CR>
  \gVzv:call setreg('"', old_reg, old_regtype)<CR>

nnoremap <leader>( viw<Esc>`>a)<Esc>`<i(<Esc>%
nnoremap <leader>{ viw<Esc>`>a}<Esc>`<i{<Esc>%
nnoremap <leader>[ viw<Esc>`>a]<Esc>`<i[<Esc>%
nnoremap <leader>" viw<Esc>`>a"<Esc>`<i"<Esc>%
nnoremap <leader>' viw<Esc>`>a'<Esc>`<i'<Esc>%
nnoremap <leader>' viw<Esc>`>a <Esc>`<i <Esc>%

nnoremap <C-H> <C-W><C-H>
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>

noremap <silent> <F11> :vnew<Cr>:term<Cr>
noremap <silent> <F23> :new<Cr>:term<Cr>

nnoremap <silent> <F9> :vert res +2<Cr>
nnoremap <silent> <F21> :vert res -2<Cr>
nnoremap <silent> <F10> :res +2<Cr>
nnoremap <silent> <F22> :res -2<Cr>

nnoremap <silent> <leader>ev :tabedit $MYVIMRC<Cr>
nnoremap <silent> <leader>sv :source $MYVIMRC<Cr>

nnoremap <silent> <leader>l viwue
nnoremap <silent> <leader>u viwUe

nnoremap <silent> <leader>pa :call ParanAdd()<Cr>

nnoremap <silent> gb :ls<Cr>:b<Space> 
nnoremap <leader>e :e <C-R>=t:srcDir<Cr>/<C-D>

nnoremap [[ ?{\n<Cr>:noh<Cr>
nnoremap ][ /{\n<Cr>:noh<Cr>
nnoremap ]] /}\n<Cr>:noh<Cr>
nnoremap [] ?}\n<Cr>:noh<Cr>

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

tnoremap <silent> <F9> <C-\><C-N>:vert res +2<Cr>a
tnoremap <silent> <F21> <C-\><C-N>:vert res -2<Cr>a
tnoremap <silent> <F10> <C-\><C-N>:res +2<Cr>a
tnoremap <silent> <F22> <C-\><C-N>:res -2<Cr>a

cabbr <expr> && expand('%:h')
