set path+=,/src/*

set makeprg=./gradlew
set errorformat=\%E[ant:scalac]\ %f:%l:\ error:\ %m,
    \%W[ant:scalac]\ %f:%l:\ warning:\ %m,
    \%E%.%#:compile%\\w%#Java%f:%l:\ error:\ %m,%-Z%p^,%-C%.%#,
    \%W%.%#:compile%\\w%#Java%f:%l:\ warning:\ %m,%-Z%p^,%-C%.%#,
    \%E%f:%l:\ error:\ %m,%-Z%p^,%-C%.%#,
    \%W%f:%l:\ warning:\ %m,%-Z%p^,%-C%.%#,
    \%E%f:\ %\\d%\\+:\ %m\ @\ line\ %l\\,\ column\ %c.,%-C%.%#,%Z%p^,
    \%E%>%f:\ %\\d%\\+:\ %m,%C\ @\ line\ %l\\,\ column\ %c.,%-C%.%#,%Z%p^,
	\%E%.%#\ >\ %m\ FAILED,
    \%-G%.%#

nnoremap <buffer><silent> <localleader>r :Make run<Cr>
nnoremap <buffer><silent> <localleader>b :Make build<Cr>
nnoremap <buffer><silent> <localleader>t :Make test<Cr>
nnoremap <buffer><silent> <localleader>i :Make install<Cr>
nnoremap <buffer><silent> <localleader>c :Make clean<Cr>

if filereadable('.vProj.vim')
    source .vProj.vim
endif

cabbr <expr> %% t:srcDir
cabbr <expr> %$ t:mainDir
cabbr <expr> $$ t:layoutDir

source ~/.config/nvim/coc.vim
