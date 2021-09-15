let b:execName=system("grep project CMakeLists.txt | perl -pe 's/project\\((.*)\\)\\n/$1/g'")
let b:run = "\./build/src/".b:execName
let b:make = "cmake -B build"
let b:build = "cmake --build build"

set makeprg=cmake
set autowrite
set errorformat+=,%ECMake\ Error\ at\ %f:%l\ (%.%#):,%C\ \ %m

let b:args = ""
let b:srcDir = "src"

nnoremap <buffer><silent> <localleader>r :execute "!".(exists('t:run') ? t:run : b:run)." ".(exists('t:args') ? t:args : b:args) <Cr>
nnoremap <buffer><silent> <localleader>b :Make --build build<Cr>
nnoremap <buffer><silent> <localleader>m :Make -B build<Cr>
nnoremap <buffer><silent> <localleader>c :execute "edit ".expand("%:h")."/CMakeLists.txt"<Cr>

cabbr <expr> %% b:srcDir
cabbr <expr> %m b:srcDir."/main.cpp"
