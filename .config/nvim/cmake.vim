let t:execName=system('grep project CMakeLists.txt | sed "s/project(//g;s/)//g"')
let t:run = "\./build/src/".t:execName
let t:make = "cmake -B build"
let t:build = "cmake --build build"

let t:args = ""
let t:srcDir = "src"

nnoremap <buffer><silent> <localleader>r :call Exec_term(t:run." ".t:args)<Cr>
nnoremap <buffer><silent> <localleader>b :let g:curPos = winsaveview()<Cr> :call Exec_term(t:build)<Cr> :call winrestview(g:curPos)<Cr>
nnoremap <buffer><silent> <localleader>m :let g:curPos = winsaveview()<Cr> :call Exec_term(t:make)<Cr> :call winrestview(g:curPos)<Cr>

cabbr <expr> %% t:srcDir

"let b:UltiSnipsSnippetDirectories=g:UltiSnipsSnippetDirectories+['myGradleSnippets']

if filereadable('.vProj.vim')
    source .vProj.vim
endif
