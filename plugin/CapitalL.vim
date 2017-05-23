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

" Defaults for quickfix window
if !exists("g:CapitalL_qf_position")
    let g:CapitalL_qf_position = ""
endif
if !exists("g:CapitalL_qf_width")
    let g:CapitalL_qf_width = 0
endif

"" Commands
command!            Ltoggle     call CapitalL_toggle("l")
command!            Lopen       call CapitalL_lopen()
command!            Lclose      call CapitalL_lclose()
command!            Lvimgrep    call CapitalL_lvimgrep()
command!            Lshow       call CapitalL_showPatterns()
command! -nargs=1   Ladd        call CapitalL_add(<f-args>)
command!            Lrm         call CapitalL_rm()
command!            Lnext       call CapitalL_cycle(1)
command!            Lprevious   call CapitalL_cycle(-1)
command! -nargs=1   Lposition   call CapitalL_setPosition(<f-args>)
command! -nargs=*   Lrefresh    call CapitalL_refresh(<f-args>)

command!            Ctoggle     call CapitalL_toggle("c")
command!            Copen       call CapitalL_copen()
command!            Cclose      call CapitalL_cclose()

"" Functions
function! CapitalL_lopen()
    " if we're in a qf window, close it first, then open it again later
    if &filetype == "qf"
        execute "call CapitalL_cclose()"
        let openqf = 1
    else
        let openqf = 0
    endif

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

    if g:CapitalL_enableKeybindings == 1
        execute "call CapitalL_addKeybindings('l','".position."')"
    endif

    execute "call CapitalL_formatLists()"
    normal! gg
    if openqf == 1
        execute "call CapitalL_copen()"
    endif
endfunction

function! CapitalL_lclose()
    execute "lclose"
    execute "call CapitalL_formatLists()"
endfunction

function! CapitalL_refresh(...)
    if a:0 > 0 && a:1 == "l"
        execute "call CapitalL_lvimgrep()"
    endif
    execute "call CapitalL_formatLists()"
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
        return ""
    endif
endfunction

function! CapitalL_GetBufferList()
" taken from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window
    redir =>buflist
    silent! ls!
    redir END
    return buflist
endfunction

function! CapitalL_toggle(...)
" inspiration from http://vim.wikia.com/wiki/Toggle_to_open_or_close_the_quickfix_window

    if a:0 == 0 || a:1 == "l"
        let type = "l"
        let bufname = "Location List"
    elseif a:1 == "c" || a:1 == "qf"
        let type = "c"
        let bufname = "Quickfix List"
    endif

    let buflist = CapitalL_GetBufferList()
    " find buffer numbers of location lists
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')
        " if one of those loc lists is in view, run lclose and return
        if bufwinnr(bufnum) != -1
          execute toupper(type)."close"
          return
        endif
    endfor

    " if loc list is empty, populate it before opening
    if type == "l" && len(getloclist(0)) == 0
        execute "call CapitalL_lvimgrep()"
    endif
    let winnr = winnr()
    execute toupper(type)."open"
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
        endif
        return
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
    execute "call CapitalL_formatList()"
endfunction

function! CapitalL_formatLists()
    execute "call CapitalL_formatList('l')"
    execute "call CapitalL_formatList('c')"
endfunction

function! CapitalL_formatList(...)
    " adjusts position, width, and text formatting of windows
    " input is 'l' (default), 'c', or 'qf'

    if a:0 == 0 || a:1 == "l"
        let type = "l"
        let bufname = "Location List"
    elseif a:1 == "c" || a:1 == "qf"
        let type = "c"
        let bufname = "Quickfix List"
    endif

    let currentWin = winnr()

    " get list of all buffers
    let buflist = CapitalL_GetBufferList()

    " find buffer number of location lists or quickfix window
    for bufnum in map(filter(split(buflist, '\n'), 'v:val =~ "'.bufname.'"'), 'str2nr(matchstr(v:val, "\\d\\+"))')

        " if this is an active window, move to it
        if bufwinnr(bufnum) != -1
            execute bufwinnr(bufnum) . "wincmd w"

            " get variables controlling the formatting
            if type == "l"
                if !exists("b:CapitalL_associatedBufnr")
                    "This buffer is not a CapitalL Location List. The b:CapitalL_associatedBufnr variable is not set.
                    continue
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

            elseif type == "c" || type == "qf"
                let width = g:CapitalL_qf_width
                let position = g:CapitalL_qf_position
                let filetype = "qf"

            endif

            "if the position is vertical, format and resize 
            if position == "left" || position == "right"
                if width > 0
                    execute "vertical resize ".width
                endif
                set modifiable
                silent %s/\v^([^|]*\|){2,2} //e
                if type == "l"
                    execute "set syntax=".filetype
                endif

                if filetype == "markdown" || filetype == "pandoc"
                    " add special formatting for md files here
                    silent! %s/^\s*\#\ //g
                    silent! %s/^\s*\#\#\ /\ \ /g
                    silent! %s/^\s*\#\#\#\ /\ \ \ \ /g
                    silent! %s/^\s*\#\#\#\#\ /\ \ \ \ \ \ /g
                    silent! %s/^\s*\#\#\#\#\#\ /\ \ \ \ \ \ \ \ /g
                    silent! %s/^\s*\#\#\#\#\#\#\ /\ \ \ \ \ \ \ \ \ \ /g
                    syn match LmarkdownH1 /^\S.*\n/
                    syn match LmarkdownH2 /^\s\s\S.*\n/
                    syn match LmarkdownH3 /^\s\s\s\s\S.*\n/
                    syn match LmarkdownH4 /^\s\s\s\s\s\s\S.*\n/
                    syn match LmarkdownH5 /^\s\s\s\s\s\s\s\s\S.*\n/
                    syn match LmarkdownH6 /^\s\s\s\s\s\s\s\s\s\s\S.*\n/
                    hi link LmarkdownH1 markdownH1
                    hi link LmarkdownH2 markdownH2
                    hi link LmarkdownH3 markdownH3
                    hi link LmarkdownH4 markdownH4
                    hi link LmarkdownH5 markdownH5
                    hi link LmarkdownH6 markdownH6
                endif

                set nomodified
                "TODO set nomodifiable. for some reason this affects other
                "windows the way it is now
                "set nomodifiable
            endif

            setlocal cursorline
            setlocal nowrap

        endif
    endfor
    " move back to original window
    execute currentWin . "wincmd w"
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
    "TODO allow for many args, and combine them with OR into one lvimgrep
    " - e.g. \(pattern1\|pattern2\|etc\)
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
    " redo the grep (remove the removed loc list from view)
    execute "call CapitalL_lvimgrep()"
    " if we were in a loc list, move back
    if exists("listWin")
        execute listWin . "wincmd w"
    endif
