" CapitalL Plugin: Easier quickfix and location lists
" Todo
"   - Lgreppattern and Cgreppattern vars that can be set in ftplugin
"   - put the default grep pattern in a plugin-specific ftplugin folder
"   - make keybindings customizable
"   - width should be a width or a height depending on position
"   - get filename for grepping from current window using ls
"   - grab current cursor position stuff from cenwin

"" Defaults
if !exists("g:CapitalL_size")
    let g:CapitalL_defaultSize = 40
endif
if !exists("g:CapitalL_defaultPosition")
    let g:CapitalL_defaultPosition = "left"
endif
if !exists("g:CapitalL_DefaultKeybindings")
    let g:CapitalL_DefaultKeybindings = 0
endif

"" Commands
command! Ltoggle execute ":call Ltoggle()"
command! Lopen execute ":call CapitalL_lopen()"
command! Lclose execute ":call CapitalL_lclose()"
command! Lvimgrep execute ":call CapitalL_lvimgrep()"
command! Lcycle execute ":call CapitalL_cycle()"

"" Keybindings
if g:CapitalL_DefaultKeybindings == 1
    nnoremap <leader>l :Ltoggle<CR>
    nnoremap <localleader>l :Lcycle<CR>
endif

function! CapitalL_cycle()
"" Lcycle() Cycle between grep patterns
" - current pattern is indexed by b:CapitalL_pattern
" - it is an index of the list b:CapitalL_patterns
    execute ":call CapitalL_lclose()"
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif

    let startPattern = b:CapitalL_currentPattern
    let stopCycle = 0
    while stopCycle == 0
        "cycle to the next grep pattern
        let b:CapitalL_currentPattern += 1
        if b:CapitalL_currentPattern > len(b:CapitalL_patterns) - 1
            let b:CapitalL_currentPattern = 0
        endif

        "do the grep
        execute ":call CapitalL_lvimgrep()"

        "exit if grep returns something
        if len(getloclist(0)) > 0
            let stopCycle = 1
        endif

        "exit if we've tried all the possible patterns
        if b:CapitalL_currentPattern = startPattern
            let stopCycle = 1
        endif
    endwhile
    execute ":call CapitalL_lopen()"
endfunction

function! CapitalL_lvimgrep()
"" Lvimgrep() Grep to populate lists
" by default uses the values of patterns and currentPattern
" - todo: if an input is given, grep that, else grep like normal
    if !exists("b:CapitalL_patterns")
        echohl ErrorMsg
        echo "No CapitalL patterns are set for this buffer. Set b:CaptialL_patterns"
        return
    end
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif
    " if we're in a loclist, get filename of associated file
    if exists("b:CapitalL_associatedFile")
        let filename = b:CapitalL_associatedfile
    else
        let filename = '%'
    endif
    execute "silent! lvimgrep /".b:CapitalL_patterns[b:CapitalL_currentPattern]."/g ".filename
endfunction

function! CapitalL_lopen()
"" Lopen() Open the lists

    "get buffer variables together before switching to loclist buffer
    if !exists("b:CapitalL_position")
        let b:CapitalL_position = g:CapitalL_defaultPosition
    endif
    if !exists("b:CapitalL_size")
        let b:CapitalL_size = g:CapitalL_defaultSize
    endif
    let position = CapitalL_parsePosition(b:CapitalL_position)
    let size = b:CapitalL_size
    let associatedFile = expand('%:p')

    execute position." lopen"

    "TODO make sure we're focused on the loclist window before adjusting it
    "resize
    if position == "topleft vertical" || position == "vertical"
        execute "vertical resize ".size
    else
        execute "resize ".size
    endif

    let b:CapitalL_filename = associatedFile
    set modifiable
    silent %s/\v^([^|]*\|){2,2} //e
    setlocal nowrap
    set nomodified nomodifiable cursorline

    nnoremap <buffer> q :Lclose<CR>
    nnoremap <buffer> l <CR>zt
    nnoremap <buffer> J j
    nnoremap <buffer> K k
    if position == "topleft vertical"
        nnoremap <buffer> j j<CR>zt<C-w>h
        nnoremap <buffer> k k<CR>zt<C-w>h
    elseif position == "vertical"
        nnoremap <buffer> j j<CR>zt<C-w>l
        nnoremap <buffer> k k<CR>zt<C-w>l
    elseif position == "topleft"
        nnoremap <buffer> j j<CR>zt<C-w>k
        nnoremap <buffer> k k<CR>zt<C-w>k
    elseif position == "botright"
        nnoremap <buffer> j j<CR>zt<C-w>j
        nnoremap <buffer> k k<CR>zt<C-w>j
    endif

    normal! gg
endfunction

function! CapitalL_parsePosition(position)
" parse the position
    if a:position == "right"
        return "vertical"
    elseif a:position == "left"
        return "topleft vertical"
    elseif a:position == "top"
        return "topleft"
    elseif a:position == "bottom"
        return "botright"
    else
        return "topleft vertical"
    endif
endfunction

function! CapitalL_lclose()
"" Lclose() Closing the windows
    execute "lclose"
endfunction

function! CapitalL_GetBufferList()
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! CapitalL_ToggleList(bufname, pfx)
"" Ltoggle() Functions for toggling the lists
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    let buflist = CapitalL_GetBufferList()
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.a:bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        if bufwinnr(bufnum) != -1
          exec(a:pfx.'close')
          return
        endif
    endfor
    " call custom grep functions if list is empty
    if a:pfx == 'l' && len(getloclist(0)) == 0
        execute "call CapitalL_lvimgrep()"
    elseif a:pfx == 'c' && len(getqflist(0)) == 0
        execute "call CapitalL_cvimgrep()"
    endif
    let winnr = winnr()
    exec(toupper(a:pfx).'open')
    if winnr() != winnr
        wincmd p
    endif
endfunction

function! Ltoggle()
    execute "call CapitalL_ToggleList('Location List', 'l')"
endfunction
"function! Ctoggle()
"    execute "call CapitalL_ToggleList('Quickfix List', 'c')"
"endfunction

