set nocompatible
set viminfo='100,<50,s10,h,n~/.config/nvim/info

source ~/.config/nvim/functions.vim 

"Plugins
call plug#begin('~/.config/nvim/plugged')
    Plug 'gruvbox-community/gruvbox'
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-fugitive'
    Plug 'neovim/nvim-lspconfig'
    Plug 'kabouzeid/nvim-lspinstall', {'branch' : 'main'}
    Plug 'RRethy/vim-illuminate'

	Plug 'hrsh7th/nvim-cmp', {'branch' : 'main'} 
	Plug 'hrsh7th/cmp-nvim-lsp', {'branch' : 'main'} 
	Plug 'saadparwaiz1/cmp_luasnip', {'branch' : 'master'} 

	Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
	Plug 'nvim-treesitter/nvim-treesitter-textobjects'

	Plug 'phaazon/hop.nvim'
	Plug 'tikhomirov/vim-glsl'	
	"Plug 'folke/lsp-trouble.nvim', {'branch' : 'main'}
	Plug 'mfussenegger/nvim-dap'
	Plug 'rcarriga/nvim-dap-ui'
	Plug 'rafamadriz/friendly-snippets', {'branch' : 'main'}
	"Plug 'nvim-telescope/telescope.nvim'
	Plug 'nvim-lua/popup.nvim'
	Plug 'nvim-lua/plenary.nvim'
	"Plug 'nvim-treesitter/playground'

	"Plug 'leiserfg/luasnip', {'branch' : 'use-named-register'}
	Plug '/home/simon/.config/nvim/plugged/luasnip-dev/' "luasnip-dev-plug
	Plug 'knsh14/vim-github-link'
	Plug 'hoob3rt/lualine.nvim'

    "Plug 'cespare/vim-toml'
    "Plug 'lervag/vimtex', {'for' : 'latex'}
    "Plug 'pietropate/vim-tex-conceal', {'for' : 'latex'}
    "Plug 'vim-scripts/DoxygenToolkit.vim', {'for' : 'cpp'}
	"Plug 'nvim-lua/lsp_extensions.nvim'
    "Plug 'norcalli/snippets.nvim'
    "Plug 'nvim-lua/completion-nvim'
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

augroup mine
au!

"autocmd mine bufnewfile,bufread *.h set filetype=c
" autocmd mine bufnewfile,bufread * 
"             \if !exists("b:gradleLoaded") && filereadable("build.gradle") |
"                 \source /home/simon/.config/nvim/gradle.vim |
"                 \let b:gradleLoaded=1 |
"             \endif
" 
" autocmd mine BufNewFile,BufRead * 
"             \if !exists("b:cmakeLoaded") && filereadable("CMakeLists.txt") |
"                 \source /home/simon/.config/nvim/cmake.vim |
"                 \let b:cmakeLoaded=1 |
"             \endif
" 
" autocmd mine BufNewFile,BufRead * 
"             \if !exists("b:makeLoaded") && (filereadable("makefile") || filereadable("Makefile") ) |
"                 \source /home/simon/.config/nvim/make.vim |
"                 \let b:makeLoaded=1 |
"             \endif
" 
" autocmd mine BufNewFile,BufRead * 
"             \if !exists("b:cargoLoaded") && filereadable("Cargo.toml") |
"                 \source /home/simon/.config/nvim/cargo.vim |
"                 \let b:cargoLoaded=1 |
"             \endif

autocmd mine BufWinEnter,WinEnter,TermOpen term://* startinsert | 
            \setlocal nonumber | 
            \setlocal norelativenumber |
			\setlocal ft=term

autocmd mine BufLeave term://* stopinsert

let w:stFt=""
let w:stFn=""
let w:fpRel=""
"add WinEnter for floating windows.
"BufEnter for <C-O>/<C-I>
autocmd mine BufRead,WinNew,TermOpen,SourcePost,WinEnter,BufEnter * 
            \let w:stFt=FiletypeClean() |
            \let w:stFn=FilenameClean() |
            \let w:fpRel=FilepathClean() |
            \setlocal statusline=%!Statusline()

