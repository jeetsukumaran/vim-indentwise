""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
""  IndentWise
""
""  Indent-level based movements in Vim.
""
""  Copyright 2015 Jeet Sukumaran.
""
""  This program is free software; you can redistribute it and/or modify
""  it under the terms of the GNU General Public License as published by
""  the Free Software Foundation; either version 3 of the License, or
""  (at your option) any later version.
""
""  This program is distributed in the hope that it will be useful,
""  but WITHOUT ANY WARRANTY; without even the implied warranty of
""  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
""  GNU General Public License <http://www.gnu.org/licenses/>
""  for more details.
""
""  This program contains code from the following sources:
""
""  - Vim Wiki tip contributed by Ingo Karkat:
""
""          http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
""
""
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" Reload and Compatibility Guard {{{1
" ============================================================================
" Reload protection.
if (exists('g:did_indentwise') && g:did_indentwise) || &cp || version < 700
    finish
endif
let g:did_indentwise = 1
" avoid line continuation issues (see ':help user_41.txt')
let s:save_cpo = &cpo
set cpo&vim
" 1}}}

" Main Code {{{1
" ==============================================================================

" move_to_indent_level {{{2
" ==============================================================================
" Jump to the next or previous line that has the same level, higher, or a
" lower level of indentation than the current line.
"
" Shamelessly taken and modified from code contributed by Ingo Karkat:
"
"   http://vim.wikia.com/wiki/Move_to_next/previous_line_with_same_indentation
"
" Parameters
" ----------
" exclusive : bool
"   true: Motion is exclusive; false: Motion is inclusive
" fwd : bool
"   true: Go to next line; false: Go to previous line
" indentlevel : int
"   <0: Go to line with smaller indentation level;
"    0: Go to line with the same indentation level;
"   >0: Go to line with the larger indentation level;
" skip_blanks : bool
"   true: Skip blank lines; false: Don't skip blank lines
" preserve_col_pos : bool
"   true: keep current cursor column; false: go to first non-space column
"
function! <SID>move_to_indent_level(exclusive, fwd, indent_level, skip_blanks, preserve_col_pos)
    let stepvalue = a:fwd ? 1 : -1
    let current_line = line('.')
    let current_column = col('.')
    let lastline = line('$')
    let current_indent = indent(current_line)
    while (current_line > 0 && current_line <= lastline)
        let current_line = current_line + stepvalue
        if (
                    \ ((a:indent_level < 0) && indent(current_line) < current_indent)
                    \ || ((a:indent_level == 0) && indent(current_line) == current_indent)
                    \ || ((a:indent_level > 0) && indent(current_line) > current_indent)
                    \)
            if (! a:skip_blanks || strlen(getline(current_line)) > 0)
                if (a:exclusive)
                    let current_line = current_line - stepvalue
                endif
                if a:preserve_col_pos
                    execute "normal! " . current_line . "G" . current_column . "|"
                else
                    execute "normal! " . current_line . "G^"
                endif
                return
            endif
        endif
    endwhile
endfunction
" 2}}}

" 1}}}

" Public Command and Key Maps {{{1
" ==============================================================================

nnoremap <silent> [- :call <SID>move_to_indent_level(0, 0, -1, 1, 0)<CR>
nnoremap <silent> ]- :call <SID>move_to_indent_level(0, 1, -1, 1, 0)<CR>
nnoremap <silent> [= :call <SID>move_to_indent_level(0, 0, 0, 1, 0)<CR>
nnoremap <silent> ]= :call <SID>move_to_indent_level(0, 1, 0, 1, 0)<CR>
nnoremap <silent> [+ :call <SID>move_to_indent_level(0, 0, +1, 1, 0)<CR>
nnoremap <silent> ]+ :call <SID>move_to_indent_level(0, 1, +1, 1, 0)<CR>
vnoremap <silent> [- <Esc>:call <SID>move_to_indent_level(0, 0, -1, 1, 0)<CR>m'gv''
vnoremap <silent> ]- <Esc>:call <SID>move_to_indent_level(0, 1, -1, 1, 0)<CR>m'gv''
vnoremap <silent> [= <Esc>:call <SID>move_to_indent_level(0, 0, 0, 1, 0)<CR>m'gv''
vnoremap <silent> ]= <Esc>:call <SID>move_to_indent_level(0, 1, 0, 1, 0)<CR>m'gv''
vnoremap <silent> [+ <Esc>:call <SID>move_to_indent_level(0, 0, +1, 1, 0)<CR>m'gv''
vnoremap <silent> ]+ <Esc>:call <SID>move_to_indent_level(0, 1, +1, 1, 0)<CR>m'gv''

" 1}}}

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" 1}}}

" vim:foldlevel=4:
