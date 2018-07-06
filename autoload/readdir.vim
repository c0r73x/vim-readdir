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

let s:sep = fnamemodify('', ':p')[-1:]

function s:sort_by_type(a, b)
    if isdirectory(a:a) && !isdirectory(a:b) | return -1
    elseif isdirectory(a:b) && !isdirectory(a:a) | return 1
    endif

    return a:a >? a:b
endfunction

function s:set_line(val)
    let l:isdir = isdirectory(a:val)
    let l:name = split(a:val, s:sep)[-1] . (l:isdir ? s:sep : '')

    if exists('g:loaded_webdevicons')
        let l:name = WebDevIconsGetFileTypeSymbol(l:name, l:isdir) . ' '. l:name
    endif

    return l:name
endfunction

function readdir#Selected()
    return b:readdir.content[line('.') - 1]
endfunction

function readdir#Show(path, focus)
    let l:readdir = b:readdir
    let l:title = fnamemodify(a:path, ':p')

    silent! file `=l:title`
    let l:path = expand('%:p') " remove double dots

    let l:content = (l:readdir.hidden == 2 ?
                \       glob(l:path . '.[^.]', 0, 1) +
                \       glob(l:path . '.??*', 0, 1) :
                \       [])
                \ + glob(l:path . '*', l:readdir.hidden, 1)

    let l:content = sort(l:content, 's:sort_by_type')
    if l:path !=# '/' | let l:content = [l:path . '..'] + l:content | endif

    setlocal modifiable
    silent 0,$ delete
    call setline(1, map(l:content[:], 's:set_line(v:val)'))

    setlocal nomodifiable nomodified

    let l:line = 1 + index(l:content, a:focus)
    call cursor(l:line ? l:line : 1, 1)
    call extend(l:readdir, {'cwd': l:path, 'content': l:content})

    let b:readdir = l:readdir
endfunction

function readdir#Open(path)
    if isdirectory(a:path)
        return readdir#Show(a:path, b:readdir.cwd)
    endif

    if exists('b:readdir.sidebar')
        exe 'wincmd p | edit ' . a:path
    else
        let l:me = bufnr('%')
        edit `=a:path`
        exe 'silent! bwipeout!' l:me
    endif
endfunction

function! readdir#Lexplore(dir, right)
    if exists('t:readdir_lexbufnr')
        let l:lexwinnr = bufwinnr(t:readdir_lexbufnr)
        if l:lexwinnr > 0
            let l:curwin = winnr()
            exe l:lexwinnr . 'wincmd w'
            exe 'silent! bwipeout!' . winbufnr(l:lexwinnr)
        endif
        unlet t:readdir_lexbufnr
    else
        let l:path = fnamemodify('.', ':p:h')
        if a:0 > 0 && a:dir !=# ''
            let l:path = fnameescape(a:dir)
        endif

        exec (a:right ? 'botright' : 'topleft') .
                    \ ' vertical ' . ((g:readdir_winsize > 0) ?
                    \ (g:readdir_winsize * winwidth(0)) / 100 :
                    \ -g:readdir_winsize) . ' new ' . l:path

        setlocal winfixwidth
        let t:readdir_lexbufnr = bufnr('%')
        let b:readdir.sidebar = 1

        exec 'nnoremap <buffer> <silent> q :Lexplore<CR>'
    endif
endfunction

function readdir#CycleHidden()
    let b:readdir.hidden = (b:readdir.hidden + 1) % 3
    call readdir#Show(b:readdir.cwd, readdir#Selected())
endfunction

" vim:foldmethod=marker
