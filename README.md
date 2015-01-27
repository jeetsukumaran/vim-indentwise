# IndentWise

## Description

`IndentWise` is a Vim plugin that provides for motions based on indent depths
or levels in normal, visual, and operator-pending modes.

### Movements by Relative Indent-Depth

The following key-mappings provide motions to go to lines of lesser, equal, or
greater indent than the line that the cursor is currently on:

- `[-`  : Move to *previous* line of *lesser* indent than the current line
- `[=`  : Move to *previous* line of *same* indent as the current line
- `[+`  : Move to *previous* line of *greater* indent than the current line
- `]-`  : Move to *next* line of *lesser* indent than the current line
- `]+`  : Move to *next* line of *greater* indent than the current line
- `]=`  : Move to *next* line of *same* indent as the current line

The above all take a `{count}`, so that, e.g., ``4[-`` will move to the
previous line that is 4 indent-depths less than the current one. An
"indent-depth" is simply the indentation of the line, and thus any line with a
smaller amount of indentation relative to current line is considered at a
lesser indent depth, and, conversely, any line with a greater indentation than
the current line is considered to be at a greater indent-depth.

### Movements by Absolute Indent-Levels

In addition, you can navigate directly to a line of a particular indent-*level*
using:

- `{count}[_`  : Move to *previous* line with indent-level of `{count}`.
- `{count}]_`  : Move to *next* line with indent-level of `{count}`.

An indent-*level* is always taken to be the effective ``shiftwidth`` value unit
of difference in line indentation (as opposed to an indent-depth, which is
*any* difference in line indentation).

### Indent-Depths vs. Indent-Levels

As noted above, an "indent-depth" is simply the amount of indentation of a
line. Thus an indent-depth difference (less or more) means *any* difference in
indentation relative to the indentation of the current line. An "indent-level"
 on the other hand, is more strict and is defined in terms of ``shiftwidth``
units.

If ``g:indentwise_depths_by_shiftwidth_units`` or
``b:indentwise_depths_by_shiftwidth_units`` is true ("``1``" in Vim-land), then
an indent-depth unit of change is given by ``&shiftwidth`` (instead of 1): this
would make indent-levels almost synonymous with indent-depths.

## Installation

### [pathogen.vim](https://github.com/tpope/vim-pathogen)

    $ cd ~/.vim/bundle
    $ git clone git://github.com/jeetsukumaran/vim-indentwise.git


### [Vundle](https://github.com/gmarik/vundle.git)

    :BundleInstall jeetsukumaran/vim-indentwise

Add the line below into your _.vimrc_.

    Bundle 'jeetsukumaran/vim-indentwise'

### Manually

Copy the _`plugin/indentwise.vim`_ file to your _`.vim/plugin`_ directory and the
_`doc/indentwise.txt`_ file to your _`.vim/doc`_ directory.

## Acknowledgements

IndentWise is based on the following:

-   ["Move to next/previous line with the same indentation"](http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation)
