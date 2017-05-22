"" CapitalL.vim: Easier location lists in vim.  

" notes
" - most of these functions start with Lclose and end with Lopen, 
"   so that buffer-specific variables are accessible if the 
"   current window is a loc list

"" Defaults
if !exists("g:CapitalL_defaultPosition")
    let g:CapitalL_defaultPosition = "left"
endif
if !exists("g:CapitalL_width")
    let g:CapitalL_defaultWidth = 40
endif
if !exists("g:CapitalL_enableKeybindings")
    let g:CapitalL_enableKeybindings = 1
endif
if !exists("g:CapitalL_defaultPattern")
    let g:CapitalL_defaultPattern = ['TODO']
endif

"" Commands
command! Ltoggle call CapitalL_toggle()
command! Lopen call CapitalL_lopen()
command! Lclose call CapitalL_lclose()
command! Lvimgrep call CapitalL_lvimgrep()
command! -nargs=1 Ladd call CapitalL_add(<f-args>)
command! Lrm call CapitalL_rm()
command! Lshow call CapitalL_showPatterns()
command! Lnext call CapitalL_cycle(1)
command! Lprevious call CapitalL_cycle(-1)
command! -nargs=1 Lposition call CapitalL_setPosition(<f-args>)

"" Functions
function! CapitalL_lopen()
    " if we're in a loc list, redo Lvimgrep (like Lrefresh)
    " Lvimgrep will move to the associated file and back
    if exists("b:CapitalL_associatedBufnr")
        execute "call CapitalL_lvimgrep()"
        return
    endif
    " after this part we know we are not in a loc list

    " if the loc list is empty, populate it
    " Lvimgrep will check pattern and currentpattern vars
    if len(getloclist(0)) == 0
        execute "call CapitalL_lvimgrep()"
    endif

    "get buffer variables together before switching to loclist buffer
    let associatedBufnr = bufnr(expand('%'))
    if !exists("b:CapitalL_position")
        let b:CapitalL_position = g:CapitalL_defaultPosition
    endif
    let position = CapitalL_parsePosition(b:CapitalL_position)

    execute position." lopen"

    let b:CapitalL_associatedBufnr = associatedBufnr
    execute "call CapitalL_formatList()"

    if g:CapitalL_enableKeybindings == 1
        nnoremap <buffer> q :Lclose<CR>
        nnoremap <buffer> l <CR>zt
        nnoremap <buffer> } :call CapitalL_cycle(1)<CR>
        nnoremap <buffer> { :call CapitalL_cycle(-1)<CR>
        nnoremap <buffer> ]] :call CapitalL_cycle(1)<CR>
        nnoremap <buffer> [[ :call CapitalL_cycle(-1)<CR>
        "keybindings for staying in loclist after doing something
        if position == "topleft vertical"
            nnoremap <buffer> J j<CR>zt<C-w>h
            nnoremap <buffer> K k<CR>zt<C-w>h
            nnoremap <buffer> o <CR>zt<C-w>h
        elseif position == "vertical"
            nnoremap <buffer> J j<CR>zt<C-w>l
            nnoremap <buffer> K k<CR>zt<C-w>l
            nnoremap <buffer> o <CR>zt<C-w>l
        elseif position == "topleft"
            nnoremap <buffer> J j<CR>zt<C-w>k
            nnoremap <buffer> K k<CR>zt<C-w>k
            nnoremap <buffer> o <CR>zt<C-w>k
        elseif position == "botright"
            nnoremap <buffer> J j<CR>zt<C-w>j
            nnoremap <buffer> K k<CR>zt<C-w>j
            nnoremap <buffer> o <CR>zt<C-w>j
        endif
    endif

    normal! gg
endfunction

function! CapitalL_setPosition(position)
    execute "call CapitalL_lclose()"
    let possible = ["left","right","top","bottom"]
    if index(possible,a:position) < 0
        echohl ErrorMsg
        echo "Position must be left, right, top, or bottom.
        return
    endif
    let b:CapitalL_position = a:position
    execute "call CapitalL_lopen()"
endfunction

function! CapitalL_parsePosition(position)
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
    execute "lclose"
endfunction

function! CapitalL_GetBufferList()
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! CapitalL_toggle()
" inspiration from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    let buflist = CapitalL_GetBufferList()
    " find buffer numbers of location lists
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "Location List"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        " if one of those loc lists is in view, run lclose and return
        if bufwinnr(bufnum) != -1
          execute "lclose"
          return
        endif
    endfor

    " if loc list is empty, populate it before opening
    if len(getloclist(0)) == 0
        execute "call CapitalL_lvimgrep()"
    endif
    let winnr = winnr()
    exec('Lopen')
    if winnr() != winnr
        wincmd p
    endif
endfunction

function! CapitalL_lvimgrep()
    " if we're in a loc list, move to the associated file
    if exists("b:CapitalL_associatedBufnr")
        let listWin = winnr()
        let fileWin = bufwinnr(b:CapitalL_associatedBufnr)
        execute fileWin . "wincmd w"
    endif
    if !exists("b:CapitalL_patterns")
        echo "No CapitalL patterns are associated with this buffer. Use :Ladd to add some."
        " if we were in a loc list, move back
        if exists("listWin")
            execute listWin . "wincmd w"
            return
        endif
    endif
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif
    " make sure it is a list variable
    if type(b:CapitalL_patterns) != 3
        let b:CapitalL_patterns = [b:CapitalL_patterns]
    endif
    " make sure current pattern ind doesn't exceed number of patterns
    if b:CapitalL_currentPattern < 0
        echohl ErrorMsg
        echo "CapitalL.vim: The current pattern index exceeds the number of patterns."
        return
    endif
    " do the lvimgrep
    execute "silent! lvimgrep /".b:CapitalL_patterns[b:CapitalL_currentPattern]."/g %"
    " if we were in a loc list, move back
    if exists("listWin")
        execute listWin . "wincmd w"
    endif
endfunction

function! CapitalL_formatList()
    " we should be in a loc list
    " this means that b:position will exist in the associated file
    " make sure of this and then move to the file to get buffer vars
    if !exists("b:CapitalL_associatedBufnr")
        echo "This buffer is not a CapitalL Location List. The b:CapitalL_associatedBufnr variable is not set."
        return
    endif

    " move to associated file, get vars, move back
    let listWin = winnr()
    let fileWin = bufwinnr(b:CapitalL_associatedBufnr)
    execute fileWin . "wincmd w"
    if !exists("b:CapitalL_width")
        let b:CapitalL_width = g:CapitalL_defaultWidth
    endif
    let width = b:CapitalL_width
    let position = b:CapitalL_position
    let filetype = &filetype
    execute listWin . "wincmd w"
    
    "if the position is vertical, format and resize 
    if position == "left" || position == "right"
        execute "vertical resize ".width
        set modifiable
        silent %s/\v^([^|]*\|){2,2} //e
        execute "set syntax=".filetype
        if filetype == "markdown" || filetype == "pandoc"
            " add special formatting for md files here
            silent %s/^#/\ \ /g
            silent %s/^#/\ \ /g
            silent %s/^#/\ \ /g
            silent %s/^#/\ \ /g
            silent %s/^#/\ \ /g
            silent %s/^#/\ \ /g
            silent %s/^\ //g
        endif
        set nomodified
endif

    set cursorline
    setlocal nowrap
endfunction

function! CapitalL_showPatterns()
    " if we're in a loc list, move to the associated file
    if exists("b:CapitalL_associatedBufnr")
        let listWin = winnr()
        let fileWin = bufwinnr(b:CapitalL_associatedBufnr)
        execute fileWin . "wincmd w"
    endif
    if exists("b:CapitalL_patterns")
        echo b:CapitalL_patterns
    else
        echo "No CapitalL patterns are currently specified."
    endif
    " if we were in a loc list, move back
    if exists("listWin")
        execute listWin . "wincmd w"
    endif
endfunction

function! CapitalL_add(pattern)
    " if we're in a loc list, move to the associated file
    if exists("b:CapitalL_associatedBufnr")
        let listWin = winnr()
        let fileWin = bufwinnr(b:CapitalL_associatedBufnr)
        execute fileWin . "wincmd w"
    endif
    " make sure patterns exists and is a list
    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = [a:pattern]
    elseif type(b:CapitalL_patterns) == 3
        let b:CapitalL_patterns = b:CapitalL_patterns + [a:pattern]
    else
        let b:CapitalL_patterns = [b:CapitalL_patterns, a:pattern]
    endif
    " update current pattern to the new one
    let b:CapitalL_currentPattern = len(b:CapitalL_patterns) - 1
    " lvimgrep the new pattern
    execute "call CapitalL_lvimgrep()"
    " if we were in a loc list, move back
    if exists("listWin")
        execute listWin . "wincmd w"
    endif
endfunction

function! CapitalL_rm()
    " if we're in a loc list, move to the associated file
    if exists("b:CapitalL_associatedBufnr")
        let listWin = winnr()
        let fileWin = bufwinnr(b:CapitalL_associatedBufnr)
        execute fileWin . "wincmd w"
    endif
    " remove the currently selected pattern from the patterns list
    execute "call remove(b:CapitalL_patterns, b:CapitalL_currentPattern)"
    " adjust the pattern index
    if b:CapitalL_currentPattern != 0
        let b:CapitalL_currentPattern = b:CapitalL_currentPattern - 1
    endif
    " if we were in a loc list, move back
    if exists("listWin")
        execute listWin . "wincmd w"
    endif
endfunction

function! CapitalL_cycle(...)
    execute ":call CapitalL_lclose()"
" - current pattern is indexed by b:CapitalL_pattern
" - it is an index of the list b:CapitalL_patterns
    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = g:CapitalL_defaultPattern
    endif
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif
    " make sure it is a list variable
    if type(b:CapitalL_patterns) != 3
        let b:CapitalL_patterns = [b:CapitalL_patterns]
    endif

    " If no input default cycle forwards
    if a:0 == 0
        let adj = 1
    else
        let adj = a:1
    endif

    "cycle the patterns
    let b:CapitalL_currentPattern = b:CapitalL_currentPattern + adj
    " wrap around if index will be out of range
    if b:CapitalL_currentPattern > len(b:CapitalL_patterns) - 1
        let b:CapitalL_currentPattern = 0
    endif
    if b:CapitalL_currentPattern < 0
        let b:CapitalL_currentPattern = len(b:CapitalL_patterns) - 1
    endif

    execute ":call CapitalL_lopen()"
endfunction