autocmd mine FileType * 
            \let w:stFt=FiletypeClean() |
            \setlocal statusline=%!Statusline()

autocmd mine BufWrite,BufRead,TabNew * let g:branches=BranchClean()

autocmd mine VimEnter * let g:branches=['']

autocmd mine TextYankPost * silent! lua vim.highlight.on_yank{on_visual=false, higroup="Visual"}

augroup END

set fillchars=fold:\ ,vert:\|
set foldtext=MyFoldText()

"Style
syntax on
let g:gruvbox_italic='1'
let g:gruvbox_contrast_dark='hard'
let g:gruvbox_sign_column='bg0'
let g:gruvbox_invert_selection=0
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
hi TabLine ctermbg=0 ctermfg=239 cterm=none
hi TabLineSel ctermbg=0 ctermfg=229 cterm=none

"Statusline
hi Status1 ctermbg=11 ctermfg=0 cterm=bold
hi Status2 ctermbg=208 ctermfg=0 cterm=bold
hi Status3 ctermbg=109 ctermfg=0 cterm=bold

hi User1 ctermbg=237 ctermfg=0

hi StatusLine ctermbg=237 ctermfg=0
hi StatusLineNC ctermbg=235 ctermfg=0

hi Folded ctermbg=0 cterm=none

hi link LspReferenceText CursorLine
hi link LspReferenceRead CursorLine
hi link LspReferenceWrite CursorLine

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

set listchars+=tab:→\ ,trail:␣,space:·

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
set virtualedit=block

set signcolumn=auto
set updatetime=1000

"lsp
"set completeopt=menuone,noinsert,noselect
set shortmess+=c

"hi link LspDiagnosticsVirtualTextError CocErrorSign
"hi link LspDiagnosticsVirtualTextWarning CocWarningSign
"hi link LspDiagnosticsVirtualTextInformation CocInfoSign
"hi link LspDiagnosticsVirtualTextHint CocHintSign
"
"hi link LspDiagnosticsDefaultError Error
"hi link LspDiagnosticsDefaultWarning Warning
"hi link LspDiagnosticsDefaultInformation Info
"hi link LspDiagnosticsDefaultHint Hint
"
"hi link LspDiagnosticsSignError CocErrorSign
"hi link LspDiagnosticsSignWarning CocWarningSign
"hi link LspDiagnosticsSignInformation CocInfoSign
"hi link LspDiagnosticsSignHint CocHintSign

hi link HopNextKey GruvboxRedBold
hi link HopNextKey1 GruvboxBlueBold
hi link HopNextKey2 GruvboxBlue
hi link HopUnmatched NonText


hi! link DiagnosticDefaultError GruvboxRed
hi! link DiagnosticSignError GruvboxRedSign
hi! link DiagnosticUnderlineError GruvboxRedUnderline
hi! link DiagnosticVirtualTextError DiagnosticDefaultError
hi! link DiagnosticFloatingError DiagnosticDefaultError

hi! link DiagnosticDefaultWarn GruvboxYellow
hi! link DiagnosticSignWarn GruvboxYellowSign
hi! link DiagnosticUnderlineWarn GruvboxYellowUnderline
hi! link DiagnosticVirtualTextWarn DiagnosticDefaultWarn
hi! link DiagnosticFloatingWarn DiagnosticDefaultWarn

hi! link DiagnosticDefaultInfo GruvboxBlue
hi! link DiagnosticSignInfo GruvboxBlueSign
hi! link DiagnosticUnderlineInfo GruvboxBlueUnderline
hi! link DiagnosticVirtualTextInfo DiagnosticDefaultInfo
hi! link DiagnosticFloatingInfo DiagnosticDefaultInfo

