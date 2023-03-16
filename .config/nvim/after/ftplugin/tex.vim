setlocal foldmethod=indent
setlocal foldlevel=1
augroup tex
au tex BufWrite <buffer> :Dispatch :TexlabBuild
set textwidth=120
