" CapitalList Plugin: Easier quickfix and location lists
" Ideas >>
"   - function for grepping
"       - Lgreppattern and Cgreppattern vars that can be set in ftplugin
"       - keybinding: <localleader>L and C maybe?
"   - function for formatting the lists
"       - Lformatpattern and Cformatpattern vars that can be set in ftplugin
"       - same keybinding as grepping function?
"   - put the default grep pattern in a plugin-specific ftplugin folder
"   - make keybindings customizable

"" Defaults
let g:CapitalLwidth = 40
let g:CapitalCwidth = 40
let g:CapitalLposition = "left"
let g:CapitalCposition = "right"
nnoremap <localleader>l :Lopen<CR>
nnoremap <localleader>q :Copen<CR>
nnoremap <localleader>L :Lvimgrep<CR>
nnoremap <localleader>Q :Cvimgrep<CR>

"" Commands
command Lopen execute ":call Capital#lopen()"
command Copen execute ":call Capital#copen()"
command Lclose execute ":call Capital#lclose()"
command Cclose execute ":call Capital#cclose()"
command Lvimgrep execute ":call Capital#lvimgrep()"
command Cvimgrep execute ":call Capital#vimgrep()"

"" Functions
function! Capital#lvimgrep()
    execute "lvimgrep /".b:CapitalLpattern."/g %"
endfunction
function! Capital#vimgrep()
    execute "vimgrep /".b:CapitalCpattern."/g %"
endfunction

function! Capital#format()
    silent %s/\v^([^|]*\|){2,2} //e
endfunction

function! Capital#lopen()
    execute "topleft vertical lopen"
    execute "vertical resize ".g:CapitalLwidth
    silent %s/\v^([^|]*\|){2,2} //e
    nnoremap <buffer> q :call Capital#lclose<CR>
    nnoremap <localleader>l :call Capital#lclose<CR>
endfunction
function! Capital#copen()
    execute "vertical copen"
    execute "vertical resize ".g:CapitalCwidth
    silent %s/\v^([^|]*\|){2,2} //e
    nnoremap <buffer> q :call Capital#cclose<CR>
    nnoremap <localleader>q :call Capital#cclose<CR>
endfunction

function! Capital#lclose()
    execute "lclose"
    nnoremap <localleader>l :Lopen<CR>
endfunction
function! Capital#cclose()
    execute "cclose"
    nnoremap <localleader>q :Copen<CR>
endfunction

