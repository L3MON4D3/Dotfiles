setl ai cindent nosi
" never indent on key-press!!
setl cinkeys=
setl indentexpr=""
nnoremap <silent><buffer> <space>i :ClangdSwitchSourceHeader<Cr>
set formatoptions+=c
set formatoptions-=t
set textwidth=80
