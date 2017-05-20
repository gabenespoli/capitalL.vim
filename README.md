# CapitalL: Easier location lists in vim.

CapitalL is basically a wrapper for the Location List commands in vim (`lvimgrep`, `lopen`, and `lclose`). The corresponding CapitalL functions using an uppercase `L` instead, hence the name. It cycles through a list of patterns to use for `lvimgrep` and displays matches in the location list. The position and size of the list can be specified with global defaults and/or buffer-specific variables. If the list is positioned on the left or right, the filename and line number information are removed to make the list more readable.

![CapitalL.vim. Search pattern is ^\"\"](http://i.imgur.com/nAOs0em.png)

![CapitalL.vim. Search pattern is ^function](http://i.imgur.com/B4o7yFi.png)

## Installation

Vundle `Plugin 'gabenespoli/CapitalL.vim'`

## Commands

`Lvimgrep` = Populate the Location List by using `lvimgrep` and the string present in `b:CapitalL_patterns[b:CapitalL_currentPattern]`.

`Lopen` = Open the Location List buffer. If it is on the left or right, reformat it.

`Lclose` = Close the Location List buffer.

`Ltoggle` = Toggle whether the Location List is open or closed.

`Lcycle` = Populate the Location List with the next pattern in `b:CaptitalL_patterns`. This will keep cycling through patterns until either the Location List is non-empty, or it has tried all of the patterns.

## Global Variables

These variables can be set in your vimrc if you don't want the defaults.

`g:CapitalL_defaultPosition` = The default position of the Location List. Can be `'left'`, `'right'`, `'top'`, or `'bottom'`. Default `'left'`.

`g:CapitalL_defaultWidth` = The default width of a Location List positioned on the left or right. Default 40.

`g:CapitalL_defaultKeybindings` = Enter 1 or 0 to use or not use these keybindings. Default 0.

`g:CapitalL_defaultLocationListKeybindings` = Enter 1 or 0 to use or not use these keybindings. Default 1.

## Buffer-Specific Variables

These variables can be set in a file in the `ftplugin` folder. `b:CapitalL_patterns` is required for this plugin to do anything.

`b:CapitalL_position` = The position of the Location List associated with the buffer. Defaults to `g:CapitalL_defaultPosition`.

`b:CapitalL_width` = The width of the Location List associated with the buffer if it is on the left or right. Defaults to `g:CapitalL_defaultWidth`.

`b:CapitalL_patterns` = A list of patterns to use with `lvimgrep` to create the location lists. The defaults can be found in the `ftplugin` folder of this repository. For example, the default for vim files is `['^\"\"', '^\s*function', 'TODO']`.

`b:CaptialL_currentPattern` = An index specifying which pattern in `b:CapitalL_patterns` is being used for this buffer's Location List.

## Default Keybindings

### Editor (`if g:CapitalL_defaultKeybindings == 1`)

Note that `<localleader>` usually defaults to backslash (\)

`<localleader>l :Ltoggle<CR>`

`<localleader>L :Lcycle<CR>`

### Location List (`if g:CapitalL_defaultLocationListKeybindings == 1`)

Note that these keybindings will only be available in the Location List buffer.

`q` = Close the Location List (`Lclose`)

`l` = Go to the currently selected line in the associated file, and put that line at the top of the screen.

`o` = Same as `l` except keep the cursor in the Location List.

`J` and `K` = Go to the next item in the list, open it, and move focus back to the list. It's like typing `jo` or `ko`.

## TODO

- add special formatting of Location List for markdown files (replace #'s with indent, use default markdown heading formatting)

