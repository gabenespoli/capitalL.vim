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
if !exists("g:CapitalList_Lwidth")
    let g:CapitalList_Lwidth = 40
endif
if !exists("g:CapitalList_Cwidth")
    let g:CapitalList_Cwidth = 40
endif
if !exists("g:CapitalList_Lposition")
    let g:CapitalList_Lposition = "left"
endif
if !exists("g:CapitalList_Cposition")
    let g:CapitalList_Cposition = "right"
endif

"" Commands
command! Lopen execute ":call CapitalList_lopen()"
command! Copen execute ":call CapitalList_copen()"
command! Lclose execute ":call CapitalList_lclose()"
command! Cclose execute ":call CapitalList_cclose()"
command! Lvimgrep execute ":call CapitalList_lvimgrep()"
command! Cvimgrep execute ":call CapitalList_cvimgrep()"

"" Keybindings
nnoremap <localleader>l :Lopen<CR>
nnoremap <localleader>q :Copen<CR>
nnoremap <localleader>L :Lvimgrep<CR>
nnoremap <localleader>Q :Cvimgrep<CR>

"" Grep to populate lists
function! CapitalList_lvimgrep()
    execute "lvimgrep /".b:CapitalList_Lpattern."/g %"
endfunction
function! CapitalList_cvimgrep()
    execute "vimgrep /".b:CapitalList_Cpattern."/g %"
endfunction

"" Open the lists
function! CapitalList_lopen()
    let position = CapitalList_getPosition(g:CapitalList_Lposition)
    execute position." lopen"
    execute "vertical resize ".g:CapitalList_Lwidth
    set modifiable
    silent %s/\v^([^|]*\|){2,2} //e
    setlocal nowrap
    set nomodified nomodifiable cursorline
    nnoremap <buffer> q :Lclose<CR>
    nnoremap <localleader>l :Lclose<CR>
endfunction
function! CapitalList_copen()
    let position = CapitalList_getPosition(g:CapitalList_Cposition)
    execute position." copen"
    execute "vertical resize ".g:CapitalList_Cwidth
    set modifiable
    silent %s/\v^([^|]*\|){2,2} //e
    setlocal nowrap
    set nomodified nomodifiable cursorline
    nnoremap <buffer> q :Cclose<CR>
    nnoremap <localleader>q :Cclose<CR>
endfunction

" parse the position
function! CapitalList_getPosition(position)
    if a:position == "right"
        return "vertical"
    elseif a:position == "left"
        return "topleft vertical"
    elseif a:position == "top"
        return "topleft"
    elseif a:position == "bottom"
        return "botright"
    else
        return "vertical"
    endif
endfunction

"" Closing the windows
function! CapitalList_lclose()
    execute "lclose"
    nnoremap <localleader>l :Lopen<CR>
endfunction
function! CapitalList_cclose()
    execute "cclose"
    nnoremap <localleader>q :Copen<CR>
endfunction

