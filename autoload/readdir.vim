" Vim global plugin for very minimal directory browsing
" Licence:     The MIT License (MIT)
" Commit:      $Format:%H$
" {{{ Copyright (c) 2015 Aristotle Pagaltzis <pagaltzis@gmx.de>
"
" Permission is hereby granted, free of charge, to any person obtaining a copy
" of this software and associated documentation files (the "Software"), to deal
" in the Software without restriction, including without limitation the rights
" to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
" copies of the Software, and to permit persons to whom the Software is
" furnished to do so, subject to the following conditions:
"
" The above copyright notice and this permission notice shall be included in
" all copies or substantial portions of the Software.
"
" THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
" IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
" FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
" AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
" LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
" OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
" THE SOFTWARE.
" }}}

if v:version < 700
    echoerr printf(
                \ 'Vim 7 is required for readdir (this is only %d.%d)',
                \ v:version / 100,
                \ v:version % 100,
                \ )
    finish
endif

let s:sep = fnamemodify('',':p')[-1:]

function s:sort_by_type(a, b)
    if isdirectory(a:a) && !isdirectory(a:b) | return -1
    elseif isdirectory(a:b) && !isdirectory(a:a) | return 1
    endif

    return a:a <? a:b
endfunction

function readdir#Selected()
    return b:readdir.content[line('.') - 1]
endfunction

function readdir#Show(path, focus)
    let l:readdir = b:readdir

    silent! file `=a:path`

    let l:path = fnamemodify(a:path, ':p') " ensure trailing slash
    let l:content = (l:readdir.hidden == 2 ?
                \       glob(l:path . '.[^.]', 0, 1) +
                \       glob(l:path . '.??*', 0, 1) :
                \       [])
                \ + glob(l:path . '*', l:readdir.hidden, 1)

    let l:content = [l:path . '..'] + sort(l:content[:], 's:sort_by_type')

    setlocal modifiable
    silent 0,$ delete
    call setline(
                \ 1,
                \ map(
                \   l:content[:],
                \   'split(v:val,s:sep)[-1] . (isdirectory(v:val) ? s:sep : '''')',
                \ ),
                \ )

    setlocal nomodifiable nomodified

    let l:line = 1 + index(l:content, a:focus)
    call cursor(l:line ? l:line : 1, 1)
    call extend(l:readdir, {'cwd': a:path, 'content': l:content})

    let b:readdir = l:readdir
endfunction

function readdir#Open(path)
    if isdirectory(a:path)
        return readdir#Show(a:path, b:readdir.cwd)
    endif

    let l:me = bufnr('%')
    edit `=a:path`
    exe 'silent! bwipeout!' l:me
endfunction

function readdir#CycleHidden()
    let b:readdir.hidden = (b:readdir.hidden + 1) % 3
    call readdir#Show(b:readdir.cwd, readdir#Selected())
endfunction

" vim:foldmethod=marker