hi! link DiagnosticDefaultHint GruvboxAqua
hi! link DiagnosticSignHint GruvboxAquaSign
hi! link DiagnosticUnderlineHint GruvboxAquaUnderline
hi! link DiagnosticVirtualTextHint DiagnosticDefaultHint
hi! link DiagnosticFloatingHint DiagnosticDefaultHint

sign define DiagnosticSignError text= texthl=DiagnosticSignError linehl= numhl=
sign define DiagnosticSignWarn text= texthl=DiagnosticSignWarn linehl= numhl=
sign define DiagnosticSignInfo text= texthl=DiagnosticSignInfo linehl= numhl=
sign define DiagnosticSignHint text= texthl=DiagnosticSignHint linehl= numhl=

lua require('init')
lua ls = require('luasnip')
lua hop = require('hop')
set completeopt=menuone
"inoremap <Tab> <cmd>lua return require'snippets'.expand_or_advance(1)<CR>
"inoremap <S-Tab> <cmd>lua return require'snippets'.advance_snippet(-1)<CR>

imap <silent><expr> <Tab> luasnip#expand_or_jumpable() ? '<Plug>luasnip-expand-or-jump' : '<Tab>'
inoremap <silent> <S-Tab> <cmd>lua ls.jump(-1)<Cr>

imap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''
smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : ''

imap <silent><expr> <C-T> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : ''
smap <silent><expr> <C-T> luasnip#choice_active() ? '<Plug>luasnip-prev-choice' : ''

snoremap <silent> <Tab> <cmd>lua ls.jump(1)<Cr>
snoremap <silent> <S-Tab> <cmd>lua ls.jump(-1)<Cr>

nnoremap <silent> \ <cmd>lua hop.hint_words()<Cr>
nnoremap <silent> \| <cmd>lua hop.hint_char1()<Cr>

let g:Illuminate_delay = 800

"cannot set in lua or stupid
"let g:completion_confirm_key = "\<C-y>"
"imap <silent> <C-I> <Plug>(completion_trigger)

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
set conceallevel=2
let g:tex_conceal='abdmgs'

"Keymappings
let mapleader=","
let maplocalleader="\<Space>"

"Vimspector
"nnoremap <F2> :call vimspector#ToggleBreakpoint()<Cr>
"nnoremap <F3> :call vimspector#StepOver()<Cr>
"nnoremap <F4> :call vimspector#StepInto()<Cr>
"nnoremap <F5> :call vimspector#Continue()<Cr>
" nvim-dap
noremap <F2> :lua require"dap".toggle_breakpoint()<Cr>
" S-F2
noremap <F14> :lua require"dap".set_breakpoint(vim.fn.input("Breakpoint condition: "))<CR>
noremap <F18> :lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))<CR>
noremap <F3> :lua require"dap".step_over()<Cr>
noremap <F4> :lua require"dap".step_into()<Cr>
noremap <F16> :lua require"dap".step_out()<Cr>
noremap <F5> :lua require"dap".continue()<Cr>
noremap <F17> :lua require"dap".run_last()<Cr>
noremap <F6> :lua require"dap.ui.variables".hover()<Cr>
noremap <leader>dws :lua require"dapui".open("sidebar")<Cr>

"Other
noremap <silent> <C-v> :vsp<Cr>
noremap <silent> <C-b> :sp<Cr>

noremap <leader>n :noh<Cr>
noremap <silent> <leader>l :set invlist<Cr>
noremap <silent> <leader>r :set invrelativenumber<Cr>
noremap <silent> <leader>t :tabedit ~/.todo<Cr>
noremap <silent> <leader>fw :set invwinfixwidth<Cr>
noremap <silent> <leader>fh :set invwinfixheight<Cr>

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

nnoremap <silent> <leader>ev :tabedit $MYVIMRC<Cr>:exe 'tcd'.expand('%:h')<Cr>
nnoremap <silent> <leader>sv :source $MYVIMRC<Cr>

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
