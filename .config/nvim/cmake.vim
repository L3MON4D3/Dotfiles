let t:execName=system("grep project CMakeLists.txt | perl -pe 's/project\\((.*)\\)\\n/$1/g'")
let t:run = "\./build/src/".t:execName
let t:make = "cmake -B build"
let t:build = "cmake --build build"

set makeprg=cmake
set autowrite
set errorformat+=,%ECMake\ Error\ at\ %f:%l\ (%.%#):,%C\ \ %m

let t:args = ""
let t:srcDir = "src"

"nnoremap <buffer><silent> <localleader>r :call Exec_term(t:run." ".t:args)<Cr>
"nnoremap <buffer><silent> <localleader>b :let g:curPos = winsaveview()<Cr> :call Exec_term(t:build)<Cr> :call winrestview(g:curPos)<Cr>
"nnoremap <buffer><silent> <localleader>m :let g:curPos = winsaveview()<Cr> :call Exec_term(t:make)<Cr> :call winrestview(g:curPos)<Cr>
"nnoremap <buffer><silent> <localleader>c :execute "edit ".expand("%:h")."/CMakeLists.txt"<Cr>

nnoremap <buffer><silent> <localleader>r :execute "!".t:run." ".t:args<Cr>
nnoremap <buffer><silent> <localleader>b :Make --build build<Cr>
nnoremap <buffer><silent> <localleader>m :Make -B build<Cr>
nnoremap <buffer><silent> <localleader>c :execute "edit ".expand("%:h")."/CMakeLists.txt"<Cr>
nnoremap <buffer><silent> <localleader>i :CocCommand clangd.switchSourceHeader<Cr>

cabbr <expr> %% t:srcDir
cabbr <expr> %m t:srcDir."/main.cpp"

if filereadable('.vProj.vim')
    source .vProj.vim
endif
