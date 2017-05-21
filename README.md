# CapitalL: Easier location lists in vim.

CapitalL is basically a wrapper for the Location List commands in vim (`lvimgrep`, `lopen`, and `lclose`). The corresponding CapitalL functions use an uppercase L instead, hence the name. It cycles through a list of patterns to use for `lvimgrep` and displays matches in the location list. The position and size of the list can be specified with global defaults and/or buffer-specific variables. If the list is positioned on the left or right, the filename and line number information are removed to make the list more readable.

![CapitalL.vim. Search pattern is ^\"\"](http://i.imgur.com/nAOs0em.png)

![CapitalL.vim. Search pattern is ^function](http://i.imgur.com/B4o7yFi.png)

This plugin was designed for quickly jumping around a file with many functions (e.g., pull a list of `def` or `class` in python, or `function` in vim or octave), or jumping around to lines beginning with a double comment character (e.g., `##` in python or bash, `""` in vim, or `%%` in octave), as well as easily switching between these two schemes. However, any pattern can be used and cycled through with other patterns.

## Installation

Vundle `Plugin 'gabenespoli/CapitalL.vim'`

## Commands

`Ltoggle` = Toggle whether the Location List is open or closed. I set this to `<localleader>l` in my vimrc.

`Lnext` = Populate the Location List with the next pattern in `b:CaptitalL_patterns`. This will keep cycling through patterns until either the Location List is non-empty, or it has tried all of the patterns.

`Lprevious` = Same as `Lnext`, but cycles through patterns in the opposite direction.

`Lvimgrep` = Populate the Location List by using `lvimgrep` and the string present in `b:CapitalL_patterns[b:CapitalL_currentPattern]`.

`Lopen` = Open the Location List buffer. If it is on the left or right, reformat it.

`Lclose` = Close the Location List buffer.

## Keybindings in the Location List Window

These keybindings are available in the Location List window only. They can be enabled or disabled with the `g:CapitalL_enableKeybindings` variable.

`q` = Close the Location List (`Lclose`)

`l` = Go to the currently selected line in the associated file, and put that line at the top of the screen.

`o` = Same as `l` except keep the cursor in the Location List.

`J` and `K` = Go to the next item in the list, open it, and move focus back to the list. It's like typing `jo` or `ko`.

`}` and `]]` = Cycle to the next pattern (`Lnext`).

`{` and `[[` = Cycle to the previous pattern (`Lprevious`).

## Global Variables

These variables can be set in your vimrc if you don't want the defaults.

`g:CapitalL_defaultPosition` = The default position of the Location List. Can be `'left'`, `'right'`, `'top'`, or `'bottom'`. Default `'left'`.

`g:CapitalL_defaultWidth` = The default width of a Location List positioned on the left or right. Default 40.

`g:CapitalL_enableKeybindings` = Enter 1 or 0 to enable or disable the default keybindings in the Location List buffer. Default 1.

## Buffer-Specific Variables

These variables can be set in a file in the `ftplugin` folder. `b:CapitalL_patterns` is required for this plugin to do anything.

`b:CapitalL_position` = The position of the Location List associated with the buffer. Defaults to `g:CapitalL_defaultPosition`.

`b:CapitalL_width` = The width of the Location List associated with the buffer if it is on the left or right. Defaults to `g:CapitalL_defaultWidth`.

`b:CapitalL_patterns` = A list of patterns to use with `lvimgrep` to create the location lists. The defaults can be found in the `ftplugin` folder of this repository. For example, the default for vim files is `['^\"\"', '^\s*function', 'TODO']`. The default is `['^\#\#', 'TODO']'`.

`b:CaptialL_currentPattern` = An index specifying which pattern in `b:CapitalL_patterns` is being used for this buffer's Location List.

## TODO

- add special formatting of Location List for markdown files (replace #'s with indent, use default markdown heading formatting)

