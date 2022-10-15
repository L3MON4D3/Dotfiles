set nocompatible
set viminfo='100,<50,s10,h,n~/.config/nvim/info
set noswapfile

"let g:did_load_filetypes=1

source ~/.config/nvim/functions.vim 

augroup packer_user_config
  autocmd!
  autocmd BufWritePost ~/.config/nvim/lua/plugins/init.lua source <afile> | PackerCompile
augroup end

augroup mine
au!

let g:neovide_cursor_animation_length = 0
set guifont=iosevka:h11.5
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

" autocmd mine TermOpen term://* startinsert |
" 			\setlocal nonumber | 
"             \setlocal norelativenumber |
" 			\setlocal ft=term

"autocmd mine BufWinEnter,WinEnter term://* startinsert
"autocmd mine BufLeave term://* stopinsert

" augroup autoquickfix
"     autocmd!
"     autocmd QuickFixCmdPost [^l]* cwindow
"     autocmd QuickFixCmdPost    l* lwindow
" augroup END

let w:stFt=""
let w:stFn=""
let w:fpRel=""
"add WinEnter for floating windows.
"BufEnter for <C-O>/<C-I>
autocmd mine QuickFixCmdPost,BufRead,WinNew,TermOpen,SourcePost,WinEnter,BufWinEnter * 
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

set fillchars=fold:\ ,vert:│
" set foldtext=MyFoldText()
set foldmethod=manual
set foldminlines=1

set grepprg=rg\ --vimgrep
set grepformat^=%f:%l:%c:%m

"Style

set termguicolors
set pumblend=15
syntax on
let g:gruvbox_italic='1'
let g:gruvbox_contrast_dark='hard'
let g:gruvbox_sign_column='bg0'
let g:gruvbox_invert_selection=0
let g:gruvbox_termcolors=256

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
hi TabLine guibg=#1d2021 guifg=#504945 gui=none
hi TabLineSel guibg=0 guifg=229 gui=none

"Statusline
hi Status1 guibg=#fabd2f guifg=#1d2021 gui=bold
hi Status2 guibg=#fe8019 guifg=#1d2021 gui=bold
hi Status3 guibg=#83a598 guifg=#1d2021 gui=bold

hi User1 guibg=#3c3836 guifg=#1d2021

hi StatusLine guibg=#3c3836 guifg=#1d2021
hi StatusLineNC guibg=#282828 guifg=#1d2021

hi Folded guibg= cterm=none gui=none

hi FloatBorder guibg=#1d2021 guifg=#504945

hi! TSVariable guifg=#ebdbb2
"hi! link TSParameter Normal
hi! TSField guifg=#ebdbb2

hi GruvboxRed guifg=#d75151

hi UnderlineTransparent gui=underline

hi link LspReferenceText CursorLine
hi link LspReferenceRead CursorLine
hi link LspReferenceWrite CursorLine

hi link LspProperty GruvboxBlue
hi link LspFunction GruvboxOrangeBold
hi link LspMethod GruvboxBlueBold
hi link LspNamespace GruvboxAqua
hi link LspType GruvboxYellow
hi link LspString GruvboxYellow
hi link LspClass LspType
hi link LspVariable GruvboxFg1

hi link LspStatic LspProperty
hi link LspEnumMember GruvboxPurple

"hi! TSParameter guifg=#ebdbb2 gui=bold
hi! link TSParameter GruvboxFg1
hi! link TSFunction GruvboxOrangeBold

hi! TSStringEscape gui=bold

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
set mouse=a
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

"Keymappings
let mapleader=","
let maplocalleader="<Space>"

lua require('init')
set completeopt=menuone
"inoremap <Tab> <cmd>lua return require'snippets'.expand_or_advance(1)<CR>
"inoremap <S-Tab> <cmd>lua return require'snippets'.advance_snippet(-1)<CR>

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

"Vimspector
"nnoremap <F2> :call vimspector#ToggleBreakpoint()<Cr>
"nnoremap <F3> :call vimspector#StepOver()<Cr>
"nnoremap <F4> :call vimspector#StepInto()<Cr>
"nnoremap <F5> :call vimspector#Continue()<Cr>
" nvim-dap
"Other
noremap <silent> <C-v> :vsp<Cr>
noremap <silent> <C-b> :sp<Cr>

function! CToggle()
    if empty(filter(getwininfo(), 'v:val.quickfix'))
        copen
    else
        cclose
    endif
endfunction

noremap <silent><leader>n :noh<Cr>
noremap <silent><leader>l :set invlist<Cr>
noremap <silent><leader>r :set invrelativenumber<Cr>
noremap <silent><leader>o :tabnew<Cr>:e ~/Documents/base<Cr>:normal gh<Cr>
noremap <leader>fw :set invwinfixwidth<Cr>
noremap <leader>fh :set invwinfixheight<Cr>
noremap <silent><leader><leader>f :luafile %<Cr>
noremap <leader>g :silent grep 
noremap <silent><leader>t :call CToggle()<Cr>

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
noremap <silent><leader>ep :tabnew<Cr>:e /home/simon/.config/nvim/lua/plugins/<Cr>:normal gh<Cr>:tcd /home/simon/.config/nvim/lua/plugins/<Cr>
noremap <silent><leader>eq :tabnew<Cr>:e /home/simon/.config/nvim/queries<Cr>:normal gh<Cr>:tcd /home/simon/.config/nvim/queries/<Cr>
noremap <silent><leader>ec :tabnew /home/simon/.config/nvim/lua/configs/project_configs.lua<Cr>
noremap <silent><leader>ef :tabnew /home/simon/.config/nvim/lua/configs/file_configs.lua<Cr>
nnoremap <silent> <leader>sv :source $MYVIMRC<Cr>

nnoremap <silent> <leader>pa :call ParanAdd()<Cr>

nnoremap <silent> gb :ls<Cr>:b<Space> 

nnoremap [[ ?{\n<Cr>:noh<Cr>
nnoremap ][ /{\n<Cr>:noh<Cr>
nnoremap ]] /}\n<Cr>:noh<Cr>
nnoremap [] ?}\n<Cr>:noh<Cr>

inoremap <C-C> <Esc>g~iwea
inoremap <C-U> <Esc>viwU<Esc>ea

inoremap <C-F> <C-X><C-F>

tnoremap <silent> <C-J> <C-\><C-N>:let b:mode="i"<Cr><C-w>j
tnoremap <silent> <C-K> <C-\><C-N>:let b:mode="i"<Cr><C-w>k
tnoremap <silent> <C-L> <C-\><C-N>:let b:mode="i"<Cr><C-w>l
tnoremap <silent> <C-H> <C-\><C-N>:let b:mode="i"<Cr><C-w>h

tnoremap <C-W> <C-\><C-N><C-w>

tnoremap <silent> <C-N> <C-\><C-N>:let b:mode="n"<Cr>

tnoremap <silent> <F9> <C-\><C-N>:vert res +2<Cr>a
tnoremap <silent> <F21> <C-\><C-N>:vert res -2<Cr>a
tnoremap <silent> <F10> <C-\><C-N>:res +2<Cr>a
tnoremap <silent> <F22> <C-\><C-N>:res -2<Cr>a

cabbr <expr> && expand('%:p:.:h')
cabbr invim /home/simon/.config/nvim/init.vim
cabbr pacconf /home/simon/.config/nvim/lua/plugins/init.lua

if filereadable('.vProj.vim')
    source .vProj.vim
endif
