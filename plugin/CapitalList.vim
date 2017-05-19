" CapitalList Plugin: Easier quickfix and location lists
" Ideas >>
"   - function for grepping
"       - Lgreppattern and Cgreppattern vars that can be set in ftplugin
"       - keybinding: <localleader>L and C maybe?
"   - function for formatting the lists
"       - Lformatpattern and Cformatpattern vars that can be set in ftplugin
"       - same keybinding as grepping function?
"   - put the default grep pattern in a plugin-specific ftplugin folder

let g:CapitalLwidth = 30
let g:CapitalCwidth = 30

function! CapitalLopen()
    execute "topleft vertical lopen"
    execute "vertical resize ".g:CapitalLwidth
    nnoremap <buffer> q :Lclose<CR>
    nnoremap <localleader>l :Lclose<CR>
endfunction
function! CapitalLclose()
    execute "lclose"
    nnoremap <localleader>l :Lopen<CR>
endfunction
function! CapitalCopen()
    execute "vertical copen"
    execute "vertical resize ".g:CapitalCwidth
    nnoremap <buffer> q :Cclose<CR>
    nnoremap <localleader>q :Cclose<CR>
endfunction
function! CapitalCclose()
    execute "cclose"
    nnoremap <localleader>q :Copen<CR>
endfunction

command Lopen execute ":call CapitalLopen()"
command Lclose execute ":call CapitalLclose()"
command Copen execute ":call CapitalCopen()"
command Cclose execute ":call CapitalCclose()"

nnoremap <localleader>q :Copen<CR>
nnoremap <localleader>l :Lopen<CR>
