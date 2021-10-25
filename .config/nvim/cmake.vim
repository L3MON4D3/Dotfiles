let t:execName=system("grep project CMakeLists.txt | perl -pe 's/project\\((.*)\\)\\n/$1/g'")
let t:run = "\./build/src/".t:execName

set makeprg=cmake
set autowrite
set errorformat+=,%ECMake\ Error\ at\ %f:%l\ (%.%#):,%C\ \ %m

let t:args = ""
let t:srcDir = "src"

nnoremap <silent> <localleader>r :execute "!".(exists('t:run') ? t:run : t:run)." ".(exists('t:args') ? t:args : b:args) <Cr>
nnoremap <silent> <localleader>b :Make --build build<Cr>
nnoremap <silent> <localleader>m :Make -B build<Cr>
nnoremap <silent> <localleader>c :execute "edit ".expand("%:h")."/CMakeLists.txt"<Cr>

cabbr <expr> %% t:srcDir
cabbr <expr> %m t:srcDir."/main.cpp"