endfunction

function! CapitalL_cycle(...)
    " if we're in a loc list, move to the associated file
    if exists("b:CapitalL_associatedBufnr")
        let listWin = winnr()
        let fileWin = bufwinnr(b:CapitalL_associatedBufnr)
        execute fileWin . "wincmd w"
    endif
    " make sure patterns exist as a non-empty list
    if !exists("b:CapitalL_patterns")
        let b:CapitalL_patterns = g:CapitalL_defaultPattern
    endif
    if type(b:CapitalL_patterns) != 3
        let b:CapitalL_patterns = [b:CapitalL_patterns]
    endif
    if len(b:CapitalL_patterns) == 0
        echo "No CapitalL_patterns exist. Use :Ladd <pattern> to add some."
        return
    endif
    if !exists("b:CapitalL_currentPattern")
        let b:CapitalL_currentPattern = 0
    endif

    " If no input default cycle forwards
    if a:0 == 0
        let adj = 1
    else
        let adj = a:1
    endif

    " cycle the patterns
    let b:CapitalL_currentPattern = b:CapitalL_currentPattern + adj
    " wrap around if index will be out of range
    if b:CapitalL_currentPattern > len(b:CapitalL_patterns) - 1
        let b:CapitalL_currentPattern = 0
    endif
    if b:CapitalL_currentPattern < 0
        let b:CapitalL_currentPattern = len(b:CapitalL_patterns) - 1
    endif

    " redo the Lvimgrep
    " Lvimgrep will reformat the list too
    execute "call CapitalL_lvimgrep()"

    " if we were in a loc list, move back
    if exists("listWin")
        execute listWin . "wincmd w"
    endif
endfunction

function! CapitalL_copen()
    " if we're in a loc list, move to the associated file
    if exists("b:CapitalL_associatedBufnr")
        let listWin = winnr()
        let fileWin = bufwinnr(b:CapitalL_associatedBufnr)
        execute fileWin . "wincmd w"
    endif
    " open the quickfix window
    let position = CapitalL_parsePosition(g:CapitalL_qf_position)
    execute position." copen"
    execute "call CapitalL_formatLists()"
    " if we were in a loc list, move back
    if exists("listWin")
        execute listWin . "wincmd w"
    endif
endfunction

function! CapitalL_cclose()
    execute "cclose"
    execute "call CapitalL_formatLists()"
endfunction

function! CapitalL_addKeybindings(type,position)
    " type should be 'l' or 'c' or 'qf'
    " position should be 

    nnoremap <buffer> q :Lclose<CR>
    nnoremap <buffer> l <CR>zt
    nnoremap <buffer> <C-d> 5j
    nnoremap <buffer> <C-u> 5k

    "keybindings for staying in loclist after doing something
    if a:position == "topleft vertical" || a:position == "left"
        nnoremap <buffer> J j<CR>zt<C-w>h
        nnoremap <buffer> K k<CR>zt<C-w>h
        nnoremap <buffer> o <CR>zt<C-w>h
    elseif a:position == "vertical" || a:position == "right"
        nnoremap <buffer> J j<CR>zt<C-w>l
        nnoremap <buffer> K k<CR>zt<C-w>l
        nnoremap <buffer> o <CR>zt<C-w>l
    elseif a:position == "topleft" || a:position == "top"
        nnoremap <buffer> J j<CR>zt<C-w>k
        nnoremap <buffer> K k<CR>zt<C-w>k
        nnoremap <buffer> o <CR>zt<C-w>k
    elseif a:position == "botright" || a:position == "bottom"
        nnoremap <buffer> J j<CR>zt<C-w>j
        nnoremap <buffer> K k<CR>zt<C-w>j
        nnoremap <buffer> o <CR>zt<C-w>j
    endif

    if a:type == "l"
        nnoremap <buffer> r :call CapitalL_refresh("l")<CR>
        nnoremap <buffer> } :call CapitalL_cycle(1)<CR>
        nnoremap <buffer> { :call CapitalL_cycle(-1)<CR>
        nnoremap <buffer> ]] :call CapitalL_cycle(1)<CR>
        nnoremap <buffer> [[ :call CapitalL_cycle(-1)<CR>

    elseif a:type == "c" || a:type = "qf"
        nnoremap <buffer> r :call CapitalL_refresh()<CR>

    endif


    
endfunction
