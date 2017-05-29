# CapitalL: Easier location lists in vim.

The vim Location List is a buffer containing links to certain lines of file which match a pattern. It can be populated using `lvimgrep` and a regex pattern, and opened using `lopen`. CapitalL is a vim plugin which stores multiple patterns in a variable, so that you can cycle through different patterns easily.

Some example patterns that I find useful:

- Lines beginning with two comment characters (e.g., `""` in vim, `##` in bash/python, `%%` in octave/matlab), essentially creating an interactive document outline.

- Lines beginning with a function definition (e.g., `function` in vim/octave/matlab, `class` and `def` in python), so you can get an overview of what's in the file and jump around quickly.

- The word "TODO", so I can see a list of my todos in a file and jump to them.

- A temporary replacement for vim's search functionality (`/` and `?`) if you want to see a list of search results instead of having to cycle through them with `n` and `N`.

Once in the Location List, use `[[`/`{` and `]]`/`}` to cycle through patterns. This plugin includes functions to control the Quickfix Window as well, but only its position and keybindings; this plugin won't populate the Quickfix Window with anything.

![CapitalL.vim. Search pattern is \(^\"\"\|^function\)](http://i.imgur.com/OQKSzrM.png)

Some other features:

- The Location List inherits the same filetype as the file so that it gets the same syntax highlighting. This is only apparent when the Location List is positioned on the left or right, when CapitalL reformats the list (i.e., strips the filename and line/col number information).

- Since there isn't any editing that needs to be done in the Location List, many keys are rebound so it acts a bit more like less and ranger.

## Installation

Vundle `Plugin 'gabenespoli/CapitalL.vim'`

## Commands

`Lopen`, `Copen` = Open the Location List or Quickfix Window. If it is on the left or right, reformat the text. For Location Lists, this runs `Lvimgrep` first to make sure it is updated.

`Lclose`, `Copen` = Close the Location List or Quickfix Window and run `Lrefresh`.

`Ltoggle`, `Ctoggle` = Toggle whether the Location List is open or closed.

`Lvimgrep` = Populate the Location List by using `lvimgrep` and the string present in `b:CapitalL_patterns[b:CapitalL_currentPattern]`.

`Lnext` = Populate the Location List with the next pattern in `b:CaptitalL_patterns`. This will keep cycling through patterns until either the Location List is non-empty, or it has tried all of the patterns.

`Lprevious` = Same as `Lnext`, but cycles through patterns in the opposite direction.

`Ladd <pattern>` = Add a pattern to the list. This is useful for "on-the-fly" location lists, instead of adding a pattern to the ftplugin file. I sometimes find it useful to use this instead of `/` or `?` for searching, since I can see all search results in a list instead of using `n`/`N` to cycle through them until I find the line I want.

`Lposition <position>` = Change the position of the Location List for the current buffer. Can be 'left', 'right', 'top', or 'bottom'.

`Lrefresh` = Reformats all lists to have the appropriate position, width, and text formatting. When called with the argument `l`, it also runs `Lvimgrep`.

## Keybindings

### Global

There are no global keybindings enabled by default. Consider adding the following keybindings to your vimrc.

```
nnoremap <localleader>l :Ltoggle<CR>
nnoremap <localleader>q :Ctoggle<CR>
```

### Location List & Quickfix Window

These keybindings are only available in the Location List or Quickfix Window. They are on by default, but can be turned off by adding `g:CapitalL_enableKeybindings = 0` to your vimrc.

`o`, `l` or `enter` = Go to the currently selected line in the associated file, and put that line at the top of the screen. `enter` is the vim default for this. `o` stands for "open"; `l` is like opening a file in [ranger](https://github.com/ranger/ranger).

`i` = Same as above except keep the cursor in Location List or Quickfix Window. This is like file preview in [ranger](https://github.com/ranger/ranger).

`q` = Close the List (`Lclose` or `Cclose`).

`j`/`e` and `k`/`y` = Select the next or previous item in the list. Since j/k are often mapped to gj/gk (to move the cursor by visual line, not line number), these keys are explicitly remapped back to j/k.

`d` and `u` = Same as above but jump by 5 items.

`f` and `b` = Same as above but jump by 10 items.

`<C-e>` and `<C-y>` = Select the next or previous item in the list, move to that location in the file, and keep focus in the Location List or Quickfix Window. This is analogous to pressing `ji` (or `<enter><C-w>p` if you aren't using the CapitalL keybindings).

`<C-d>` and `<C-u>` = Same as above but jump by 5 items.

`<C-f>` and `<C-b>` = Same as above but jump by 10 lines.

`r` = Refresh the formatting of all lists (`Lrefresh`). If the cursor is focused in a Location List, also run `Lvimgrep`.

### Location List Only

These keybindings are only available in the Location List (i.e., not the Quickfix Window).

`}` or `]]` = Cycle to the next pattern (`Lnext`).

`{` or `[[` = Cycle to the previous pattern (`Lprevious`).

## Global Variables

These variables can be set in your vimrc if you don't want the defaults.

`g:CapitalL_defaultPosition` = The default position of the Location List. Can be 'left', 'right', 'top', or 'bottom'. Default 'left'.

`g:CapitalL_qf_position` = As above, but for the Quickfix Window. Default 'right'.

`g:CapitalL_defaultWidth` = The default width of a Location List positioned on the left or right. Default 40.

`g:CapitalL_qf_width` = As above.

`g:CapitalL_defaultPattern` = A list of the patterns to cycle through if there is no buffer-specific variable (i.e., set in the ftplugin file). Default `['TODO']`.

`g:CapitalL_enableKeybindings` = Enter 1 or 0 to enable or disable the default keybindings in the Location List buffer. Default 1.

## Buffer-Specific Variables

These variables can be set in a file in the ftplugin folder. `b:CapitalL_patterns` is required for this plugin to do anything.

`b:CapitalL_position` = The position of the Location List associated with the buffer. Defaults to `g:CapitalL_defaultPosition`.

`b:CapitalL_width` = The width of the Location List associated with the buffer if it is on the left or right. Defaults to `g:CapitalL_defaultWidth`.

`b:CapitalL_patterns` = A list of patterns to use with `Lvimgrep` to create the location lists. The defaults can be found in the `ftplugin` folder of this repository. The default if no ftplugin file is found is `['TODO']'`.

`b:CaptialL_currentPattern` = An index specifying which pattern in `b:CapitalL_patterns` is being used for this buffer's Location List.

## Special Markdown Formatting

If the filetype is markdown or pandoc, then the Location List is formatted differently. The #'s for headings are replaced with 2 spaces each (except for level 1). This indented format is easier to read (without the leading #'s everywhere) and see the outline of the document. Each heading is given the syntax LmarkdownH1, LmarkdownH2, etc., and the highlights are linked to markdownH1, markdownH2, etc. This means that the syntax highlighting for markdown headings is retained, but also customizable for the Location List only.

## TODO

- Allow for multiple inputs into Ladd and combine them with logical or: `\(pattern1\|pattern2\)`

- implement a function to change the special formatting of the list to the markdown version. Implement a pseudo-markdown-headings formatting that can use any comment character, but the first heading level is ignored (i.e., in vim, `""` is a level 1 heading, `"""` is a level 2 heading, etc., and `"` are ignored). This allows relatively easy implementation of some document structure to code files.

