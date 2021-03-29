set nocompatible
set viminfo='100,<50,s10,h,n~/.config/nvim/info

source ~/.config/nvim/functions.vim 

"Plugins
call plug#begin('~/.config/nvim/plugged')
    Plug 'cespare/vim-toml'
    Plug 'jackguo380/vim-lsp-cxx-highlight',
    Plug 'lervag/vimtex', {'for' : 'latex'}
    Plug 'morhetz/gruvbox'
    Plug 'pietropate/vim-tex-conceal', {'for' : 'latex'}
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-fugitive'
    Plug 'vim-scripts/DoxygenToolkit.vim', {'for' : 'cpp'}

    Plug 'neovim/nvim-lspconfig'
    Plug 'anott03/nvim-lspinstall'
	Plug 'hrsh7th/nvim-compe'
	Plug '/home/simon/.config/nvim/plugged/luasnip-dev/'
    "Plug 'norcalli/snippets.nvim'
    "Plug 'nvim-lua/completion-nvim'
	"Plug 'norcalli/snippets.nvim'
	"Plug 'phazoon/hop.nvim'
	"Plug 'hrsh7th/vim-vsnip'
	"Plug 'hrsh7th/vim-vsnip-integ'
    "Plug 'nvim-lua/lsp_extensions.nvim'
	"Plug 'rust-lang/rust.vim'
    "Plug 'SirVer/ultisnips'
    "Plug 'https://gitlab.com/Dica-Developer/vim-jdb.git'
    "Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
    "Plug 'neovim/nvim-lsp'
    "Plug 'peterhoeg/vim-qml'
    "Plug 'vim-airline/vim-airline'
    "Plug 'vim-airline/vim-airline-themes'
    "Plug 'vim-scripts/OmniCppComplete'
    "Plug 'ycm-core/youCompleteMe'
    "Plug 'yous/vim-open-color'
call plug#end()

autocmd bufnewfile,bufread *.h set filetype=c
autocmd bufnewfile,bufread * 
            \if !exists("b:gradleloaded") && filereadable("build.gradle") |
                \source /home/simon/.config/nvim/gradle.vim |
                \let b:gradleloaded=1 |
            \endif

"augroup CompletionTriggerCharacter
"    autocmd!
"    autocmd BufEnter * let g:completion_trigger_character = ['.']
"    autocmd BufEnter *.c,*.cpp,*.rs let g:completion_trigger_character = ['.', '::']
"augroup end

autocmd BufNewFile,BufRead * 
            \if !exists("b:cmakeLoaded") && filereadable("CMakeLists.txt") |
                \source /home/simon/.config/nvim/cmake.vim |
                \let b:cmakeLoaded=1 |
            \endif

autocmd BufNewFile,BufRead * 
            \if !exists("b:makeLoaded") && (filereadable("makefile") || filereadable("Makefile") ) |
                \source /home/simon/.config/nvim/make.vim |
                \let b:makeLoaded=1 |
            \endif

autocmd BufNewFile,BufRead * 
            \if !exists("b:cargoLoaded") && filereadable("Cargo.toml") |
                \source /home/simon/.config/nvim/cargo.vim |
                \let b:cargoLoaded=1 |
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

set fillchars=fold:\ ,vert:\|
set foldtext=MyFoldText()

"Style
syntax enable
let g:gruvbox_italic='1'
let g:gruvbox_contrast_dark='hard'
set background=dark
colorscheme gruvbox

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

"Tabline
hi TabLine ctermbg=0 ctermfg=245 cterm=none
hi TabLineSel ctermbg=0 ctermfg=229 cterm=none

"Statusline
hi Status1 ctermbg=11 ctermfg=0 cterm=bold
hi Status2 ctermbg=208 ctermfg=0 cterm=bold
hi Status3 ctermbg=109 ctermfg=0 cterm=bold

hi User1 ctermbg=237 ctermfg=0

hi StatusLine ctermbg=237 ctermfg=0
hi StatusLineNC ctermbg=235 ctermfg=0

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

"lsp
"set completeopt=menuone,noinsert,noselect
set shortmess+=c

hi link LspDiagnosticsVirtualTextError CocErrorSign
hi link LspDiagnosticsVirtualTextWarning CocWarningSign
hi link LspDiagnosticsVirtualTextInformation CocInfoSign
hi link LspDiagnosticsVirtualTextHint CocHintSign

hi link LspDiagnosticsSignError CocErrorSign
hi link LspDiagnosticsSignWarning CocWarningSign
hi link LspDiagnosticsSignInformation CocInfoSign
hi link LspDiagnosticsSignHint CocHintSign

sign define LspDiagnosticsSignError text=» texthl=LspDiagnosticsSignError linehl= numhl=
sign define LspDiagnosticsSignWarning text=» texthl=LspDiagnosticsSignWarning linehl= numhl=
sign define LspDiagnosticsSignInformation text=» texthl=LspDiagnosticsSignInformation linehl= numhl=
sign define LspDiagnosticsSignHint text=» texthl=LspDiagnosticsSignHint linehl= numhl=

lua require('init')
lua ls = require('luasnip')
set completeopt=menuone

"inoremap <Tab> <cmd>lua return require'snippets'.expand_or_advance(1)<CR>
"inoremap <S-Tab> <cmd>lua return require'snippets'.advance_snippet(-1)<CR>


let g:vsnip_snippet_dir = '/home/simon/.config/nvim/vsnip/'

smap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'
imap <expr> <Tab>   vsnip#available(1)  ? '<Plug>(vsnip-expand-or-jump)' : '<Tab>'

imap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'
smap <expr> <S-Tab> vsnip#jumpable(-1)  ? '<Plug>(vsnip-jump-prev)'      : '<S-Tab>'

inoremap <silent><expr> <C-X><C-O> compe#complete()
inoremap <silent><expr> <C-Y>      compe#confirm('<CR>')

imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
inoremap <silent> <S-Tab> <cmd>lua ls.jump(-1)<Cr>

imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'

snoremap <silent> <Tab> <cmd>lua ls.jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua ls.jump(-1)<Cr>

"cannot set in lua or stupid
"let g:completion_confirm_key = "\<C-y>"
"imap <silent> <C-X><C-O> <Plug>(completion_trigger)

"Ultisnips
"let g:UltiSnipsJumpBackwardTrigger="<S-Tab>"
"let g:UltiSnipsExpandTrigger="<Tab>"
"let g:UltiSnipsJumpForwardTrigger="<Tab>"
"let g:UltiSnipsSnippetDirectories=['mySnippets']

"let g:coc_snippet_next = '<tab>'
"let g:coc_snippet_prev = '<S-Tab>'
"xmap <Tab> <Plug>(coc-snippets-select)
"
"inoremap <silent><expr> <TAB>
"  \ coc#expandableOrJumpable() ?
"  \ "\<C-r>=coc#rpc#request('doKeymap', ['snippets-expand-jump',''])\<CR>" :
"  \ "\<TAB>"
"
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

if filereadable('.vProj.vim')
    source .vProj.vim
endif
