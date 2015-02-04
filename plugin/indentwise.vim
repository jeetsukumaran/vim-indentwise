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

" Global Options {{{1
" ============================================================================
let g:indentwise_equal_indent_skips_contiguous = get(g:, 'indentwise_equal_indent_skips_contiguous', 1)
" 1}}}

" Main Code {{{1
" ==============================================================================

" sw() {{{2
" ==============================================================================
if exists('*shiftwidth')
    func s:sw()
        return shiftwidth()
    endfunc
else
    func s:sw()
        return &sw
    endfunc
endif
" 2}}}

" move_to_indent_depth {{{2
" ==============================================================================
" Jump to the next or previous line that has the same depth, higher, or a
" lower depth of indentation than the current line.
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
" target_indent_depth : int
"   <0: Go to line with smaller indentation depth;
"    0: Go to line with the same indentation depth;
"   >0: Go to line with the larger indentation depth;
" skip_blanks : bool
"   true: Skip blank lines; false: Don't skip blank lines
" preserve_col_pos : bool
"   true: keep current cursor column; false: go to first non-space column
"
function! <SID>move_to_indent_depth(exclusive, fwd, target_indent_depth, skip_blanks, preserve_col_pos, vis_mode) range
    let stepvalue = a:fwd ? 1 : -1
    if a:fwd
        let stepvalue = 1
        let current_line = a:lastline
    else
        let stepvalue = -1
        let current_line = a:firstline
    endif
    let start_line = current_line
    let last_accepted_line = current_line
    let current_column = col('.')
    let lastline = line('$')
    let current_indent = indent(current_line)
    let num_reps = v:count1
    let indent_depth_changed = 0
    while (current_line > 0 && current_line <= lastline && num_reps > 0)
        let current_line = current_line + stepvalue
        let candidate_line_indent = indent(current_line)
        let accept_line = 0
        if ((a:target_indent_depth < 0) && candidate_line_indent < current_indent)
            let accept_line = 1
        elseif ((a:target_indent_depth > 0) && candidate_line_indent > current_indent)
            let accept_line = 1
        elseif (a:target_indent_depth == 0)
            if candidate_line_indent == current_indent
                if l:indent_depth_changed || !g:indentwise_equal_indent_skips_contiguous
                    let accept_line = 1
                    let indent_depth_changed = 0
                else
                    let last_accepted_line = current_line
                endif
            elseif candidate_line_indent != current_indent
                let indent_depth_changed = 1
            endif
        endif
        if accept_line
            if (! a:skip_blanks || strlen(getline(current_line)) > 0)
                let num_reps = num_reps - 1
                let current_indent = candidate_line_indent
                let last_accepted_line = current_line
                " echomsg num_reps . ": " . current_line . ": ". getline(current_line)
            endif
        endif
    endwhile
    if a:vis_mode
        normal! gv
    endif
    if (a:exclusive)
        let last_accepted_line = last_accepted_line - stepvalue
    endif
    if (last_accepted_line != start_line)
        if a:preserve_col_pos
            execute "normal! " . last_accepted_line . "G" . current_column . "|"
        else
            execute "normal! " . last_accepted_line . "G^"
        endif
    endif
endfunction
" 2}}}

" move_to_absolute_indent_level {{{2
" ==============================================================================
function! <SID>move_to_absolute_indent_level(exclusive, fwd, skip_blanks, preserve_col_pos, vis_mode) range
    if a:fwd
        let stepvalue = 1
        let current_line = a:lastline
    else
        let stepvalue = -1
        let current_line = a:firstline
    endif
    let lastline = line('$')
    let current_indent = indent(current_line)
    let target_indent = v:count * s:sw()
    let num_reps = 1
    while (current_line > 0 && current_line <= lastline && num_reps > 0)
        let current_line = current_line + stepvalue
        let candidate_line_indent = indent(current_line)
        if (candidate_line_indent == target_indent)
            if (! a:skip_blanks || strlen(getline(current_line)) > 0)
                let num_reps = num_reps - 1
                let current_indent = candidate_line_indent
                " echomsg num_reps . ": " . current_line . ": ". getline(current_line)
            endif
        endif
    endwhile
    if a:vis_mode
        normal! gv
    endif
    if (a:exclusive)
        let current_line = current_line - stepvalue
    endif
    if (current_line > 0 && current_line <= lastline)
        if a:preserve_col_pos
            execute "normal! " . current_line . "G" . current_column . "|"
        else
            execute "normal! " . current_line . "G^"
        endif
    endif
endfunction
" 2}}}

" 1}}}

" Public Command and Key Maps {{{1
" ==============================================================================

