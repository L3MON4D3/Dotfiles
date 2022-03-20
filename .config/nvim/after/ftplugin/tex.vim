setlocal foldmethod=indent
setlocal foldlevel=1
setlocal fillchars=fold:\ ,vert:\|
setlocal foldtext=MyFoldText()
augroup tex
au tex BufWrite <buffer> :Dispatch :TexlabBuild
set textwidth=120
