set makeprg=cmake
set autowrite
set errorformat+=,%ECMake\ Error\ at\ %f:%l\ (%.%#):,%C\ \ %m

let t:args = ""
let t:srcDir = "src"

nnoremap <silent> <localleader>b :Make --build build<Cr>
nnoremap <silent> <localleader>m :Make -B build<Cr>

cabbr <expr> %% t:srcDir
cabbr <expr> %m t:srcDir."/main.cpp"