nnoremap <silent> <Plug>(IndentWisePreviousLesserIndent)   :<C-U>call <SID>move_to_indent_depth(0, 0, -1, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWisePreviousLesserIndent)   :call <SID>move_to_indent_depth(0, 0, -1, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWisePreviousLesserIndent)   V:<C-U>call <SID>move_to_indent_depth(1, 0, -1, 1, 0, 0)<CR>

nnoremap <silent> <Plug>(IndentWisePreviousEqualIndent)    :<C-U>call <SID>move_to_indent_depth(0, 0,  0, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWisePreviousEqualIndent)    :call <SID>move_to_indent_depth(0, 0,  0, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWisePreviousEqualIndent)    V:<C-U>call <SID>move_to_indent_depth(1, 0,  0, 1, 0, 0)<CR>

nnoremap <silent> <Plug>(IndentWisePreviousGreaterIndent)  :<C-U>call <SID>move_to_indent_depth(0, 0, +1, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWisePreviousGreaterIndent)  :call <SID>move_to_indent_depth(0, 0, +1, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWisePreviousGreaterIndent)  V:<C-U>call <SID>move_to_indent_depth(1, 0, +1, 1, 0, 0)<CR>

nnoremap <silent> <Plug>(IndentWiseNextLesserIndent)       :<C-U>call <SID>move_to_indent_depth(0, 1, -1, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWiseNextLesserIndent)       :call <SID>move_to_indent_depth(0, 1, -1, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWiseNextLesserIndent)       V:<C-U>call <SID>move_to_indent_depth(1, 1, -1, 1, 0, 0)<CR>

nnoremap <silent> <Plug>(IndentWiseNextEqualIndent)        :<C-U>call <SID>move_to_indent_depth(0, 1,  0, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWiseNextEqualIndent)        :call <SID>move_to_indent_depth(0, 1,  0, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWiseNextEqualIndent)        V:<C-U>call <SID>move_to_indent_depth(1, 1,  0, 1, 0, 0)<CR>

nnoremap <silent> <Plug>(IndentWiseNextGreaterIndent)      :<C-U>call <SID>move_to_indent_depth(0, 1, +1, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWiseNextGreaterIndent)      :call <SID>move_to_indent_depth(0, 1, +1, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWiseNextGreaterIndent)      V:<C-U>call <SID>move_to_indent_depth(1, 1, +1, 1, 0, 0)<CR>

nnoremap <silent> <Plug>(IndentWisePreviousAbsoluteIndent) :<C-U>call <SID>move_to_absolute_indent_level(0, 0, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWisePreviousAbsoluteIndent) :call <SID>move_to_absolute_indent_level(0, 0, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWisePreviousAbsoluteIndent) V:<C-U>call <SID>move_to_absolute_indent_level(1, 0, 1, 0, 1)<CR>
nnoremap <silent> <Plug>(IndentWiseNextAbsoluteIndent)     :<C-U>call <SID>move_to_absolute_indent_level(0, 1, 1, 0, 0)<CR>
vnoremap <silent> <Plug>(IndentWiseNextAbsoluteIndent)     :call <SID>move_to_absolute_indent_level(0, 1, 1, 0, 1)<CR>
onoremap <silent> <Plug>(IndentWiseNextAbsoluteIndent)     V:<C-U>call <SID>move_to_absolute_indent_level(1, 1, 1, 0, 1)<CR>

if !exists("g:indentwise_suppress_keymaps") || !g:indentwise_suppress_keymaps
    if !hasmapto('<Plug>(IndentWisePreviousLesserIndent)')
        map [- <Plug>(IndentWisePreviousLesserIndent)
    endif
    if !hasmapto('<Plug>(IndentWisePreviousEqualIndent)')
        map [= <Plug>(IndentWisePreviousEqualIndent)
    endif
    if !hasmapto('<Plug>(IndentWisePreviousGreaterIndent)')
        map [+ <Plug>(IndentWisePreviousGreaterIndent)
    endif
    if !hasmapto('<Plug>(IndentWiseNextLesserIndent)')
        map ]- <Plug>(IndentWiseNextLesserIndent)
    endif
    if !hasmapto('<Plug>(IndentWiseNextEqualIndent)')
        map ]= <Plug>(IndentWiseNextEqualIndent)
    endif
    if !hasmapto('<Plug>(IndentWiseNextGreaterIndent)')
        map ]+ <Plug>(IndentWiseNextGreaterIndent)
    endif
    if !hasmapto('<Plug>(IndentWisePreviousAbsoluteIndent)')
        map [_ <Plug>(IndentWisePreviousAbsoluteIndent)
    endif
    if !hasmapto('<Plug>(IndentWiseNextAbsoluteIndent)')
        map ]_ <Plug>(IndentWiseNextAbsoluteIndent)
    endif
endif

" 1}}}

" Restore State {{{1
" ============================================================================
" restore options
let &cpo = s:save_cpo
" 1}}}

" vim:foldlevel=4:
